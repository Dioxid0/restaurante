-- =====================================================================
-- Reservaciones: ajustes tras la revisión del equipo (CU-10, CU-12, CU-13, CU-14)
--
-- 1. Solo el gerente (y el cliente, con RN-07) puede cancelar. El mesero no.
-- 2. Solo el cliente confirma su reservación; ni el mesero ni el gerente.
-- 3. El cliente confirma ANTES de que se cierre la ventana de 5 horas
--    (la misma de RN-07). Una reservación que sigue `pendiente` al llegar a
--    las 5 horas queda "sin confirmar" y deja libre la mesa.
-- 4. El cliente solo reserva o reprograma con 5 horas de anticipación o más
--    (para menos tiempo debe llamar al restaurante).
-- 5. Lo que registra el personal a nombre de un cliente nace `confirmada`
--    (el cliente la confirmó al hacerla por teléfono o en persona).
--
-- No se editan migraciones anteriores: solo se reemplazan dos funciones.
-- =====================================================================

-- Una reservación `pendiente` solo aparta la mesa mientras el cliente todavía puede
-- confirmarla (faltan más de 5 horas). Después queda "sin confirmar" y la mesa se libera.
create or replace function public.asignar_mesa(
  p_fecha date, p_hora time, p_comensales int, p_excluir bigint default null
) returns bigint
language sql stable security definer set search_path = public as $$
  select m.id_mesa
  from public.mesa m
  where m.capacidad >= p_comensales
    and not exists (
      select 1 from public.reservacion r
      where r.id_mesa = m.id_mesa
        and (r.estado = 'confirmada'
             or (r.estado = 'pendiente'
                 and (r.fecha + r.hora) - interval '5 hours' > public.ahora_local()))
        and (p_excluir is null or r.id_reservacion <> p_excluir)
        and (r.fecha + r.hora) < (p_fecha + p_hora) + interval '2 hours'
        and (r.fecha + r.hora) + interval '2 hours' > (p_fecha + p_hora))
  order by m.capacidad, m.numero_mesa
  limit 1
$$;

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
        raise exception 'Para reservar se necesitan al menos 5 horas de anticipación; contacta al restaurante';
      end if;
    elsif v_rol in ('mesero', 'gerente') then
      -- El personal registra a nombre del cliente (por teléfono o en persona): nace confirmada.
      new.estado := 'confirmada';
    elsif v_rol <> 'sistema' then
      raise exception 'No autorizado';
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
  elsif v_rol in ('mesero', 'gerente') then
    if new.estado is distinct from old.estado then
      if new.estado = 'confirmada' then
        raise exception 'Solo el cliente puede confirmar su reservación';
      end if;
      if new.estado = 'cancelada' and v_rol <> 'gerente' then
        raise exception 'Solo el gerente puede cancelar reservaciones';
      end if;
    end if;
  elsif v_rol <> 'sistema' then
    raise exception 'No autorizado';
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

-- Ahora esta vista lista las reservaciones que NO se confirmaron a tiempo
-- (pendientes que ya entraron a las últimas 5 horas): el personal puede llamar al cliente.
comment on view public.reservaciones_por_confirmar is
  'Reservaciones pendientes que ya entraron a las últimas 5 horas: sin confirmar (la mesa ya está libre).';
