-- El gerente supervisa, no toma pedidos: solo el mesero (en mesa o para llevar)
-- y el cliente (en línea) crean pedidos. Es la misma función de siempre con un
-- único cambio: se quita 'gerente' de los roles autorizados.
-- El gerente sigue pudiendo editar y cancelar pedidos (RN-03) con actualizar_pedido.
create or replace function public.crear_pedido(p_tipo_pedido text, p_id_mesa bigint, p_items jsonb)
returns bigint
language plpgsql security definer set search_path = public as $$
declare
  v_rol text := public.rol_actual();
  v_folio bigint;
  v_dia int;
  v_item jsonb;
begin
  if v_rol not in ('mesero', 'cliente') then
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
