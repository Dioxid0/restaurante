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

  /// CU-10: crea una reservación `pendiente` y la base asigna la mesa.
  /// Si lo hace un cliente, se ignora [idCliente] (siempre es el suyo).
  /// Si lo hace el personal, [idCliente] es obligatorio.
  /// Devuelve el id de la reservación.
  Future<int> crear({
    required DateTime inicio,
    required int comensales,
    int? idCliente,
  });

  /// CU-13: cambia fecha, hora o comensales. La base vuelve a asignar mesa y,
  /// si lo hace el cliente, la reservación regresa a `pendiente`.
  Future<void> modificar({
    required int idReservacion,
    required DateTime inicio,
    required int comensales,
  });

  /// CU-14: cancela la reservación (el cliente solo con 5 horas de anticipación).
  Future<void> cancelar(int idReservacion);

  /// Pasa una reservación `pendiente` a `confirmada` ("¿Confirmas tu reservación?").
  Future<void> confirmar(int idReservacion);

  /// Solo para el personal: clientes que se pueden elegir al reservar.
  Future<List<ClienteReserva>> clientes();

  /// Solo para el personal: da de alta un cliente sin cuenta (por ejemplo, el que llama por teléfono).
  Future<ClienteReserva> crearCliente({required String nombre, String? telefono});
}