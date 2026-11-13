import '../entities/pedido.dart';
import '../entities/pedido_detalle.dart';

abstract interface class PedidoRepository {
  /// Pedidos de la fecha operativa de hoy (todos los estados), más recientes primero.
  Future<List<PedidoResumen>> pedidosDelDia();

  /// Emite un evento cada vez que cambia algún pedido (tiempo real).
  Stream<void> cambios();

  Future<void> actualizarEstado(int folio, EstadoPedido nuevoEstado);

  /// Crea el pedido completo (renglones incluidos). Devuelve el folio global.
  /// Lanza [ErrorDeNegocio] con el motivo si la base lo rechaza.
  Future<int> crearPedido({
    required TipoPedido tipo,
    required List<ItemPedido> items,
    int? idMesa,
  });

  Future<PedidoDetalle> obtenerPedido(int folio);

  /// Reemplaza renglones, tipo y mesa de un pedido existente (y avisa a cocina).
  Future<void> actualizarPedido({
    required int folio,
    required TipoPedido tipo,
    required List<ItemPedido> items,
    int? idMesa,
  });

  /// Cancela el pedido (el motivo es obligatorio).
  Future<void> cancelarPedido(int folio, String motivo);

  /// CU-09 (solo gerente): descuento de [monto] sobre el pedido completo, o cortesía (el pedido
  /// queda en 0). Un monto de 0 sin cortesía retira el descuento. El motivo es obligatorio.
  Future<void> aplicarDescuento({
    required int folio,
    required double monto,
    required bool esCortesia,
    required String motivo,
  });
}
