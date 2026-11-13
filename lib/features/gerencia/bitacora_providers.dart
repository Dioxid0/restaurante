import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repository_providers.dart';
import '../../domain/entities/entrada_bitacora.dart';

part 'bitacora_providers.g.dart';

/// Tabla elegida en el filtro de la bitácora (null = todas).
@riverpod
class BitacoraFiltro extends _$BitacoraFiltro {
  @override
  String? build() => null;

  void elegir(String? tabla) => state = tabla;
}

/// Últimas 100 entradas de la bitácora (según el filtro).
@riverpod
Future<List<EntradaBitacora>> bitacora(Ref ref) {
  final tabla = ref.watch(bitacoraFiltroProvider);
  return ref.watch(bitacoraRepositoryProvider).recientes(tabla: tabla, limite: 100);
}
