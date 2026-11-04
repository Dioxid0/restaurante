-- =====================================================================
-- Pantalla de comanda: imagen del platillo, categorías, mesa automática
-- y edición atómica de pedidos.
-- =====================================================================

-- 1. Imagen y categorías del menú -------------------------------------
alter table public.platillo add column imagen_url text; -- null => la app muestra un ícono

update public.platillo set categoria = case categoria
  when 'Entradas' then 'Antojitos/Entradas'
  when 'Platos fuertes' then 'Platos Fuertes'
  else categoria end;

alter table public.platillo add constraint platillo_categoria_check
  check (categoria in ('Bebidas', 'Antojitos/Entradas', 'Platos Fuertes', 'Postres', 'Especialidades'));

alter table public.detalle_pedido add constraint detalle_nota_largo
  check (notas_especiales is null or char_length(notas_especiales) <= 200);

-- 2. La mesa se ocupa y se libera sola ---------------------------------
-- Una mesa está "ocupada" mientras tenga algún pedido en mesa activo
-- (pendiente, en preparación, listo o entregado). Cuando todos quedan
-- completados o cancelados, vuelve a "libre". Los pedidos "para llevar"
-- no ocupan la mesa.
create function public.sincronizar_mesa(p_id_mesa bigint) returns void
language plpgsql security definer set search_path = public as $$
declare
  v_estado text;
begin
  if p_id_mesa is null then
    return;
  end if;
  v_estado := case when exists (
      select 1 from public.pedido p
      where p.id_mesa = p_id_mesa
        and p.tipo_pedido = 'en_mesa'
        and p.estado in ('pendiente', 'en_preparacion', 'listo', 'entregado'))
    then 'ocupada' else 'libre' end;
  update public.mesa set estado = v_estado
   where id_mesa = p_id_mesa and estado is distinct from v_estado;
end $$;

create function public.pedido_sincroniza_mesa() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if tg_op = 'UPDATE' and old.id_mesa is distinct from new.id_mesa then
    perform public.sincronizar_mesa(old.id_mesa);
  end if;
  perform public.sincronizar_mesa(new.id_mesa);
  return null;
end $$;

create trigger pedido_sincroniza_mesa after insert or update on public.pedido
  for each row execute function public.pedido_sincroniza_mesa();

-- Pedidos que ya existían
select public.sincronizar_mesa(id_mesa) from (
  select distinct id_mesa from public.pedido where id_mesa is not null) x;

-- 3. Editar un pedido completo en una sola operación -------------------
-- Reemplaza los renglones y cambia tipo/mesa; avisa UNA vez a cocina.
-- p_items: [{id_platillo, cantidad, notas_especiales}]
create function public.actualizar_pedido(
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
      raise exception 'Se requiere el PIN del gerente';
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

revoke execute on function public.actualizar_pedido(bigint, text, bigint, jsonb) from public, anon;
grant execute on function public.actualizar_pedido(bigint, text, bigint, jsonb) to authenticated;
