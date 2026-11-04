-- =====================================================================
-- Datos de DESARROLLO LOCAL (se ejecuta con `npx supabase db reset`).
-- NUNCA usar estas credenciales fuera del entorno local.
--
-- Usuarios de prueba (login en la app: usuario + contraseña; internamente
-- el correo es <usuario>@restaurante.local):
--   mesero   / Mesero#2026
--   chef     / Chef#2026
--   gerente  / Gerente#2026   (PIN del gerente: 1234)
--   cliente  / Cliente#2026   (cliente@restaurante.local)
-- =====================================================================

create function pg_temp.crear_usuario(
  p_email text, p_password text, p_rol text, p_nombre text
) returns uuid language plpgsql as $$
declare
  v_id uuid := gen_random_uuid();
begin
  insert into auth.users (
    instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
    confirmation_token, recovery_token, email_change_token_new, email_change)
  values (
    '00000000-0000-0000-0000-000000000000', v_id, 'authenticated', 'authenticated',
    p_email, extensions.crypt(p_password, extensions.gen_salt('bf')), now(),
    jsonb_build_object('provider', 'email', 'providers', jsonb_build_array('email'))
      || case when p_rol is not null then jsonb_build_object('rol', p_rol) else '{}'::jsonb end,
    jsonb_build_object('nombre', p_nombre), now(), now(), '', '', '', '');

  insert into auth.identities (
    id, user_id, provider_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
  values (
    gen_random_uuid(), v_id, v_id::text,
    jsonb_build_object('sub', v_id::text, 'email', p_email, 'email_verified', true),
    'email', now(), now(), now());
  return v_id;
end $$;

-- Empleados
insert into public.empleado (user_id, nombre, rol, turno, usuario) values
  (pg_temp.crear_usuario('mesero@restaurante.local',  'Mesero#2026',  'mesero',  'Mesero'),  'Mesero',  'mesero',  'matutino',   'mesero'),
  (pg_temp.crear_usuario('chef@restaurante.local',    'Chef#2026',    'chef',    'Chef'),    'Chef',    'chef',    'matutino',   'chef'),
  (pg_temp.crear_usuario('gerente@restaurante.local', 'Gerente#2026', 'gerente', 'Gerente'), 'Gerente', 'gerente', 'matutino',   'gerente');

insert into public.gerente_pin (id_empleado, pin_hash)
select id_empleado, extensions.crypt('1234', extensions.gen_salt('bf'))
from public.empleado where usuario = 'gerente';

-- Cliente de prueba (el trigger handle_new_user crea su ficha en `cliente`)
select pg_temp.crear_usuario('cliente@restaurante.local', 'Cliente#2026', null, 'Cliente de Prueba');

-- Mesas
insert into public.mesa (numero_mesa, capacidad) values
  (1, 2), (2, 2), (3, 4), (4, 4), (5, 4), (6, 6), (7, 6), (8, 8);

-- Menú
insert into public.platillo (nombre, precio, categoria) values
  ('Guacamole con totopos',   85.00, 'Entradas'),
  ('Sopa de tortilla',        75.00, 'Entradas'),
  ('Quesadillas',             70.00, 'Entradas'),
  ('Tacos al pastor (orden)', 120.00, 'Platos fuertes'),
  ('Enchiladas verdes',       135.00, 'Platos fuertes'),
  ('Arrachera con guarnición', 235.00, 'Platos fuertes'),
  ('Pollo en mole',           150.00, 'Platos fuertes'),
  ('Flan napolitano',         60.00, 'Postres'),
  ('Pastel de chocolate',     70.00, 'Postres'),
  ('Agua de horchata',        35.00, 'Bebidas'),
  ('Refresco',                30.00, 'Bebidas'),
  ('Café americano',          35.00, 'Bebidas');
