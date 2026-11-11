-- =====================================================================
-- Reservaciones: segunda revisión del equipo
--
-- 1. Solo el CLIENTE hace reservaciones. Ni el mesero ni el gerente crean.
-- 2. El MESERO solo consulta: no crea, no modifica, no cancela, no confirma.
-- 3. El GERENTE modifica y cancela las reservaciones de los clientes (sin el límite de
--    5 horas), pero no crea ni confirma por el cliente.
-- 4. Solo el cliente confirma (con más de 5 horas de anticipación, como antes).
--
-- No se edita la migración anterior: se reemplazan las políticas RLS y la función
-- `reservacion_validar()`. Sobre `asignar_mesa()` no hay cambios.
-- =====================================================================

-- RLS: crear solo el dueño (cliente); modificar el dueño o el gerente. El mesero solo lee.
drop policy reservacion_insert on public.reservacion;
create policy reservacion_insert on public.reservacion for insert to authenticated
  with check (id_cliente = public.id_cliente_actual());

drop policy reservacion_update on public.reservacion;
create policy reservacion_update on public.reservacion for update to authenticated
  using (id_cliente = public.id_cliente_actual() or public.rol_actual() = 'gerente')
  with check (id_cliente = public.id_cliente_actual() or public.rol_actual() = 'gerente');

create or replace function public.reservacion_validar() returns trigger
language plpgsql security definer set search_path = public as $$
declare
  v_rol text;
  v_inicio_old timestamp;
  v_cambia boolean;
begin
  v_rol := case when public.es_sistema() then 'sistema' else public.rol_actual() end;

  if tg_op = 'INSERT' then
    if v_rol = 'cliente' then
      new.id_cliente := public.id_cliente_actual();
      new.estado := 'pendiente';
      if (new.fecha + new.hora) < public.ahora_local() + interval '5 hours' then
        raise exception 'Las reservaciones requieren al menos 5 horas de anticipación';
      end if;
    elsif v_rol <> 'sistema' then
      raise exception 'Solo los clientes pueden hacer reservaciones';
    end if;
    perform pg_advisory_xact_lock(hashtext('reservacion_mesa'));
    new.id_mesa := public.asignar_mesa(new.fecha, new.hora, new.num_comensales, null);
    if new.id_mesa is null then
      raise exception 'No hay mesas disponibles para esa fecha, hora y número de comensales';
    end if;
    return new;
  end if;

  -- UPDATE
  v_inicio_old := old.fecha + old.hora;
  v_cambia := (new.fecha, new.hora, new.num_comensales)
              is distinct from (old.fecha, old.hora, old.num_comensales);

  if v_rol <> 'sistema' and new.id_cliente is distinct from old.id_cliente then
    raise exception 'No se puede cambiar el cliente de una reservación';
  end if;

  if v_rol = 'cliente' then
    if old.id_cliente is distinct from public.id_cliente_actual() then
      raise exception 'No autorizado';
    end if;
    new.id_mesa := old.id_mesa;

    if new.estado is distinct from old.estado then
      if old.estado = 'pendiente' and new.estado = 'confirmada' then
        if v_cambia then
          raise exception 'Para confirmar no se puede modificar la reservación';
        end if;
        if v_inicio_old - interval '5 hours' < public.ahora_local() then
          raise exception 'Ya no puedes confirmar: la reservación se confirma con más de 5 horas de anticipación';
        end if;
      elsif old.estado in ('pendiente', 'confirmada') and new.estado = 'cancelada' then
        if v_inicio_old - interval '5 hours' < public.ahora_local() then
          raise exception 'Solo puedes cancelar con 5 horas de anticipación; contacta al restaurante';
        end if;
      else
        raise exception 'Cambio de estado no permitido';
      end if;
    end if;

    if v_cambia then
      if old.estado not in ('pendiente', 'confirmada') then
        raise exception 'Esta reservación ya no puede modificarse';
      end if;
      if v_inicio_old - interval '5 hours' < public.ahora_local() then
        raise exception 'Solo puedes modificar con 5 horas de anticipación; contacta al restaurante';
      end if;
      if (new.fecha + new.hora) < public.ahora_local() + interval '5 hours' then
        raise exception 'La nueva fecha y hora deben tener al menos 5 horas de anticipación';
      end if;
      new.estado := 'pendiente'; -- hay que volver a confirmar
    end if;
  elsif v_rol = 'gerente' then
    -- El gerente modifica y cancela; confirmar es solo del cliente.
    if new.estado is distinct from old.estado and new.estado = 'confirmada' then
      raise exception 'Solo el cliente puede confirmar su reservación';
    end if;
  elsif v_rol <> 'sistema' then
    -- Mesero (y cualquier otro): solo consulta.
    raise exception 'Solo el gerente puede modificar o cancelar reservaciones';
  end if;

  if v_cambia and new.estado in ('pendiente', 'confirmada') then
    perform pg_advisory_xact_lock(hashtext('reservacion_mesa'));
    new.id_mesa := public.asignar_mesa(new.fecha, new.hora, new.num_comensales, old.id_reservacion);
    if new.id_mesa is null then
      raise exception 'No hay mesas disponibles para esa fecha, hora y número de comensales';
    end if;
  end if;
  return new;
end $$;
