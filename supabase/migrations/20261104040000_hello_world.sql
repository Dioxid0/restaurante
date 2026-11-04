-- Tabla de prueba para verificar el entorno (app -> Supabase -> RLS).
-- Se puede eliminar más adelante con una nueva migración (drop table public.hello_check).
create table public.hello_check (
  id bigint generated always as identity primary key,
  message text not null
);

alter table public.hello_check enable row level security;

create policy "hello_check lectura publica"
  on public.hello_check for select
  to anon, authenticated
  using (true);

insert into public.hello_check (message) values ('¡Hola desde Supabase local!');
