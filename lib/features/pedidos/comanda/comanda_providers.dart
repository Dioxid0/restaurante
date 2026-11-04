import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repository_providers.dart';
import '../../../domain/entities/mesa.dart';
import '../../../domain/entities/pedido_detalle.dart';
import '../../../domain/entities/platillo.dart';

part 'comanda_providers.g.dart';

/// Menú completo (disponibles y agotados).
@riverpod
Future<List<Platillo>> menu(Ref ref) => ref.watch(menuRepositoryProvider).platillos();

/// Todas las mesas, libres u ocupadas.
@riverpod
Future<List<Mesa>> mesas(Ref ref) => ref.watch(mesaRepositoryProvider).mesas();

/// Pedido a editar.
@riverpod
Future<PedidoDetalle> pedidoParaEditar(Ref ref, int folio) =>
    ref.watch(pedidoRepositoryProvider).obtenerPedido(folio);
