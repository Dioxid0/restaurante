// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pedidos_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Pedidos del día. Se actualiza solo vía Realtime cuando alguien cambia un pedido.

@ProviderFor(PedidosDelDia)
final pedidosDelDiaProvider = PedidosDelDiaProvider._();

/// Pedidos del día. Se actualiza solo vía Realtime cuando alguien cambia un pedido.
final class PedidosDelDiaProvider
    extends $AsyncNotifierProvider<PedidosDelDia, List<PedidoResumen>> {
  /// Pedidos del día. Se actualiza solo vía Realtime cuando alguien cambia un pedido.
  PedidosDelDiaProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pedidosDelDiaProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pedidosDelDiaHash();

  @$internal
  @override
  PedidosDelDia create() => PedidosDelDia();
}

String _$pedidosDelDiaHash() => r'598a8a616ed9f409ea1b2420494eb8fc2c108fed';

/// Pedidos del día. Se actualiza solo vía Realtime cuando alguien cambia un pedido.

abstract class _$PedidosDelDia extends $AsyncNotifier<List<PedidoResumen>> {
  FutureOr<List<PedidoResumen>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<PedidoResumen>>, List<PedidoResumen>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<PedidoResumen>>, List<PedidoResumen>>,
              AsyncValue<List<PedidoResumen>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Reloj que avanza cada 30 s (para los minutos transcurridos).

@ProviderFor(reloj)
final relojProvider = RelojProvider._();

/// Reloj que avanza cada 30 s (para los minutos transcurridos).

final class RelojProvider
    extends
        $FunctionalProvider<AsyncValue<DateTime>, DateTime, Stream<DateTime>>
    with $FutureModifier<DateTime>, $StreamProvider<DateTime> {
  /// Reloj que avanza cada 30 s (para los minutos transcurridos).
  RelojProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'relojProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$relojHash();

  @$internal
  @override
  $StreamProviderElement<DateTime> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<DateTime> create(Ref ref) {
    return reloj(ref);
  }
}

String _$relojHash() => r'7d6d4394b2e13b9eb30b0f2c3acdb1abd4caf37f';
