import '../entities/pedido.dart';

abstract interface class PedidoRepository {
  /// Pedidos de la fecha operativa de hoy (todos los estados), más recientes primero.
  Future<List<PedidoResumen>> pedidosDelDia();

  /// Emite un evento cada vez que cambia algún pedido (tiempo real).
  Stream<void> cambios();

  Future<void> actualizarEstado(int folio, EstadoPedido nuevoEstado);
}
