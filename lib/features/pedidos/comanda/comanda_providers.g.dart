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

/// Pedido completo (para editarlo o verlo en el modal de detalle).

@ProviderFor(detallePedido)
final detallePedidoProvider = DetallePedidoFamily._();

/// Pedido completo (para editarlo o verlo en el modal de detalle).

final class DetallePedidoProvider
    extends
        $FunctionalProvider<
          AsyncValue<PedidoDetalle>,
          PedidoDetalle,
          FutureOr<PedidoDetalle>
        >
    with $FutureModifier<PedidoDetalle>, $FutureProvider<PedidoDetalle> {
  /// Pedido completo (para editarlo o verlo en el modal de detalle).
  DetallePedidoProvider._({
    required DetallePedidoFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'detallePedidoProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$detallePedidoHash();

  @override
  String toString() {
    return r'detallePedidoProvider'
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
    return detallePedido(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DetallePedidoProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$detallePedidoHash() => r'bddda1977d8dd25e539dd9c40e9fcbc16fc7fda6';

/// Pedido completo (para editarlo o verlo en el modal de detalle).

final class DetallePedidoFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<PedidoDetalle>, int> {
  DetallePedidoFamily._()
    : super(
        retry: null,
        name: r'detallePedidoProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Pedido completo (para editarlo o verlo en el modal de detalle).

  DetallePedidoProvider call(int folio) =>
      DetallePedidoProvider._(argument: folio, from: this);

  @override
  String toString() => r'detallePedidoProvider';
}
