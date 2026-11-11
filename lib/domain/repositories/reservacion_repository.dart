import '../entities/reservacion.dart';

/// Contrato para las reservaciones (CU-10, CU-12, CU-13 y CU-14).
/// Quién puede hacer qué lo decide la base de datos (RLS y triggers), no la app.
/// Todos los métodos lanzan [ErrorDeNegocio] con el motivo si la base rechaza la acción.
abstract interface class ReservacionRepository {
  /// CU-12: las reservaciones que el usuario puede ver, de la más próxima a la más lejana.
  /// El cliente recibe solo las suyas; el mesero y el gerente reciben todas.
  Future<List<Reservacion>> listar();

  /// Emite un evento cada vez que cambia alguna reservación (tiempo real).
  Stream<void> cambios();

  /// CU-10: solo el cliente reserva. Queda `pendiente`, la base asigna la mesa
  /// y la reservación siempre es del cliente que la crea.
  /// Devuelve el id de la reservación.
  Future<int> crear({required DateTime inicio, required int comensales});

  /// CU-13: cambia fecha, hora o comensales (el cliente con 5 horas de anticipación;
  /// el gerente sin ese límite). La base vuelve a asignar mesa y, si lo hace el
  /// cliente, la reservación regresa a `pendiente`.
  Future<void> modificar({
    required int idReservacion,
    required DateTime inicio,
    required int comensales,
  });

  /// CU-14: cancela la reservación (el cliente solo con 5 horas de anticipación;
  /// el gerente en cualquier momento). El mesero no puede.
  Future<void> cancelar(int idReservacion);

  /// Solo el cliente: pasa una reservación `pendiente` a `confirmada`
  /// ("¿Confirmas tu reservación?"), con más de 5 horas de anticipación.
  Future<void> confirmar(int idReservacion);
}
