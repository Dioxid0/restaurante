import '../entities/cocina.dart';

/// Lo que necesita la pantalla de Cocina. Para cambiar el estado de un pedido
/// (pendiente → en preparación → listo) se usa `PedidoRepository.actualizarEstado`;
/// la base valida que el chef solo pueda hacer esas dos transiciones.
abstract interface class CocinaRepository {
  /// Pedidos de hoy en estado pendiente, en preparación o listo, con sus platillos.
  /// Los más antiguos primero.
  Future<List<PedidoCocina>> pedidos();

  /// Avisos que cocina todavía no ha marcado como atendidos (los más recientes primero).
  Future<List<AvisoCocina>> avisosPendientes();

  /// Emite un evento cuando cambia un pedido o llega un aviso (tiempo real).
  Stream<void> cambios();

  Future<void> marcarAtendido(int idNotificacion);

  Future<void> marcarTodosAtendidos();
}
