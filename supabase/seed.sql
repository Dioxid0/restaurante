-- =====================================================================
-- Datos de DESARROLLO LOCAL (se ejecuta con `npx supabase db reset`).
-- NUNCA usar estas credenciales fuera del entorno local.
--
-- Usuarios de prueba (login en la app: usuario + contraseña; internamente
-- el correo es <usuario>@restaurante.local):
--   mesero   / Mesero#2026
--   chef     / Chef#2026
--   gerente  / Gerente#2026
--   cliente@correo.com / Cliente#2026   (cliente; entra con su correo)
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
  (pg_temp.crear_usuario('mesero@restaurante.local',  'Mesero#2026',  'mesero',  'Juan Pérez'),  'Juan Pérez',  'mesero',  'matutino',   'mesero'),
  (pg_temp.crear_usuario('chef@restaurante.local',    'Chef#2026',    'chef',    'Chef'),    'Chef',    'chef',    'matutino',   'chef'),
  (pg_temp.crear_usuario('gerente@restaurante.local', 'Gerente#2026', 'gerente', 'Gerente'), 'Gerente', 'gerente', 'matutino',   'gerente');

insert into public.gerente_pin (id_empleado, pin_hash)
select id_empleado, extensions.crypt('1234', extensions.gen_salt('bf'))
from public.empleado where usuario = 'gerente';

-- Cliente de prueba (el trigger handle_new_user crea su ficha en `cliente`)
select pg_temp.crear_usuario('cliente@correo.com', 'Cliente#2026', null, 'Cliente de Prueba');

-- Meseros adicionales (sin acceso al sistema; solo para datos de demostración)
insert into public.empleado (nombre, rol, turno, usuario) values
  ('Ana López',  'mesero', 'matutino', 'alopez'),
  ('Sofía Ruiz', 'mesero', 'matutino', 'sruiz');

-- Mesas
insert into public.mesa (numero_mesa, capacidad) values
  (1, 2), (2, 2), (3, 4), (4, 4), (5, 4), (6, 6), (7, 6), (8, 8),
  (9, 4), (10, 4), (11, 2), (12, 6);

-- Menú (imagen_url null: la app muestra un ícono por categoría)
insert into public.platillo (nombre, precio, categoria, disponible) values
  ('Enchiladas Verdes',        165.00, 'Platos Fuertes',     true),
  ('Tacos de Arrachera',       148.00, 'Platos Fuertes',     true),
  ('Chilaquiles de la Casa',   142.00, 'Platos Fuertes',     true),
  ('Pollo con Mole',           189.00, 'Platos Fuertes',     true),
  ('Cochinita Pibil',          195.00, 'Especialidades',     true),
  ('Arrachera con Guarnición', 235.00, 'Especialidades',     true),
  ('Guacamole con Totopos',     85.00, 'Antojitos/Entradas', true),
  ('Sopa de Tortilla',          75.00, 'Antojitos/Entradas', true),
  ('Quesadillas',               70.00, 'Antojitos/Entradas', true),
  ('Flan de la Abuela',         89.00, 'Postres',            true),
  ('Pastel de Chocolate',       70.00, 'Postres',            false), -- agotado (para ver ese estado)
  ('Agua de Jamaica',           48.00, 'Bebidas',            true),
  ('Agua de Horchata',          35.00, 'Bebidas',            true),
  ('Refresco',                  30.00, 'Bebidas',            true),
  ('Café Americano',            35.00, 'Bebidas',            true);

-- Pedidos de demostración (para ver la Comandería con datos). Se crean "como sistema",
-- por eso no pasan por las reglas de la API. Las horas son relativas al momento del reset.
create function pg_temp.pid(p_nombre text) returns bigint language sql as $$
  select id_platillo from public.platillo where nombre = p_nombre
$$;

do $$
declare
  v_juan  bigint := (select id_empleado from public.empleado where usuario = 'mesero');
  v_ana   bigint := (select id_empleado from public.empleado where usuario = 'alopez');
  v_sofia bigint := (select id_empleado from public.empleado where usuario = 'sruiz');
  v_folio bigint;
begin
  insert into public.pedido (tipo_pedido, id_mesa, id_empleado, estado, hora_ingreso)
  values ('en_mesa', (select id_mesa from public.mesa where numero_mesa = 12), v_juan, 'listo', now() - interval '24 minutes')
  returning folio into v_folio;
  insert into public.detalle_pedido (folio, id_platillo, cantidad, notas_especiales) values
    (v_folio, pg_temp.pid('Arrachera con Guarnición'), 1, null),
    (v_folio, pg_temp.pid('Agua de Horchata'), 2, null),
    (v_folio, pg_temp.pid('Quesadillas'), 2, 'Sin cebolla');

  insert into public.pedido (tipo_pedido, id_mesa, id_empleado, estado, hora_ingreso)
  values ('en_mesa', (select id_mesa from public.mesa where numero_mesa = 3), v_sofia, 'entregado', now() - interval '32 minutes')
  returning folio into v_folio;
  insert into public.detalle_pedido (folio, id_platillo, cantidad) values
    (v_folio, pg_temp.pid('Enchiladas Verdes'), 2),
    (v_folio, pg_temp.pid('Pollo con Mole'), 2),
    (v_folio, pg_temp.pid('Refresco'), 2);

  insert into public.pedido (tipo_pedido, id_empleado, estado, hora_ingreso)
  values ('para_llevar', v_juan, 'en_preparacion', now() - interval '27 minutes')
  returning folio into v_folio;
  insert into public.detalle_pedido (folio, id_platillo, cantidad) values
    (v_folio, pg_temp.pid('Tacos de Arrachera'), 2),
    (v_folio, pg_temp.pid('Café Americano'), 1);

  insert into public.pedido (tipo_pedido, id_empleado, estado, hora_ingreso)
  values ('para_llevar', v_ana, 'en_preparacion', now() - interval '18 minutes')
  returning folio into v_folio;
  insert into public.detalle_pedido (folio, id_platillo, cantidad) values
    (v_folio, pg_temp.pid('Chilaquiles de la Casa'), 1),
    (v_folio, pg_temp.pid('Guacamole con Totopos'), 1),
    (v_folio, pg_temp.pid('Flan de la Abuela'), 2);

  insert into public.pedido (tipo_pedido, id_mesa, id_empleado, estado, hora_ingreso)
  values ('en_mesa', (select id_mesa from public.mesa where numero_mesa = 1), v_juan, 'pendiente', now() - interval '3 minutes')
  returning folio into v_folio;
  insert into public.detalle_pedido (folio, id_platillo, cantidad, notas_especiales) values
    (v_folio, pg_temp.pid('Enchiladas Verdes'), 2, 'Sin tortilla'),
    (v_folio, pg_temp.pid('Enchiladas Verdes'), 1, null),
    (v_folio, pg_temp.pid('Agua de Jamaica'), 1, null);
end $$;

-- Las notificaciones y la bitácora de arriba son ruido del seed: se limpian.
delete from public.notificacion_cocina;
delete from public.bitacora_auditoria;
