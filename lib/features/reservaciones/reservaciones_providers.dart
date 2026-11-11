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
  /// Solo el cliente reserva, y siempre para sí mismo.
  Future<int> crear({required DateTime inicio, required int comensales}) async {
    final id = await ref
        .read(reservacionRepositoryProvider)
        .crear(inicio: inicio, comensales: comensales);
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
