// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comanda_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Menú completo (disponibles y agotados).

@ProviderFor(menu)
final menuProvider = MenuProvider._();

/// Menú completo (disponibles y agotados).

final class MenuProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Platillo>>,
          List<Platillo>,
          FutureOr<List<Platillo>>
        >
    with $FutureModifier<List<Platillo>>, $FutureProvider<List<Platillo>> {
  /// Menú completo (disponibles y agotados).
  MenuProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'menuProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$menuHash();

  @$internal
  @override
  $FutureProviderElement<List<Platillo>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Platillo>> create(Ref ref) {
    return menu(ref);
  }
}

String _$menuHash() => r'dbce981afc0346ca02b0d2982120f1dd665ac6f3';

/// Todas las mesas, libres u ocupadas.

@ProviderFor(mesas)
final mesasProvider = MesasProvider._();

/// Todas las mesas, libres u ocupadas.

final class MesasProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Mesa>>,
          List<Mesa>,
          FutureOr<List<Mesa>>
        >
    with $FutureModifier<List<Mesa>>, $FutureProvider<List<Mesa>> {
  /// Todas las mesas, libres u ocupadas.
  MesasProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mesasProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mesasHash();

  @$internal
  @override
  $FutureProviderElement<List<Mesa>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Mesa>> create(Ref ref) {
    return mesas(ref);
  }
}

String _$mesasHash() => r'5dfac5c164c807a1b1ebcc5ebc1edebe40c27b2d';

/// Pedido a editar.

@ProviderFor(pedidoParaEditar)
final pedidoParaEditarProvider = PedidoParaEditarFamily._();

/// Pedido a editar.

final class PedidoParaEditarProvider
    extends
        $FunctionalProvider<
          AsyncValue<PedidoDetalle>,
          PedidoDetalle,
          FutureOr<PedidoDetalle>
        >
    with $FutureModifier<PedidoDetalle>, $FutureProvider<PedidoDetalle> {
  /// Pedido a editar.
  PedidoParaEditarProvider._({
    required PedidoParaEditarFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'pedidoParaEditarProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pedidoParaEditarHash();

  @override
  String toString() {
    return r'pedidoParaEditarProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<PedidoDetalle> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PedidoDetalle> create(Ref ref) {
    final argument = this.argument as int;
    return pedidoParaEditar(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PedidoParaEditarProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pedidoParaEditarHash() => r'98b96b06c192ec99f1ea23d2e285f63f29cbf95d';

/// Pedido a editar.

final class PedidoParaEditarFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<PedidoDetalle>, int> {
  PedidoParaEditarFamily._()
    : super(
        retry: null,
        name: r'pedidoParaEditarProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Pedido a editar.

  PedidoParaEditarProvider call(int folio) =>
      PedidoParaEditarProvider._(argument: folio, from: this);

  @override
  String toString() => r'pedidoParaEditarProvider';
}
