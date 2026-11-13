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
  const LineaPedido._();

  const factory LineaPedido({
    required int idPlatillo,
    required String nombre,
    required double precioUnitario,
    required int cantidad,
    String? nota,
  }) = _LineaPedido;

  double get importe => precioUnitario * cantidad;
}

/// Pedido completo con sus renglones (para editarlo o consultarlo).
@freezed
abstract class PedidoDetalle with _$PedidoDetalle {
  const PedidoDetalle._();

  const factory PedidoDetalle({
    required int folio,
    required int folioDia,
    required TipoPedido tipo,
    required EstadoPedido estado,
    required List<LineaPedido> lineas,
    int? idMesa,
    int? numeroMesa,
    String? nombreMesero,
    String? nombreCliente,
    @Default(false) bool esEnLinea,
    @Default(0.0) double total,
    @Default(0.0) double descuento,
    @Default(false) bool esCortesia,
    String? motivoDescuento,
  }) = _PedidoDetalle;

  String get folioEtiqueta => '#PED-${folioDia.toString().padLeft(3, '0')}';

  /// Lo que costaba el pedido antes del descuento o la cortesía (con IVA incluido).
  /// En una cortesía el total es 0 y el descuento guarda el importe completo.
  double get totalSinDescuento => total + descuento;

  String? get mesaEtiqueta =>
      numeroMesa == null ? null : 'M-${numeroMesa.toString().padLeft(2, '0')}';
}
