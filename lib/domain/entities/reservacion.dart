import 'package:freezed_annotation/freezed_annotation.dart';

part 'reservacion.freezed.dart';

/// Estados de una reservación (los mismos valores que guarda la base de datos).
enum EstadoReservacion {
  pendiente('pendiente', 'Pendiente'),
  confirmada('confirmada', 'Confirmada'),
  cancelada('cancelada', 'Cancelada'),
  completada('completada', 'Completada');

  const EstadoReservacion(this.valorBd, this.etiqueta);
  final String valorBd;
  final String etiqueta;

  /// Reservaciones que todavía cuentan (no canceladas ni terminadas).
  bool get esActiva => this == pendiente || this == confirmada;

  static EstadoReservacion desdeBd(String valor) =>
      EstadoReservacion.values.firstWhere((e) => e.valorBd == valor);
}

/// Una reservación de mesa. La mesa la asigna la base de datos automáticamente.
@freezed
abstract class Reservacion with _$Reservacion {
  const Reservacion._();

  const factory Reservacion({
    required int idReservacion,
    required DateTime inicio, // fecha y hora de la reservación
    required int comensales,
    required EstadoReservacion estado,
    required int idCliente,
    String? nombreCliente,
    // Solo el personal puede ver la mesa; para el cliente viene null (lo decide RLS).
    int? numeroMesa,
  }) = _Reservacion;

  /// Cada reservación ocupa la mesa 2 horas (regla de la base de datos).
  static const duracion = Duration(hours: 2);

  /// Ventana de RN-07: el cliente solo cancela o modifica con 5 horas de anticipación.
  static const anticipacionCliente = Duration(hours: 5);

  DateTime get fin => inicio.add(duracion);

  /// M-03 (o null si no se puede ver la mesa)
  String? get mesaEtiqueta =>
      numeroMesa == null ? null : 'M-${numeroMesa.toString().padLeft(2, '0')}';

  /// El cliente aún puede cancelar o modificar (RN-07). El personal no tiene este límite.
  bool clientePuedeCambiar(DateTime ahora) =>
      estado.esActiva && inicio.subtract(anticipacionCliente).isAfter(ahora);

  /// Está dentro de las últimas 5 horas y falta confirmarla: se muestra "¿Confirmas?".
  bool requiereConfirmacion(DateTime ahora) =>
      estado == EstadoReservacion.pendiente &&
      inicio.isAfter(ahora) &&
      !inicio.isAfter(ahora.add(anticipacionCliente));
}

/// Cliente que el personal elige al reservar a nombre de alguien.
@freezed
abstract class ClienteReserva with _$ClienteReserva {
  const factory ClienteReserva({
    required int idCliente,
    required String nombre,
    String? telefono,
  }) = _ClienteReserva;
}