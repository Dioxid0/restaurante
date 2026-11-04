-- =====================================================================
-- Cuentas: el gerente crea al personal; los clientes se registran solos.
-- =====================================================================

-- "Juan Pérez" -> "juan.perez". Se usa para armar el correo interno de un empleado
-- (juan.perez@restaurante.local). Debe coincidir con normalizarUsuario() en Dart.
create function public.normalizar_usuario(p text) returns text
language sql immutable as $$
  select trim(both '.' from regexp_replace(
    lower(translate(btrim(p), 'áéíóúüñÁÉÍÓÚÜÑ', 'aeiouunaeiouun')),
    '[^a-z0-9]+', '.', 'g'))
$$;

-- Dos usuarios no pueden normalizarse al mismo correo ("Juan Perez" vs "juan.perez").
create unique index empleado_usuario_normalizado_key
  on public.empleado (public.normalizar_usuario(usuario));

-- Registro abierto = solo clientes. Se endurece el trigger:
--  * los empleados se identifican por app_metadata.rol (no editable por el usuario);
--  * nadie puede registrarse con el dominio interno de empleados.
create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if new.raw_app_meta_data ? 'rol' then
    return new;
  end if;
  if lower(new.email) like '%@restaurante.local' then
    raise exception 'Ese correo no está permitido';
  end if;
  insert into public.cliente (user_id, nombre, telefono, correo)
  values (
    new.id,
    coalesce(nullif(btrim(new.raw_user_meta_data ->> 'nombre'), ''), split_part(new.email, '@', 1)),
    nullif(btrim(new.raw_user_meta_data ->> 'telefono'), ''),
    new.email);
  return new;
end $$;

-- Solo el gerente crea cuentas de personal (mesero, chef, gerente).
create function public.crear_empleado(
  p_nombre text, p_usuario text, p_password text, p_rol text,
  p_turno text default null, p_pin text default null
) returns bigint
language plpgsql security definer set search_path = public, extensions as $$
declare
  v_id uuid := gen_random_uuid();
  v_normal text;
  v_email text;
  v_empleado bigint;
begin
  if public.rol_actual() <> 'gerente' then
    raise exception 'Solo el gerente puede crear cuentas';
  end if;
  if p_rol not in ('mesero', 'chef', 'gerente') then
    raise exception 'Rol inválido';
  end if;
  p_nombre := btrim(coalesce(p_nombre, ''));
  p_usuario := btrim(coalesce(p_usuario, ''));
  if p_nombre = '' then
    raise exception 'Indica el nombre';
  end if;
  if p_usuario like '%@%' then
    raise exception 'El usuario no puede ser un correo electrónico';
  end if;
  v_normal := public.normalizar_usuario(p_usuario);
  if length(v_normal) < 3 then
    raise exception 'El usuario debe tener al menos 3 letras o números';
  end if;
  if length(coalesce(p_password, '')) < 8 then
    raise exception 'La contraseña debe tener al menos 8 caracteres';
  end if;
  if p_pin is not null and (p_rol <> 'gerente' or p_pin !~ '^[0-9]{4,6}$') then
    raise exception 'El PIN es solo para gerentes y debe tener de 4 a 6 dígitos';
  end if;

  v_email := v_normal || '@restaurante.local';
  if exists (select 1 from auth.users where lower(email) = v_email)
     or exists (select 1 from public.empleado where public.normalizar_usuario(usuario) = v_normal) then
    raise exception 'Ese usuario ya existe';
  end if;

  insert into auth.users (
    instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
    confirmation_token, recovery_token, email_change_token_new, email_change)
  values (
    '00000000-0000-0000-0000-000000000000', v_id, 'authenticated', 'authenticated',
    v_email, crypt(p_password, gen_salt('bf')), now(),
    jsonb_build_object('provider', 'email', 'providers', jsonb_build_array('email'), 'rol', p_rol),
    jsonb_build_object('nombre', p_nombre), now(), now(), '', '', '', '');

  insert into auth.identities (
    id, user_id, provider_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
  values (
    gen_random_uuid(), v_id, v_id::text,
    jsonb_build_object('sub', v_id::text, 'email', v_email, 'email_verified', true),
    'email', now(), now(), now());

  insert into public.empleado (user_id, nombre, rol, turno, usuario)
  values (v_id, p_nombre, p_rol, nullif(btrim(coalesce(p_turno, '')), ''), p_usuario)
  returning id_empleado into v_empleado;

  if p_pin is not null then
    insert into public.gerente_pin (id_empleado, pin_hash)
    values (v_empleado, crypt(p_pin, gen_salt('bf')));
  end if;
  return v_empleado;
end $$;

revoke execute on function public.crear_empleado(text, text, text, text, text, text) from public, anon;
grant execute on function public.crear_empleado(text, text, text, text, text, text) to authenticated;

-- Auditoría de cuentas de personal (RNF-04)
create trigger auditar after insert or update or delete on public.empleado
  for each row execute function public.auditar('id_empleado');
