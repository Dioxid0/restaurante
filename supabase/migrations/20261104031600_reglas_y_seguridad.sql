-- =====================================================================
-- Reglas de negocio (triggers y funciones) y seguridad (RLS por rol)
-- Roles de la app: cliente, mesero, chef, gerente.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. AYUDANTES DE IDENTIDAD
-- ---------------------------------------------------------------------

-- Rol del usuario autenticado: mesero | chef | gerente | cliente | anonimo
create function public.rol_actual() returns text
language sql stable security definer set search_path = public as $$
  select coalesce(
    (select e.rol from public.empleado e where e.user_id = auth.uid() and e.activo),
    (select 'cliente' from public.cliente c where c.user_id = auth.uid()),
    'anonimo')
$$;

create function public.id_empleado_actual() returns bigint
language sql stable security definer set search_path = public as $$
  select e.id_empleado from public.empleado e where e.user_id = auth.uid() and e.activo
$$;

create function public.id_cliente_actual() returns bigint
language sql stable security definer set search_path = public as $$
  select c.id_cliente from public.cliente c where c.user_id = auth.uid()
$$;

-- true cuando NO es una petición de la API de un usuario (seeds, migraciones,
-- service_role, psql). Los triggers de validación no se aplican en ese caso.
create function public.es_sistema() returns boolean
language sql stable as $$
  select coalesce(auth.role(), '') not in ('anon', 'authenticated')
$$;

-- Al registrarse un usuario sin rol de empleado, se crea su ficha de cliente.
-- Los empleados se crean con app_metadata.rol (no editable por el usuario).
create function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if new.raw_app_meta_data ? 'rol' then
    return new;
  end if;
  insert into public.cliente (user_id, nombre, telefono, correo)
  values (
    new.id,
    coalesce(nullif(new.raw_user_meta_data ->> 'nombre', ''), split_part(new.email, '@', 1)),
    new.raw_user_meta_data ->> 'telefono',
    new.email);
  return new;
end $$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------
-- 2. PEDIDOS
-- ---------------------------------------------------------------------

create function public.calcular_total(p_folio bigint) returns numeric
language sql stable as $$
  select case when p.es_cortesia then 0
              else greatest(coalesce(s.suma, 0) - p.descuento, 0) end
  from public.pedido p
  left join lateral (
    select sum(d.subtotal) as suma from public.detalle_pedido d where d.folio = p.folio
  ) s on true
  where p.folio = p_folio
$$;

-- Asigna fecha operativa y folio del día (reinicia cada día).
create function public.pedido_antes_insert() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  perform pg_advisory_xact_lock(hashtext('pedido_folio_dia'));
  new.fecha_operativa := public.hoy_local();
  select coalesce(max(p.folio_dia), 0) + 1 into new.folio_dia
  from public.pedido p where p.fecha_operativa = new.fecha_operativa;
  return new;
end $$;

create trigger pedido_antes_insert before insert on public.pedido
  for each row execute function public.pedido_antes_insert();

-- Reglas de modificación / cancelación / transición de estado (RN-03).
create function public.pedido_antes_update() returns trigger
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
          raise exception 'Se requiere el PIN del gerente';
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
      raise exception 'Se requiere el PIN del gerente';
    end if;
  end if;
  return new;
end $$;

create trigger pedido_antes_update before update on public.pedido
  for each row execute function public.pedido_antes_update();

-- Cancelación => registro en merma_cancelacion + aviso a cocina.
create function public.pedido_despues_update() returns trigger
language plpgsql security definer set search_path = public as $$
declare
  v_rol text := public.rol_actual();
begin
  if new.estado = 'cancelado' and old.estado <> 'cancelado' then
    insert into public.merma_cancelacion
      (tipo, motivo, costo_perdida, folio, id_empleado_solicita, id_empleado_autoriza, cancelado_por)
    values (
      'cancelacion',
      coalesce(nullif(btrim(coalesce(new.motivo_cancelacion, '')), ''), 'Sin motivo'),
      case when old.estado in ('en_preparacion', 'listo', 'entregado') then new.total else 0 end,
      new.folio,
      public.id_empleado_actual(),
      case when v_rol = 'gerente' then public.id_empleado_actual()
           when old.estado = 'pendiente' then null
           else new.autorizado_por end,
      case when v_rol in ('cliente', 'mesero', 'gerente') then v_rol end);
    insert into public.notificacion_cocina (mensaje, tipo_evento, folio)
    values ('Pedido #' || new.folio_dia || ' cancelado', 'cancelado', new.folio);
  elsif new.estado = old.estado
    and (new.tipo_pedido is distinct from old.tipo_pedido or new.id_mesa is distinct from old.id_mesa)
    and coalesce(current_setting('app.interno', true), '') <> '1' then
    insert into public.notificacion_cocina (mensaje, tipo_evento, folio)
    values ('Pedido #' || new.folio_dia || ' modificado', 'modificado', new.folio);
  end if;
  return null;
end $$;

create trigger pedido_despues_update after update on public.pedido
  for each row execute function public.pedido_despues_update();

-- Detalle: quién puede editar y cuándo.
create function public.detalle_validar_edicion() returns trigger
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
      raise exception 'Se requiere el PIN del gerente';
    end if;
  elsif v_rol <> 'gerente' then
    raise exception 'No autorizado';
  end if;

  if tg_op = 'UPDATE' and new.folio is distinct from old.folio then
    raise exception 'No se puede mover un renglón a otro pedido';
  end if;
  return coalesce(new, old);
end $$;

-- Detalle: precio congelado al momento del pedido y subtotal calculado.
create function public.detalle_calcular_precio() returns trigger
language plpgsql security definer set search_path = public as $$
declare
  v_precio numeric;
  v_disp boolean;
begin
  select p.precio, p.disponible into v_precio, v_disp
  from public.platillo p where p.id_platillo = new.id_platillo;

  if tg_op = 'INSERT' or new.id_platillo is distinct from old.id_platillo then
    if not coalesce(v_disp, false) then
      raise exception 'El platillo no está disponible';
    end if;
    new.precio_unitario := v_precio;
  else
    new.precio_unitario := old.precio_unitario;
  end if;
  new.subtotal := round(new.cantidad * new.precio_unitario, 2);
  return new;
end $$;

create trigger detalle_1_validar before insert or update or delete on public.detalle_pedido
  for each row execute function public.detalle_validar_edicion();
create trigger detalle_2_precio before insert or update on public.detalle_pedido
  for each row execute function public.detalle_calcular_precio();

-- Detalle: recalcula total y avisa a cocina cuando se modifica un pedido existente.
create function public.detalle_despues_escritura() returns trigger
language plpgsql security definer set search_path = public as $$
declare
  v_folio bigint := coalesce(new.folio, old.folio);
  v_dia int;
begin
  perform set_config('app.interno', '1', true);
  update public.pedido set total = public.calcular_total(v_folio) where folio = v_folio;
  perform set_config('app.interno', '', true);

  if coalesce(current_setting('app.creando_pedido', true), '') <> '1' then
    select p.folio_dia into v_dia from public.pedido p where p.folio = v_folio;
    if v_dia is not null then
      insert into public.notificacion_cocina (mensaje, tipo_evento, folio)
      values ('Pedido #' || v_dia || ' modificado', 'modificado', v_folio);
    end if;
  end if;
  return null;
end $$;

create trigger detalle_despues_escritura after insert or update or delete on public.detalle_pedido
  for each row execute function public.detalle_despues_escritura();

-- ---------------------------------------------------------------------
-- 3. RESERVACIONES (asignación automática de mesa y RN-07)
-- ---------------------------------------------------------------------
-- Duración supuesta de una reservación: 2 horas. Ventana de RN-07: 5 horas.

create function public.asignar_mesa(
  p_fecha date, p_hora time, p_comensales int, p_excluir bigint default null
) returns bigint
language sql stable security definer set search_path = public as $$
  select m.id_mesa
  from public.mesa m
  where m.capacidad >= p_comensales
    and not exists (
      select 1 from public.reservacion r
      where r.id_mesa = m.id_mesa
        and r.estado in ('pendiente', 'confirmada')
        and (p_excluir is null or r.id_reservacion <> p_excluir)
        and (r.fecha + r.hora) < (p_fecha + p_hora) + interval '2 hours'
        and (r.fecha + r.hora) + interval '2 hours' > (p_fecha + p_hora))
  order by m.capacidad, m.numero_mesa
  limit 1
$$;

create function public.reservacion_validar() returns trigger
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
      if (new.fecha + new.hora) <= public.ahora_local() then
        raise exception 'La fecha y hora de la reservación deben ser futuras';
      end if;
    elsif v_rol not in ('mesero', 'gerente', 'sistema') then
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
      if (new.fecha + new.hora) <= public.ahora_local() then
        raise exception 'La fecha y hora de la reservación deben ser futuras';
      end if;
      new.estado := 'pendiente'; -- hay que volver a confirmar
    end if;
  elsif v_rol not in ('mesero', 'gerente', 'sistema') then
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

create trigger reservacion_validar before insert or update on public.reservacion
  for each row execute function public.reservacion_validar();

-- Reservaciones pendientes que ya están dentro de las últimas 5 horas:
-- la app del cliente muestra "¿Confirmas tu reservación?".
create view public.reservaciones_por_confirmar with (security_invoker = true) as
select r.*
from public.reservacion r
where r.estado = 'pendiente'
  and (r.fecha + r.hora) > public.ahora_local()
  and (r.fecha + r.hora) <= public.ahora_local() + interval '5 hours';

-- ---------------------------------------------------------------------
-- 4. FUNCIONES PARA LA APP (RPC)
-- ---------------------------------------------------------------------

-- Crea un pedido completo en una sola operación. items: [{id_platillo, cantidad, notas_especiales}]
create function public.crear_pedido(p_tipo_pedido text, p_id_mesa bigint, p_items jsonb)
returns bigint
language plpgsql security definer set search_path = public as $$
declare
  v_rol text := public.rol_actual();
  v_folio bigint;
  v_dia int;
  v_item jsonb;
begin
  if v_rol not in ('mesero', 'gerente', 'cliente') then
    raise exception 'No autorizado';
  end if;
  if p_items is null or jsonb_typeof(p_items) <> 'array' or jsonb_array_length(p_items) = 0 then
    raise exception 'El pedido debe tener al menos un platillo';
  end if;
  if v_rol = 'cliente' then
    p_tipo_pedido := 'para_llevar'; -- el cliente solo hace pedidos en línea para llevar
    p_id_mesa := null;
  end if;
  if p_tipo_pedido = 'en_mesa' and p_id_mesa is null then
    raise exception 'Un pedido en mesa requiere la mesa';
  end if;

  perform set_config('app.creando_pedido', '1', true);
  insert into public.pedido (tipo_pedido, id_mesa, origen, id_empleado, id_cliente)
  values (p_tipo_pedido, p_id_mesa,
          case when v_rol = 'cliente' then 'en_linea' else 'mesero' end,
          public.id_empleado_actual(), public.id_cliente_actual())
  returning folio, folio_dia into v_folio, v_dia;

  for v_item in select * from jsonb_array_elements(p_items) loop
    insert into public.detalle_pedido (folio, id_platillo, cantidad, notas_especiales)
    values (v_folio, (v_item ->> 'id_platillo')::bigint, (v_item ->> 'cantidad')::int,
            nullif(v_item ->> 'notas_especiales', ''));
  end loop;
  perform set_config('app.creando_pedido', '', true);

  insert into public.notificacion_cocina (mensaje, tipo_evento, folio)
  values ('Nuevo pedido #' || v_dia, 'nuevo', v_folio);
  return v_folio;
end $$;

-- El mesero ingresa el PIN de un gerente para poder modificar/cancelar un
-- pedido que ya no está "pendiente". La autorización dura 10 minutos.
create function public.autorizar_con_pin(p_folio bigint, p_pin text) returns void
language plpgsql security definer set search_path = public, extensions as $$
declare
  v_gerente bigint;
begin
  if public.rol_actual() not in ('mesero', 'gerente') then
    raise exception 'No autorizado';
  end if;
  select g.id_empleado into v_gerente
  from public.gerente_pin g
  join public.empleado e on e.id_empleado = g.id_empleado and e.activo
  where g.pin_hash = crypt(p_pin, g.pin_hash)
  limit 1;
  if v_gerente is null then
    raise exception 'PIN incorrecto';
  end if;
  perform set_config('app.interno', '1', true);
  update public.pedido
     set autorizado_por = v_gerente, autorizacion_hasta = now() + interval '10 minutes'
   where folio = p_folio;
  perform set_config('app.interno', '', true);
end $$;

-- El gerente define su propio PIN (4 a 6 dígitos).
create function public.establecer_pin(p_pin text) returns void
language plpgsql security definer set search_path = public, extensions as $$
begin
  if public.rol_actual() <> 'gerente' then
    raise exception 'No autorizado';
  end if;
  if p_pin !~ '^[0-9]{4,6}$' then
    raise exception 'El PIN debe tener de 4 a 6 dígitos';
  end if;
  insert into public.gerente_pin (id_empleado, pin_hash)
  values (public.id_empleado_actual(), crypt(p_pin, gen_salt('bf')))
  on conflict (id_empleado) do update set pin_hash = excluded.pin_hash;
end $$;

-- CU-09: descuento o cortesía sobre el pedido completo (solo gerente).
create function public.aplicar_descuento(
  p_folio bigint, p_monto numeric, p_es_cortesia boolean, p_motivo text
) returns void
language plpgsql security definer set search_path = public as $$
declare
  v_suma numeric;
begin
  if public.rol_actual() <> 'gerente' then
    raise exception 'Solo el gerente puede autorizar descuentos o cortesías';
  end if;
  if nullif(btrim(coalesce(p_motivo, '')), '') is null then
    raise exception 'Indica el motivo';
  end if;
  if not p_es_cortesia and (p_monto is null or p_monto < 0) then
    raise exception 'Monto inválido';
  end if;
  if not exists (select 1 from public.pedido where folio = p_folio and estado <> 'cancelado') then
    raise exception 'Pedido no encontrado o cancelado';
  end if;
  select coalesce(sum(subtotal), 0) into v_suma from public.detalle_pedido where folio = p_folio;

  perform set_config('app.interno', '1', true);
  update public.pedido
     set descuento = case when p_es_cortesia then v_suma else least(p_monto, v_suma) end,
         es_cortesia = p_es_cortesia,
         motivo_descuento = p_motivo,
         id_empleado_descuento = public.id_empleado_actual()
   where folio = p_folio;
  update public.pedido set total = public.calcular_total(p_folio) where folio = p_folio;
  perform set_config('app.interno', '', true);
end $$;

-- ---------------------------------------------------------------------
-- 5. BITÁCORA DE AUDITORÍA (RNF-04)
-- ---------------------------------------------------------------------

create function public.auditar() returns trigger
language plpgsql security definer set search_path = public as $$
declare
  v_id text;
begin
  v_id := coalesce(to_jsonb(new) ->> tg_argv[0], to_jsonb(old) ->> tg_argv[0]);
  insert into public.bitacora_auditoria
    (tabla, id_registro, accion, user_id, rol, id_empleado, datos_anteriores, datos_nuevos)
  values (
    tg_table_name, v_id, tg_op, auth.uid(), public.rol_actual(), public.id_empleado_actual(),
    case when tg_op <> 'INSERT' then to_jsonb(old) end,
    case when tg_op <> 'DELETE' then to_jsonb(new) end);
  return null;
end $$;

create trigger auditar after insert or update or delete on public.pedido
  for each row execute function public.auditar('folio');
create trigger auditar after insert or update or delete on public.detalle_pedido
  for each row execute function public.auditar('id_detalle');
create trigger auditar after insert or update or delete on public.reservacion
  for each row execute function public.auditar('id_reservacion');
create trigger auditar after insert or update or delete on public.platillo
  for each row execute function public.auditar('id_platillo');
create trigger auditar after insert or update or delete on public.mesa
  for each row execute function public.auditar('id_mesa');

-- ---------------------------------------------------------------------
-- 6. RLS: activado en TODAS las tablas
-- ---------------------------------------------------------------------

alter table public.empleado            enable row level security;
alter table public.gerente_pin         enable row level security; -- sin políticas: inaccesible por API
alter table public.cliente             enable row level security;
alter table public.mesa                enable row level security;
alter table public.platillo            enable row level security;
alter table public.reservacion         enable row level security;
alter table public.pedido              enable row level security;
alter table public.detalle_pedido      enable row level security;
alter table public.notificacion_cocina enable row level security;
alter table public.merma_cancelacion   enable row level security;
alter table public.bitacora_auditoria  enable row level security;

-- empleado
create policy empleado_select on public.empleado for select to authenticated
  using (public.rol_actual() in ('mesero', 'chef', 'gerente'));
create policy empleado_update on public.empleado for update to authenticated
  using (public.rol_actual() = 'gerente') with check (public.rol_actual() = 'gerente');

-- cliente
create policy cliente_select on public.cliente for select to authenticated
  using (user_id = auth.uid() or public.rol_actual() in ('mesero', 'gerente'));
create policy cliente_insert on public.cliente for insert to authenticated
  with check (public.rol_actual() in ('mesero', 'gerente') and user_id is null);
create policy cliente_update on public.cliente for update to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

-- mesa
create policy mesa_select on public.mesa for select to authenticated
  using (public.rol_actual() in ('mesero', 'chef', 'gerente'));
create policy mesa_update on public.mesa for update to authenticated
  using (public.rol_actual() in ('mesero', 'gerente'))
  with check (public.rol_actual() in ('mesero', 'gerente'));
create policy mesa_insert on public.mesa for insert to authenticated
  with check (public.rol_actual() = 'gerente');
create policy mesa_delete on public.mesa for delete to authenticated
  using (public.rol_actual() = 'gerente');

-- platillo (el menú es público)
create policy platillo_select on public.platillo for select to anon, authenticated
  using (true);
create policy platillo_insert on public.platillo for insert to authenticated
  with check (public.rol_actual() = 'gerente');
create policy platillo_update on public.platillo for update to authenticated
  using (public.rol_actual() = 'gerente') with check (public.rol_actual() = 'gerente');
create policy platillo_delete on public.platillo for delete to authenticated
  using (public.rol_actual() = 'gerente');

-- reservacion
create policy reservacion_select on public.reservacion for select to authenticated
  using (id_cliente = public.id_cliente_actual() or public.rol_actual() in ('mesero', 'gerente'));
create policy reservacion_insert on public.reservacion for insert to authenticated
  with check (id_cliente = public.id_cliente_actual() or public.rol_actual() in ('mesero', 'gerente'));
create policy reservacion_update on public.reservacion for update to authenticated
  using (id_cliente = public.id_cliente_actual() or public.rol_actual() in ('mesero', 'gerente'))
  with check (id_cliente = public.id_cliente_actual() or public.rol_actual() in ('mesero', 'gerente'));

-- pedido (se crea solo con crear_pedido())
create policy pedido_select on public.pedido for select to authenticated
  using (public.rol_actual() in ('mesero', 'chef', 'gerente') or id_cliente = public.id_cliente_actual());
create policy pedido_update on public.pedido for update to authenticated
  using (public.rol_actual() in ('mesero', 'chef', 'gerente') or id_cliente = public.id_cliente_actual())
  with check (public.rol_actual() in ('mesero', 'chef', 'gerente') or id_cliente = public.id_cliente_actual());

-- detalle_pedido
create policy detalle_select on public.detalle_pedido for select to authenticated
  using (exists (select 1 from public.pedido p where p.folio = detalle_pedido.folio));
create policy detalle_insert on public.detalle_pedido for insert to authenticated
  with check (exists (select 1 from public.pedido p where p.folio = detalle_pedido.folio
    and (public.rol_actual() in ('mesero', 'gerente') or p.id_cliente = public.id_cliente_actual())));
create policy detalle_update on public.detalle_pedido for update to authenticated
  using (exists (select 1 from public.pedido p where p.folio = detalle_pedido.folio
    and (public.rol_actual() in ('mesero', 'gerente') or p.id_cliente = public.id_cliente_actual())))
  with check (exists (select 1 from public.pedido p where p.folio = detalle_pedido.folio
    and (public.rol_actual() in ('mesero', 'gerente') or p.id_cliente = public.id_cliente_actual())));
create policy detalle_delete on public.detalle_pedido for delete to authenticated
  using (exists (select 1 from public.pedido p where p.folio = detalle_pedido.folio
    and (public.rol_actual() in ('mesero', 'gerente') or p.id_cliente = public.id_cliente_actual())));

-- notificacion_cocina (las crean los triggers)
create policy notificacion_select on public.notificacion_cocina for select to authenticated
  using (public.rol_actual() in ('mesero', 'chef', 'gerente'));
create policy notificacion_update on public.notificacion_cocina for update to authenticated
  using (public.rol_actual() in ('chef', 'gerente'))
  with check (public.rol_actual() in ('chef', 'gerente'));

-- merma_cancelacion y bitacora: solo lectura para el gerente
create policy merma_select on public.merma_cancelacion for select to authenticated
  using (public.rol_actual() = 'gerente');
create policy bitacora_select on public.bitacora_auditoria for select to authenticated
  using (public.rol_actual() = 'gerente');

-- ---------------------------------------------------------------------
-- 7. PERMISOS
-- ---------------------------------------------------------------------

-- Sin sesión (anon) solo se puede leer el menú.
revoke all on all tables in schema public from anon;
grant select on public.platillo to anon;

-- Nadie desde la API toca el PIN ni escribe directamente en estas tablas.
revoke all on public.gerente_pin from anon, authenticated;
revoke insert, delete on public.pedido from authenticated;
revoke insert, update, delete on public.notificacion_cocina from authenticated;
grant update (atendida) on public.notificacion_cocina to authenticated;
revoke insert, update, delete on public.merma_cancelacion from authenticated;
revoke insert, update, delete on public.bitacora_auditoria from authenticated;
revoke insert, delete on public.empleado from authenticated;

-- Las funciones RPC solo para usuarios con sesión.
revoke execute on function public.crear_pedido(text, bigint, jsonb) from public, anon;
revoke execute on function public.autorizar_con_pin(bigint, text) from public, anon;
revoke execute on function public.establecer_pin(text) from public, anon;
revoke execute on function public.aplicar_descuento(bigint, numeric, boolean, text) from public, anon;
grant execute on function public.crear_pedido(text, bigint, jsonb) to authenticated;
grant execute on function public.autorizar_con_pin(bigint, text) to authenticated;
grant execute on function public.establecer_pin(text) to authenticated;
grant execute on function public.aplicar_descuento(bigint, numeric, boolean, text) to authenticated;

-- ---------------------------------------------------------------------
-- 8. TIEMPO REAL (comandas y avisos de cocina)
-- ---------------------------------------------------------------------

do $$
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    alter publication supabase_realtime add table
      public.pedido, public.detalle_pedido, public.notificacion_cocina, public.reservacion;
  end if;
end $$;
