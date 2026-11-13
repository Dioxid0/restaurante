-- RN-03 corregida: ya no hay PIN del gerente (un PIN compartido se puede aprender o prestar).
-- Ahora el mesero SOLICITA el cambio de un pedido que ya no está pendiente y el gerente
-- lo APRUEBA desde su propia sesión. La aprobación abre una ventana de 10 minutos sobre ese
-- pedido (pedido.autorizado_por / autorizacion_hasta), que es el mismo mecanismo que ya
-- validaban los triggers y actualizar_pedido: aquí solo cambia cómo se concede.

-- 1. Se quita el PIN. (La tabla gerente_pin se conserva, pero ya nada la usa.)
drop function if exists public.autorizar_con_pin(bigint, text);
drop function if exists public.establecer_pin(text);

-- 2. Solicitudes de cambio
create table public.solicitud_cambio (
  id_solicitud         bigint generated always as identity primary key,
  fecha_solicitud      timestamptz not null default now(),
  folio                bigint not null references public.pedido (folio) on delete cascade,
  tipo                 text not null check (tipo in ('modificar', 'cancelar')),
  motivo               text not null check (length(btrim(motivo)) > 0 and length(motivo) <= 200),
  estado               text not null default 'pendiente'
                         check (estado in ('pendiente', 'aprobada', 'rechazada')),
  id_empleado_solicita bigint not null references public.empleado (id_empleado),
  id_empleado_resuelve bigint references public.empleado (id_empleado),
  fecha_resolucion     timestamptz,
  vigente_hasta        timestamptz  -- solo si fue aprobada: fin de la ventana de 10 minutos
);
-- Una sola solicitud pendiente por pedido.
create unique index solicitud_cambio_una_pendiente on public.solicitud_cambio (folio) where estado = 'pendiente';
create index on public.solicitud_cambio (fecha_solicitud desc);

alter table public.solicitud_cambio enable row level security;
revoke all on public.solicitud_cambio from anon;
revoke insert, update, delete on public.solicitud_cambio from authenticated;
grant select on public.solicitud_cambio to authenticated;
-- Solo lectura desde la API (mesero y gerente); escribir es únicamente con las funciones de abajo.
create policy solicitud_select on public.solicitud_cambio for select to authenticated
  using (public.rol_actual() in ('mesero', 'gerente'));

create trigger auditar after insert or update or delete on public.solicitud_cambio
  for each row execute function public.auditar('id_solicitud');

-- 3. El mesero pide el cambio
create function public.solicitar_cambio(p_folio bigint, p_tipo text, p_motivo text)
returns bigint
language plpgsql security definer set search_path = public as $$
declare
  v_ped public.pedido%rowtype;
  v_id bigint;
begin
  if public.rol_actual() <> 'mesero' then
    raise exception 'Solo el mesero solicita cambios (el gerente modifica directamente)';
  end if;
  if p_tipo is null or p_tipo not in ('modificar', 'cancelar') then
    raise exception 'Tipo de solicitud no válido';
  end if;
  if nullif(btrim(coalesce(p_motivo, '')), '') is null then
    raise exception 'Indica el motivo de la solicitud';
  end if;
  if length(p_motivo) > 200 then
    raise exception 'El motivo admite hasta 200 caracteres';
  end if;
  select * into v_ped from public.pedido where folio = p_folio;
  if not found then
    raise exception 'Pedido no encontrado';
  end if;
  if v_ped.estado in ('cancelado', 'completado') then
    raise exception 'El pedido ya está cerrado y no puede modificarse';
  end if;
  if v_ped.estado = 'pendiente' then
    raise exception 'El pedido sigue pendiente: puedes modificarlo o cancelarlo sin autorización';
  end if;
  if v_ped.autorizacion_hasta is not null and v_ped.autorizacion_hasta > now() then
    raise exception 'Ya tienes autorización vigente para este pedido';
  end if;
  if exists (select 1 from public.solicitud_cambio where folio = p_folio and estado = 'pendiente') then
    raise exception 'Ya hay una solicitud pendiente para este pedido';
  end if;
  insert into public.solicitud_cambio (folio, tipo, motivo, id_empleado_solicita)
  values (p_folio, p_tipo, btrim(p_motivo), public.id_empleado_actual())
  returning id_solicitud into v_id;
  return v_id;
end $$;

-- 4. El gerente aprueba o rechaza
create function public.resolver_solicitud(p_id bigint, p_aprobar boolean)
returns void
language plpgsql security definer set search_path = public as $$
declare
  v_sol public.solicitud_cambio%rowtype;
  v_ped public.pedido%rowtype;
  v_hasta timestamptz := now() + interval '10 minutes';
begin
  if public.rol_actual() <> 'gerente' then
    raise exception 'Solo el gerente resuelve solicitudes';
  end if;
  select * into v_sol from public.solicitud_cambio where id_solicitud = p_id for update;
  if not found then
    raise exception 'Solicitud no encontrada';
  end if;
  if v_sol.estado <> 'pendiente' then
    raise exception 'Esta solicitud ya fue resuelta';
  end if;
  select * into v_ped from public.pedido where folio = v_sol.folio;

  if p_aprobar then
    if v_ped.estado in ('cancelado', 'completado') then
      raise exception 'El pedido ya está cerrado y no puede modificarse';
    end if;
    perform set_config('app.interno', '1', true);
    update public.pedido
       set autorizado_por = public.id_empleado_actual(), autorizacion_hasta = v_hasta
     where folio = v_sol.folio;
    perform set_config('app.interno', '', true);
    update public.solicitud_cambio
       set estado = 'aprobada', vigente_hasta = v_hasta,
           id_empleado_resuelve = public.id_empleado_actual(), fecha_resolucion = now()
     where id_solicitud = p_id;
  else
    update public.solicitud_cambio
       set estado = 'rechazada',
           id_empleado_resuelve = public.id_empleado_actual(), fecha_resolucion = now()
     where id_solicitud = p_id;
  end if;
end $$;

revoke execute on function public.solicitar_cambio(bigint, text, text) from public, anon;
revoke execute on function public.resolver_solicitud(bigint, boolean) from public, anon;
grant execute on function public.solicitar_cambio(bigint, text, text) to authenticated;
grant execute on function public.resolver_solicitud(bigint, boolean) to authenticated;

-- 5. Tiempo real: el gerente ve llegar las solicitudes y el mesero ve la respuesta.
do $$
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    alter publication supabase_realtime add table public.solicitud_cambio;
  end if;
end $$;

-- 6. Mensaje nuevo en las reglas (antes decían "Se requiere el PIN del gerente").
-- Son las mismas funciones de siempre; solo cambia el texto del error.

create or replace function public.pedido_antes_update() returns trigger
language plpgsql security definer set search_path = public as $$
declare
  v_rol text;
  v_autorizado boolean;
begin
  if public.es_sistema() or coalesce(current_setting('app.interno', true), '') = '1' then
    return new;
  end if;
  v_rol := public.rol_actual();

  if old.estado in ('cancelado', 'completado') then
    raise exception 'El pedido ya está cerrado y no puede modificarse';
  end if;

  if new.folio is distinct from old.folio
     or new.folio_dia is distinct from old.folio_dia
     or new.fecha_operativa is distinct from old.fecha_operativa
     or new.hora_ingreso is distinct from old.hora_ingreso
     or new.origen is distinct from old.origen
     or new.id_empleado is distinct from old.id_empleado
     or new.id_cliente is distinct from old.id_cliente
     or new.total is distinct from old.total
     or new.descuento is distinct from old.descuento
     or new.es_cortesia is distinct from old.es_cortesia
     or new.motivo_descuento is distinct from old.motivo_descuento
     or new.id_empleado_descuento is distinct from old.id_empleado_descuento
     or new.autorizado_por is distinct from old.autorizado_por
     or new.autorizacion_hasta is distinct from old.autorizacion_hasta then
    raise exception 'Campo protegido: no se puede modificar directamente';
  end if;

  v_autorizado := v_rol = 'gerente'
    or (old.autorizacion_hasta is not null and old.autorizacion_hasta > now());

  if new.estado is distinct from old.estado then
    if new.estado = 'cancelado' then
      if nullif(btrim(coalesce(new.motivo_cancelacion, '')), '') is null then
        raise exception 'Indica el motivo de la cancelación';
      end if;
      if v_rol = 'cliente' then
        if old.id_cliente is distinct from public.id_cliente_actual() then
          raise exception 'No autorizado';
        end if;
        if old.estado <> 'pendiente' then
          raise exception 'Tu pedido ya está en preparación y no puede cancelarse; pide ayuda al mesero';
        end if;
      elsif v_rol = 'mesero' then
        if old.estado <> 'pendiente' and not v_autorizado then
          raise exception 'Este pedido ya no está pendiente: pide al gerente que apruebe tu solicitud de cambio';
        end if;
      elsif v_rol <> 'gerente' then
        raise exception 'No autorizado';
      end if;
    elsif v_rol = 'chef' then
      if not ((old.estado = 'pendiente' and new.estado = 'en_preparacion')
           or (old.estado = 'en_preparacion' and new.estado = 'listo')) then
        raise exception 'Transición de estado no permitida para cocina';
      end if;
    elsif v_rol = 'mesero' then
      if not ((old.estado = 'listo' and new.estado = 'entregado')
           or (old.estado = 'entregado' and new.estado = 'completado')) then
        raise exception 'Transición de estado no permitida';
      end if;
    elsif v_rol <> 'gerente' then
      raise exception 'No autorizado';
    end if;
  elsif new.tipo_pedido is distinct from old.tipo_pedido
     or new.id_mesa is distinct from old.id_mesa
     or new.motivo_cancelacion is distinct from old.motivo_cancelacion then
    if v_rol not in ('mesero', 'gerente') then
      raise exception 'No autorizado';
    end if;
    if old.estado <> 'pendiente' and not v_autorizado then
      raise exception 'Este pedido ya no está pendiente: pide al gerente que apruebe tu solicitud de cambio';
    end if;
  end if;
  return new;
end $$;

create or replace function public.detalle_validar_edicion() returns trigger
language plpgsql security definer set search_path = public as $$
declare
  v_ped public.pedido%rowtype;
  v_rol text;
  v_aut boolean;
begin
  if public.es_sistema() or coalesce(current_setting('app.creando_pedido', true), '') = '1' then
    return coalesce(new, old);
  end if;
  select * into v_ped from public.pedido where folio = coalesce(new.folio, old.folio);
  v_rol := public.rol_actual();

  if v_ped.estado in ('cancelado', 'completado') then
    raise exception 'El pedido ya está cerrado y no puede modificarse';
  end if;
  v_aut := v_rol = 'gerente'
    or (v_ped.autorizacion_hasta is not null and v_ped.autorizacion_hasta > now());

  if v_rol = 'cliente' then
    if v_ped.id_cliente is distinct from public.id_cliente_actual() then
      raise exception 'No autorizado';
    end if;
    if v_ped.estado <> 'pendiente' then
      raise exception 'Tu pedido ya está en preparación y no puede modificarse; pide ayuda al mesero';
    end if;
  elsif v_rol = 'mesero' then
    if v_ped.estado <> 'pendiente' and not v_aut then
      raise exception 'Este pedido ya no está pendiente: pide al gerente que apruebe tu solicitud de cambio';
    end if;
  elsif v_rol <> 'gerente' then
    raise exception 'No autorizado';
  end if;

  if tg_op = 'UPDATE' and new.folio is distinct from old.folio then
    raise exception 'No se puede mover un renglón a otro pedido';
  end if;
  return coalesce(new, old);
end $$;

create or replace function public.actualizar_pedido(
  p_folio bigint, p_tipo_pedido text, p_id_mesa bigint, p_items jsonb
) returns void
language plpgsql security definer set search_path = public as $$
declare
  v_rol text := public.rol_actual();
  v_ped public.pedido%rowtype;
  v_aut boolean;
  v_item jsonb;
begin
  select * into v_ped from public.pedido where folio = p_folio for update;
  if not found then
    raise exception 'Pedido no encontrado';
  end if;
  if v_ped.estado in ('cancelado', 'completado') then
    raise exception 'El pedido ya está cerrado y no puede modificarse';
  end if;

  v_aut := v_rol = 'gerente'
    or (v_ped.autorizacion_hasta is not null and v_ped.autorizacion_hasta > now());

  if v_rol = 'cliente' then
    if v_ped.id_cliente is distinct from public.id_cliente_actual() then
      raise exception 'No autorizado';
    end if;
    if v_ped.estado <> 'pendiente' then
      raise exception 'Tu pedido ya está en preparación y no puede modificarse; pide ayuda al mesero';
    end if;
    p_tipo_pedido := 'para_llevar';
    p_id_mesa := null;
  elsif v_rol = 'mesero' then
    if v_ped.estado <> 'pendiente' and not v_aut then
      raise exception 'Este pedido ya no está pendiente: pide al gerente que apruebe tu solicitud de cambio';
    end if;
  elsif v_rol <> 'gerente' then
    raise exception 'No autorizado';
  end if;

  if p_tipo_pedido not in ('en_mesa', 'para_llevar') then
    raise exception 'Tipo de pedido inválido';
  end if;
  if p_tipo_pedido = 'en_mesa' and p_id_mesa is null then
    raise exception 'Un pedido en mesa requiere la mesa';
  end if;
  if p_items is null or jsonb_typeof(p_items) <> 'array' or jsonb_array_length(p_items) = 0 then
    raise exception 'El pedido debe tener al menos un platillo';
  end if;

  perform set_config('app.creando_pedido', '1', true);
  delete from public.detalle_pedido where folio = p_folio;
  for v_item in select * from jsonb_array_elements(p_items) loop
    insert into public.detalle_pedido (folio, id_platillo, cantidad, notas_especiales)
    values (p_folio, (v_item ->> 'id_platillo')::bigint, (v_item ->> 'cantidad')::int,
            nullif(btrim(coalesce(v_item ->> 'notas_especiales', '')), ''));
  end loop;
  perform set_config('app.creando_pedido', '', true);

  perform set_config('app.interno', '1', true);
  update public.pedido set tipo_pedido = p_tipo_pedido, id_mesa = p_id_mesa where folio = p_folio;
  perform set_config('app.interno', '', true);

  insert into public.notificacion_cocina (mensaje, tipo_evento, folio)
  values ('Pedido #' || v_ped.folio_dia || ' modificado', 'modificado', p_folio);
end $$;
