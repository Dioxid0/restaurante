-- Gerencia: administración de personal, menú y mesas + consulta de la bitácora.

-- ---------------------------------------------------------------------
-- 1. Personal: el gerente solo puede activar/desactivar por la API;
--    el nombre, turno y rol se cambian con editar_empleado().
--    (Antes un gerente podía cambiar usuario, user_id o rol con un UPDATE directo.)
-- ---------------------------------------------------------------------

revoke update on public.empleado from authenticated;
grant update (activo) on public.empleado to authenticated;

create function public.empleado_proteger() returns trigger
language plpgsql as $$
begin
  if public.es_sistema() then
    return new;
  end if;
  if old.id_empleado = public.id_empleado_actual()
     and (new.activo is distinct from old.activo or new.rol is distinct from old.rol) then
    raise exception 'No puedes desactivar tu propia cuenta ni cambiar tu propio rol';
  end if;
  if old.rol = 'gerente' and old.activo
     and (not new.activo or new.rol <> 'gerente')
     and not exists (select 1 from public.empleado e
                      where e.rol = 'gerente' and e.activo and e.id_empleado <> old.id_empleado) then
    raise exception 'Debe quedar al menos un gerente activo';
  end if;
  return new;
end $$;

create trigger empleado_proteger before update on public.empleado
  for each row execute function public.empleado_proteger();

create function public.editar_empleado(
  p_id bigint, p_nombre text, p_turno text, p_rol text
) returns void
language plpgsql security definer set search_path = public as $$
declare
  v_user uuid;
begin
  if public.rol_actual() is distinct from 'gerente' then
    raise exception 'Solo el gerente puede editar cuentas';
  end if;
  p_nombre := btrim(coalesce(p_nombre, ''));
  p_turno := nullif(btrim(coalesce(p_turno, '')), '');
  if p_nombre = '' then
    raise exception 'Indica el nombre';
  end if;
  if p_rol not in ('mesero', 'chef', 'gerente') then
    raise exception 'Rol inválido';
  end if;
  update public.empleado
     set nombre = p_nombre, turno = p_turno, rol = p_rol
   where id_empleado = p_id
  returning user_id into v_user;
  if not found then
    raise exception 'La cuenta no existe';
  end if;
  -- El rol también viaja en app_metadata (como lo escribe crear_empleado).
  if v_user is not null then
    update auth.users
       set raw_app_meta_data = jsonb_set(coalesce(raw_app_meta_data, '{}'::jsonb), '{rol}', to_jsonb(p_rol))
     where id = v_user;
  end if;
end $$;

revoke execute on function public.editar_empleado(bigint, text, text, text) from public, anon;
grant execute on function public.editar_empleado(bigint, text, text, text) to authenticated;

-- ---------------------------------------------------------------------
-- 2. Menú y mesas: datos válidos (los permisos ya estaban: solo el gerente
--    inserta, edita y borra; un platillo o mesa con pedidos no se puede borrar).
-- ---------------------------------------------------------------------

alter table public.platillo add constraint platillo_nombre_no_vacio check (btrim(nombre) <> '');
create unique index platillo_nombre_key on public.platillo (lower(btrim(nombre)));
alter table public.mesa add constraint mesa_numero_positivo check (numero_mesa > 0);

-- ---------------------------------------------------------------------
-- 3. Bitácora de auditoría (RNF-04): lectura para el gerente, con el nombre de
--    quien hizo el cambio y qué campos cambiaron.
-- ---------------------------------------------------------------------

create function public.bitacora_gerencial(p_tabla text default null, p_limite int default 100)
returns jsonb
language plpgsql stable security definer set search_path = public as $$
begin
  if public.rol_actual() is distinct from 'gerente' then
    raise exception 'Solo el gerente puede ver la bitácora';
  end if;
  p_limite := least(greatest(coalesce(p_limite, 100), 1), 200);

  return coalesce((
    select jsonb_agg(jsonb_build_object(
             'id', x.id_bitacora,
             'fecha_hora', x.fecha_hora,
             'tabla', x.tabla,
             'id_registro', x.id_registro,
             'accion', x.accion,
             'rol', x.rol,
             'empleado', x.nombre,
             'cambios', x.cambios) order by x.fecha_hora desc, x.id_bitacora desc)
    from (
      select b.id_bitacora, b.fecha_hora, b.tabla, b.id_registro, b.accion, b.rol, e.nombre,
             case b.accion
               when 'UPDATE' then (
                 select coalesce(jsonb_object_agg(k, jsonb_build_object(
                          'antes', b.datos_anteriores -> k, 'despues', b.datos_nuevos -> k)), '{}'::jsonb)
                 from jsonb_object_keys(b.datos_nuevos) k
                 where b.datos_anteriores -> k is distinct from b.datos_nuevos -> k)
               when 'INSERT' then b.datos_nuevos
               else b.datos_anteriores
             end as cambios
      from public.bitacora_auditoria b
      left join public.empleado e on e.id_empleado = b.id_empleado
      where p_tabla is null or b.tabla = p_tabla
      order by b.fecha_hora desc, b.id_bitacora desc
      limit p_limite) x), '[]'::jsonb);
end $$;

revoke execute on function public.bitacora_gerencial(text, int) from public, anon;
grant execute on function public.bitacora_gerencial(text, int) to authenticated;
