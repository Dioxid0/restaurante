import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repository_providers.dart';
import '../../domain/entities/reservacion.dart';

part 'reservaciones_providers.g.dart';

/// Reservaciones que el usuario puede ver (CU-12).
/// El cliente recibe solo las suyas; el mesero y el gerente, todas (lo decide la base).
/// Se actualiza sola vía Realtime cuando alguien crea, cambia o cancela una reservación.
@riverpod
class ReservacionesLista extends _$ReservacionesLista {
  @override
  Future<List<Reservacion>> build() async {
    final repo = ref.watch(reservacionRepositoryProvider);
    final sub = repo.cambios().listen((_) => ref.invalidateSelf());
    ref.onDispose(sub.cancel);
    return repo.listar();
  }

  /// CU-10: crea la reservación. Si falla lanza [ErrorDeNegocio] con el motivo.
  /// [idCliente] solo lo usa el personal; el cliente siempre reserva para sí mismo.
  Future<int> crear({
    required DateTime inicio,
    required int comensales,
    int? idCliente,
  }) async {
    final id = await ref.read(reservacionRepositoryProvider).crear(
          inicio: inicio,
          comensales: comensales,
          idCliente: idCliente,
        );
    ref.invalidateSelf();
    return id;
  }

  /// CU-13: cambia fecha, hora o comensales.
  Future<void> modificar({
    required int idReservacion,
    required DateTime inicio,
    required int comensales,
  }) async {
    await ref.read(reservacionRepositoryProvider).modificar(
          idReservacion: idReservacion,
          inicio: inicio,
          comensales: comensales,
        );
    ref.invalidateSelf();
  }

  /// CU-14: cancela la reservación (el cliente solo con 5 horas de anticipación).
  Future<void> cancelar(int idReservacion) async {
    await ref.read(reservacionRepositoryProvider).cancelar(idReservacion);
    ref.invalidateSelf();
  }

  /// "¿Confirmas tu reservación?": pasa de pendiente a confirmada.
  Future<void> confirmar(int idReservacion) async {
    await ref.read(reservacionRepositoryProvider).confirmar(idReservacion);
    ref.invalidateSelf();
  }
}

/// Clientes que el personal puede elegir al reservar (solo lo usa el personal).
@riverpod
class ClientesReserva extends _$ClientesReserva {
  @override
  Future<List<ClienteReserva>> build() => ref.watch(reservacionRepositoryProvider).clientes();

  /// Da de alta un cliente sin cuenta (por ejemplo, el que llama por teléfono)
  /// y devuelve el cliente creado para dejarlo seleccionado.
  Future<ClienteReserva> crear({required String nombre, String? telefono}) async {
    final nuevo = await ref
        .read(reservacionRepositoryProvider)
        .crearCliente(nombre: nombre, telefono: telefono);
    ref.invalidateSelf();
    return nuevo;
  }
}