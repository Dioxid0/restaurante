import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repository_providers.dart';
import '../../domain/entities/pedido.dart';

part 'pedidos_providers.g.dart';

/// Pedidos del día. Se actualiza solo vía Realtime cuando alguien cambia un pedido.
@riverpod
class PedidosDelDia extends _$PedidosDelDia {
  @override
  Future<List<PedidoResumen>> build() async {
    final repo = ref.watch(pedidoRepositoryProvider);
    final sub = repo.cambios().listen((_) => ref.invalidateSelf());
    ref.onDispose(sub.cancel);
    return repo.pedidosDelDia();
  }

  /// Cambia el estado (p. ej. listo → entregado). Las reglas las valida la base de datos.
  Future<void> cambiarEstado(int folio, EstadoPedido nuevo) async {
    await ref.read(pedidoRepositoryProvider).actualizarEstado(folio, nuevo);
    ref.invalidateSelf();
  }
}

/// Reloj que avanza cada 30 s (para los minutos transcurridos).
@riverpod
Stream<DateTime> reloj(Ref ref) async* {
  yield DateTime.now();
  yield* Stream.periodic(const Duration(seconds: 30), (_) => DateTime.now());
}
