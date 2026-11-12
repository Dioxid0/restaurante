// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cocina_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Tablero de cocina (CU-03): pedidos de hoy pendientes, en preparación y listos.
/// Se recarga solo vía Realtime cuando cambia un pedido o llega un aviso.

@ProviderFor(CocinaPedidos)
final cocinaPedidosProvider = CocinaPedidosProvider._();

/// Tablero de cocina (CU-03): pedidos de hoy pendientes, en preparación y listos.
/// Se recarga solo vía Realtime cuando cambia un pedido o llega un aviso.
final class CocinaPedidosProvider
    extends $AsyncNotifierProvider<CocinaPedidos, List<PedidoCocina>> {
  /// Tablero de cocina (CU-03): pedidos de hoy pendientes, en preparación y listos.
  /// Se recarga solo vía Realtime cuando cambia un pedido o llega un aviso.
  CocinaPedidosProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cocinaPedidosProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cocinaPedidosHash();

  @$internal
  @override
  CocinaPedidos create() => CocinaPedidos();
}

String _$cocinaPedidosHash() => r'84b1f63171c92d776ea25b4f99c26b6aeaf09123';

/// Tablero de cocina (CU-03): pedidos de hoy pendientes, en preparación y listos.
/// Se recarga solo vía Realtime cuando cambia un pedido o llega un aviso.

abstract class _$CocinaPedidos extends $AsyncNotifier<List<PedidoCocina>> {
  FutureOr<List<PedidoCocina>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<PedidoCocina>>, List<PedidoCocina>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<PedidoCocina>>, List<PedidoCocina>>,
              AsyncValue<List<PedidoCocina>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Avisos a cocina sin atender (CU-06): nuevo, modificado o cancelado.

@ProviderFor(AvisosCocina)
final avisosCocinaProvider = AvisosCocinaProvider._();

/// Avisos a cocina sin atender (CU-06): nuevo, modificado o cancelado.
final class AvisosCocinaProvider
    extends $AsyncNotifierProvider<AvisosCocina, List<AvisoCocina>> {
  /// Avisos a cocina sin atender (CU-06): nuevo, modificado o cancelado.
  AvisosCocinaProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'avisosCocinaProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$avisosCocinaHash();

  @$internal
  @override
  AvisosCocina create() => AvisosCocina();
}

String _$avisosCocinaHash() => r'07b515509027b0bb8941451cf53a77ae1b4bcbd2';

/// Avisos a cocina sin atender (CU-06): nuevo, modificado o cancelado.

abstract class _$AvisosCocina extends $AsyncNotifier<List<AvisoCocina>> {
  FutureOr<List<AvisoCocina>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<AvisoCocina>>, List<AvisoCocina>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<AvisoCocina>>, List<AvisoCocina>>,
              AsyncValue<List<AvisoCocina>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
