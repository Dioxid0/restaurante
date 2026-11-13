-- CU-07 Reporte gerencial: ventas, pedidos, platillos, cancelaciones y descuentos
-- de un rango de fechas operativas. Solo lo puede pedir el gerente.
-- "Venta" = pedido no cancelado (cobros/caja están fuera de alcance).

create or replace function public.reporte_gerencial(p_desde date, p_hasta date)
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_res jsonb;
begin
  if public.rol_actual() is distinct from 'gerente' then
    raise exception 'Solo el gerente puede ver el reporte';
  end if;
  if p_desde is null or p_hasta is null or p_desde > p_hasta then
    raise exception 'Rango de fechas no válido';
  end if;
  if p_hasta - p_desde > 366 then
    raise exception 'El rango no puede ser mayor a un año';
  end if;

  with p as (
    select * from public.pedido where fecha_operativa between p_desde and p_hasta
  ),
  v as (select * from p where estado <> 'cancelado'),
  dsc as (
    select v.folio_dia, v.es_cortesia, v.motivo_descuento,
           case when v.es_cortesia
                then coalesce(nullif(v.descuento, 0),
                              (select coalesce(sum(d.subtotal), 0) from public.detalle_pedido d where d.folio = v.folio))
                else v.descuento end as monto,
           v.fecha_operativa, v.folio
    from v
    where v.es_cortesia or v.descuento > 0
  )
  select jsonb_build_object(
    'desde', p_desde,
    'hasta', p_hasta,
    'pedidos_total', (select count(*) from p),
    'pedidos_validos', (select count(*) from v),
    'ventas', (select coalesce(sum(total), 0) from v),
    'ventas_brutas', (select coalesce(sum(total + descuento), 0) from v),
    'ticket_promedio', (select coalesce(round(avg(total), 2), 0) from v),
    'por_estado', (
      select coalesce(jsonb_object_agg(estado, n), '{}'::jsonb)
      from (select estado, count(*) n from p group by estado) e),
    'por_tipo', (
      select coalesce(jsonb_agg(jsonb_build_object('clave', tipo_pedido, 'pedidos', n, 'ventas', s) order by tipo_pedido), '[]'::jsonb)
      from (select tipo_pedido, count(*) n, sum(total) s from v group by tipo_pedido) t),
    'por_origen', (
      select coalesce(jsonb_agg(jsonb_build_object('clave', origen, 'pedidos', n, 'ventas', s) order by origen), '[]'::jsonb)
      from (select origen, count(*) n, sum(total) s from v group by origen) t),
    'top_platillos', (
      select coalesce(jsonb_agg(jsonb_build_object('nombre', nombre, 'cantidad', cant, 'importe', imp) order by cant desc, imp desc, nombre), '[]'::jsonb)
      from (
        select pl.nombre, sum(d.cantidad)::int cant, sum(d.subtotal) imp
        from public.detalle_pedido d
        join v on v.folio = d.folio
        join public.platillo pl on pl.id_platillo = d.id_platillo
        group by pl.nombre
        order by sum(d.cantidad) desc, sum(d.subtotal) desc, pl.nombre
        limit 5) x),
    'por_dia', (
      select coalesce(jsonb_agg(jsonb_build_object('fecha', fecha_operativa, 'pedidos', n, 'ventas', s) order by fecha_operativa), '[]'::jsonb)
      from (select fecha_operativa, count(*) n, sum(total) s from v group by fecha_operativa) t),
    'cancelaciones', jsonb_build_object(
      'cantidad', (select count(*) from public.merma_cancelacion m join p on p.folio = m.folio),
      'perdida', (select coalesce(sum(m.costo_perdida), 0) from public.merma_cancelacion m join p on p.folio = m.folio),
      'lista', (
        select coalesce(jsonb_agg(jsonb_build_object(
                 'folio_dia', folio_dia, 'fecha', fecha_operativa, 'motivo', motivo,
                 'costo_perdida', costo_perdida, 'cancelado_por', cancelado_por) order by fh desc), '[]'::jsonb)
        from (
          select p.folio_dia, p.fecha_operativa, m.motivo, m.costo_perdida, m.cancelado_por, m.fecha_hora fh
          from public.merma_cancelacion m join p on p.folio = m.folio
          order by m.fecha_hora desc limit 10) c)),
    'descuentos', jsonb_build_object(
      'descuentos', jsonb_build_object(
        'pedidos', (select count(*) from dsc where not es_cortesia),
        'monto', (select coalesce(sum(monto), 0) from dsc where not es_cortesia)),
      'cortesias', jsonb_build_object(
        'pedidos', (select count(*) from dsc where es_cortesia),
        'monto', (select coalesce(sum(monto), 0) from dsc where es_cortesia)),
      'lista', (
        select coalesce(jsonb_agg(jsonb_build_object(
                 'folio_dia', folio_dia, 'fecha', fecha_operativa, 'es_cortesia', es_cortesia,
                 'monto', monto, 'motivo', motivo_descuento) order by folio desc), '[]'::jsonb)
        from (select * from dsc order by folio desc limit 10) l))
  ) into v_res;

  return v_res;
end;
$$;

revoke execute on function public.reporte_gerencial(date, date) from public, anon;
grant execute on function public.reporte_gerencial(date, date) to authenticated;
