import 'package:restaurant_app/domain/entities/reservacion.dart';
import 'package:restaurant_app/domain/errors.dart';
import 'package:restaurant_app/domain/repositories/reservacion_repository.dart';

/// Repositorio falso de reservaciones: guarda en memoria lo que la app le pide.
class FakeReservacionRepository implements ReservacionRepository {
  FakeReservacionRepository([List<Reservacion>? reservaciones])
      : reservaciones = reservaciones ?? [];

  List<Reservacion> reservaciones;

  final creadas = <({DateTime inicio, int comensales})>[];
  final modificadas = <({int id, DateTime inicio, int comensales})>[];
  final canceladas = <int>[];
  final confirmadas = <int>[];

  /// Si no es null, crear/modificar fallan con este mensaje.
  String? errorAlGuardar;

  /// Si no es null, cancelar/confirmar fallan con este mensaje.
  String? errorAlCambiarEstado;

  @override
  Future<List<Reservacion>> listar() async => List.of(reservaciones);

  @override
  Stream<void> cambios() => const Stream.empty();

  @override
  Future<int> crear({required DateTime inicio, required int comensales}) async {
    if (errorAlGuardar != null) throw ErrorDeNegocio(errorAlGuardar!);
    creadas.add((inicio: inicio, comensales: comensales));
    return 500 + creadas.length;
  }

  @override
  Future<void> modificar({
    required int idReservacion,
    required DateTime inicio,
    required int comensales,
  }) async {
    if (errorAlGuardar != null) throw ErrorDeNegocio(errorAlGuardar!);
    modificadas.add((id: idReservacion, inicio: inicio, comensales: comensales));
  }

  @override
  Future<void> cancelar(int idReservacion) async {
    if (errorAlCambiarEstado != null) throw ErrorDeNegocio(errorAlCambiarEstado!);
    canceladas.add(idReservacion);
    _poner(idReservacion, EstadoReservacion.cancelada);
  }

  @override
  Future<void> confirmar(int idReservacion) async {
    if (errorAlCambiarEstado != null) throw ErrorDeNegocio(errorAlCambiarEstado!);
    confirmadas.add(idReservacion);
    _poner(idReservacion, EstadoReservacion.confirmada);
  }

  void _poner(int id, EstadoReservacion estado) {
    reservaciones = [
      for (final r in reservaciones) r.idReservacion == id ? r.copyWith(estado: estado) : r,
    ];
  }
}

/// Una reservación que empieza dentro de [enCuanto] (por defecto, mañana).
Reservacion reservacionDePrueba({
  int id = 1,
  Duration enCuanto = const Duration(days: 1),
  int comensales = 2,
  EstadoReservacion estado = EstadoReservacion.pendiente,
  int? mesa,
  String? cliente,
}) =>
    Reservacion(
      idReservacion: id,
      inicio: DateTime.now().add(enCuanto),
      comensales: comensales,
      estado: estado,
      idCliente: 1,
      nombreCliente: cliente,
      numeroMesa: mesa,
    );