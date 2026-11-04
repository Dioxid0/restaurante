import 'package:freezed_annotation/freezed_annotation.dart';

part 'pedido.freezed.dart';

enum EstadoPedido {
  pendiente('pendiente', 'Pendiente'),
  enPreparacion('en_preparacion', 'En Preparación'),
  listo('listo', 'Listo'),
  entregado('entregado', 'Entregado'),
  completado('completado', 'Completado'),
  cancelado('cancelado', 'Cancelado');

  const EstadoPedido(this.valorBd, this.etiqueta);
  final String valorBd;
  final String etiqueta;

  /// Pedidos que siguen en operación (no cerrados).
  bool get esActivo => this != completado && this != cancelado;

  static EstadoPedido desdeBd(String valor) =>
      EstadoPedido.values.firstWhere((e) => e.valorBd == valor);
}

enum TipoPedido {
  enMesa('en_mesa', 'Presencial · Comer aquí'),
  paraLlevar('para_llevar', 'Para Llevar · Recoger');

  const TipoPedido(this.valorBd, this.descripcion);
  final String valorBd;
  final String descripcion;

  static TipoPedido desdeBd(String valor) =>
      TipoPedido.values.firstWhere((t) => t.valorBd == valor);
}

/// Fila de la lista de comandas.
@freezed
abstract class PedidoResumen with _$PedidoResumen {
  const PedidoResumen._();

  const factory PedidoResumen({
    required int folio,
    required int folioDia,
    required DateTime horaIngreso,
    required TipoPedido tipo,
    required EstadoPedido estado,
    required double total,
    required bool esEnLinea,
    int? numeroMesa,
    String? nombreMesero,
  }) = _PedidoResumen;

  /// Folio visible para mesero y chef: #PED-108
  String get folioEtiqueta => '#PED-${folioDia.toString().padLeft(3, '0')}';

  /// M-01 (o null si no tiene mesa)
  String? get mesaEtiqueta =>
      numeroMesa == null ? null : 'M-${numeroMesa.toString().padLeft(2, '0')}';
}
