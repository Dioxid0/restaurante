-- =====================================================================
-- Esquema inicial: Restaurante "El Buen Sabor"
-- Basado en el modelo E-R (docs/modelo-er.webp) y los casos de uso
-- (docs/casos-de-uso.webp). Decisiones y reglas: docs/dominio.md
-- Convenciones: snake_case, singular, RLS activado en TODAS las tablas.
-- =====================================================================

create extension if not exists pgcrypto with schema extensions;

-- Zona horaria del restaurante (el "día" del restaurante no es el día UTC)
create function public.hoy_local() returns date
language sql stable as $$ select (now() at time zone 'America/Mexico_City')::date $$;

create function public.ahora_local() returns timestamp
language sql stable as $$ select now() at time zone 'America/Mexico_City' $$;

-- ---------------------------------------------------------------------
-- 1. TABLAS
-- ---------------------------------------------------------------------

create table public.empleado (
  id_empleado bigint generated always as identity primary key,
  user_id     uuid unique references auth.users (id) on delete set null,
  nombre      text not null,
  rol         text not null check (rol in ('mesero', 'chef', 'gerente')),
  turno       text,
  usuario     text not null unique,
  activo      boolean not null default true
);

-- El PIN del gerente vive aparte: ningún cliente de la API puede leerlo.
create table public.gerente_pin (
  id_empleado bigint primary key references public.empleado (id_empleado) on delete cascade,
  pin_hash    text not null
);

create table public.cliente (
  id_cliente bigint generated always as identity primary key,
  user_id    uuid unique references auth.users (id) on delete cascade,
  nombre     text not null,
  telefono   text,
  correo     text
);

create table public.mesa (
  id_mesa     bigint generated always as identity primary key,
  numero_mesa int not null unique,
  capacidad   int not null check (capacidad > 0),
  estado      text not null default 'libre' check (estado in ('libre', 'ocupada', 'reservada'))
);

create table public.platillo (
  id_platillo bigint generated always as identity primary key,
  nombre      text not null,
  precio      numeric(10, 2) not null check (precio >= 0),
  categoria   text not null,
  disponible  boolean not null default true
);

create table public.reservacion (
  id_reservacion bigint generated always as identity primary key,
  fecha          date not null,
  hora           time not null,
  num_comensales int not null check (num_comensales > 0),
  estado         text not null default 'pendiente'
                 check (estado in ('pendiente', 'confirmada', 'cancelada', 'completada')),
  id_cliente     bigint not null references public.cliente (id_cliente),
  id_mesa        bigint not null references public.mesa (id_mesa) -- la asigna el sistema
);

create table public.pedido (
  folio              bigint generated always as identity primary key, -- folio global
  folio_dia          int not null,                                    -- folio que ven mesero y chef
  fecha_operativa    date not null default public.hoy_local(),
  hora_ingreso       timestamptz not null default now(),
  tipo_pedido        text not null check (tipo_pedido in ('en_mesa', 'para_llevar')),
  origen             text not null default 'mesero' check (origen in ('mesero', 'en_linea')),
  estado             text not null default 'pendiente'
                     check (estado in ('pendiente', 'en_preparacion', 'listo', 'entregado', 'completado', 'cancelado')),
  total              numeric(10, 2) not null default 0,
  -- Descuento / cortesía (CU-09): solo informativo para el reporte gerencial
  descuento          numeric(10, 2) not null default 0 check (descuento >= 0),
  es_cortesia        boolean not null default false,
  motivo_descuento   text,
  id_empleado_descuento bigint references public.empleado (id_empleado),
  -- Cancelación (RN-03)
  motivo_cancelacion text,
  -- Autorización temporal con PIN del gerente (RN-03)
  autorizado_por     bigint references public.empleado (id_empleado),
  autorizacion_hasta timestamptz,
  id_empleado        bigint references public.empleado (id_empleado),
  id_cliente         bigint references public.cliente (id_cliente),
  id_mesa            bigint references public.mesa (id_mesa),
  unique (fecha_operativa, folio_dia),
  check (tipo_pedido <> 'en_mesa' or id_mesa is not null)
);

create table public.detalle_pedido (
  id_detalle       bigint generated always as identity primary key,
  folio            bigint not null references public.pedido (folio) on delete cascade,
  id_platillo      bigint not null references public.platillo (id_platillo),
  cantidad         int not null check (cantidad > 0),
  precio_unitario  numeric(10, 2) not null, -- precio al momento del pedido
  subtotal         numeric(10, 2) not null,
  notas_especiales text
);

create table public.notificacion_cocina (
  id_notificacion bigint generated always as identity primary key,
  hora_emision    timestamptz not null default now(),
  mensaje         text not null,
  tipo_evento     text not null check (tipo_evento in ('nuevo', 'modificado', 'cancelado')),
  atendida        boolean not null default false,
  folio           bigint not null references public.pedido (folio) on delete cascade
);

create table public.merma_cancelacion (
  id_merma             bigint generated always as identity primary key,
  fecha_hora           timestamptz not null default now(),
  tipo                 text not null default 'cancelacion' check (tipo in ('cancelacion', 'merma')),
  motivo               text not null,
  costo_perdida        numeric(10, 2) not null default 0,
  folio                bigint not null unique references public.pedido (folio),
  id_empleado_solicita bigint references public.empleado (id_empleado), -- null si cancela el cliente
  id_empleado_autoriza bigint references public.empleado (id_empleado), -- null si no requirió autorización
  cancelado_por        text check (cancelado_por in ('cliente', 'mesero', 'gerente'))
);

-- RNF-04: bitácora de auditoría (quién registró / modificó)
create table public.bitacora_auditoria (
  id_bitacora      bigint generated always as identity primary key,
  fecha_hora       timestamptz not null default now(),
  tabla            text not null,
  id_registro      text,
  accion           text not null,
  user_id          uuid,
  rol              text,
  id_empleado      bigint,
  datos_anteriores jsonb,
  datos_nuevos     jsonb
);
create index on public.bitacora_auditoria (tabla, fecha_hora desc);

-- Índices útiles
create index on public.pedido (fecha_operativa, estado);
create index on public.detalle_pedido (folio);
create index on public.reservacion (fecha, hora);
create index on public.notificacion_cocina (atendida, hora_emision desc);
