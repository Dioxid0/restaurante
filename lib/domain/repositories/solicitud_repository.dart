import '../entities/solicitud_cambio.dart';

/// Solicitudes de cambio de pedidos (RN-03). El mesero solicita y el gerente resuelve;
/// las reglas (quién puede, en qué estado, una sola pendiente por pedido) las valida la base.
abstract interface class SolicitudRepository {
  /// Solicitudes de los pedidos de hoy, de la más antigua a la más reciente.
  Future<List<SolicitudCambio>> deHoy();

  /// Emite un evento cuando llega o cambia una solicitud (tiempo real).
  Stream<void> cambios();

  /// Mesero: pide [tipo] sobre el pedido [folio], con un motivo.
  Future<void> solicitar(int folio, TipoSolicitud tipo, String motivo);

  /// Gerente: aprueba (abre 10 minutos de autorización) o rechaza.
  Future<void> resolver(int idSolicitud, {required bool aprobar});
}
