import 'package:freezed_annotation/freezed_annotation.dart';

import 'pedido.dart';

part 'pedido_detalle.freezed.dart';

/// Un renglón a enviar al crear o actualizar un pedido.
@freezed
abstract class ItemPedido with _$ItemPedido {
  const factory ItemPedido({
    required int idPlatillo,
    required int cantidad,

    /// null o vacío => sin nota.
    String? nota,
  }) = _ItemPedido;
}

/// Renglón de un pedido ya guardado.
@freezed
abstract class LineaPedido with _$LineaPedido {
  const factory LineaPedido({
    required int idPlatillo,
    required String nombre,
    required double precioUnitario,
    required int cantidad,
    String? nota,
  }) = _LineaPedido;
}

/// Pedido completo con sus renglones (para editarlo).
@freezed
abstract class PedidoDetalle with _$PedidoDetalle {
  const factory PedidoDetalle({
    required int folio,
    required int folioDia,
    required TipoPedido tipo,
    required EstadoPedido estado,
    required List<LineaPedido> lineas,
    int? idMesa,
  }) = _PedidoDetalle;
}
