import 'package:freezed_annotation/freezed_annotation.dart';

import 'pedido.dart';

part 'cocina.freezed.dart';

/// Un platillo del pedido tal como lo ve la cocina (sin precios).
@freezed
abstract class RenglonCocina with _$RenglonCocina {
  const factory RenglonCocina({
    required String nombre,
    required int cantidad,
    String? nota,
  }) = _RenglonCocina;
}

/// Pedido activo en el tablero de cocina (CU-03): pendiente, en preparación o listo.
@freezed
abstract class PedidoCocina with _$PedidoCocina {
  const PedidoCocina._();

  const factory PedidoCocina({
    required int folio,
    required int folioDia,
    required DateTime horaIngreso,
    required TipoPedido tipo,
    required EstadoPedido estado,
    required bool esEnLinea,
    int? numeroMesa,
    @Default(<RenglonCocina>[]) List<RenglonCocina> renglones,
  }) = _PedidoCocina;

  /// #PED-108
  String get folioEtiqueta => '#PED-${folioDia.toString().padLeft(3, '0')}';

  /// M-01 (o null si no tiene mesa)
  String? get mesaEtiqueta =>
      numeroMesa == null ? null : 'M-${numeroMesa.toString().padLeft(2, '0')}';

  /// Cantidad total de platillos (suma de las cantidades).
  int get totalPlatillos => renglones.fold(0, (suma, r) => suma + r.cantidad);
}

enum TipoAviso {
  nuevo('nuevo'),
  modificado('modificado'),
  cancelado('cancelado');

  const TipoAviso(this.valorBd);
  final String valorBd;

  static TipoAviso desdeBd(String valor) =>
      TipoAviso.values.firstWhere((t) => t.valorBd == valor);
}

/// Aviso a cocina (CU-06): pedido nuevo, modificado o cancelado.
@freezed
abstract class AvisoCocina with _$AvisoCocina {
  const factory AvisoCocina({
    required int idNotificacion,
    required DateTime hora,
    required String mensaje,
    required TipoAviso tipo,
    required int folio,
  }) = _AvisoCocina;
}
