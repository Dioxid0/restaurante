import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repository_providers.dart';
import '../../domain/entities/cocina.dart';
import '../../domain/entities/pedido.dart';

part 'cocina_providers.g.dart';

/// Tablero de cocina (CU-03): pedidos de hoy pendientes, en preparación y listos.
/// Se recarga solo vía Realtime cuando cambia un pedido o llega un aviso.
@riverpod
class CocinaPedidos extends _$CocinaPedidos {
  @override
  Future<List<PedidoCocina>> build() async {
    final repo = ref.watch(cocinaRepositoryProvider);
    final sub = repo.cambios().listen((_) => ref.invalidateSelf());
    ref.onDispose(sub.cancel);
    return repo.pedidos();
  }

  /// CU-15: avanza el pedido (pendiente → en preparación, en preparación → listo).
  /// La base rechaza cualquier otra transición con un mensaje en español.
  Future<void> avanzar(int folio, EstadoPedido nuevo) async {
    await ref.read(pedidoRepositoryProvider).actualizarEstado(folio, nuevo);
    ref.invalidateSelf();
  }
}

/// Avisos a cocina sin atender (CU-06): nuevo, modificado o cancelado.
@riverpod
class AvisosCocina extends _$AvisosCocina {
  @override
  Future<List<AvisoCocina>> build() async {
    final repo = ref.watch(cocinaRepositoryProvider);
    final sub = repo.cambios().listen((_) => ref.invalidateSelf());
    ref.onDispose(sub.cancel);
    return repo.avisosPendientes();
  }

  Future<void> atender(int idNotificacion) async {
    await ref.read(cocinaRepositoryProvider).marcarAtendido(idNotificacion);
    ref.invalidateSelf();
  }

  Future<void> atenderTodos() async {
    await ref.read(cocinaRepositoryProvider).marcarTodosAtendidos();
    ref.invalidateSelf();
  }
}
