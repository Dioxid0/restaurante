// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comanda_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Estado de la pantalla de comanda (crear / editar / pedido del cliente).
/// [esCliente]: el cliente siempre pide "para llevar" y sin mesa.

@ProviderFor(ComandaController)
final comandaControllerProvider = ComandaControllerFamily._();

/// Estado de la pantalla de comanda (crear / editar / pedido del cliente).
/// [esCliente]: el cliente siempre pide "para llevar" y sin mesa.
final class ComandaControllerProvider
    extends $NotifierProvider<ComandaController, ComandaState> {
  /// Estado de la pantalla de comanda (crear / editar / pedido del cliente).
  /// [esCliente]: el cliente siempre pide "para llevar" y sin mesa.
  ComandaControllerProvider._({
    required ComandaControllerFamily super.from,
    required bool super.argument,
  }) : super(
         retry: null,
         name: r'comandaControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$comandaControllerHash();

  @override
  String toString() {
    return r'comandaControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ComandaController create() => ComandaController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ComandaState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ComandaState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ComandaControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$comandaControllerHash() => r'1cbf08767e5f3fa26934053fe1a9c6f8deb03dc6';

/// Estado de la pantalla de comanda (crear / editar / pedido del cliente).
/// [esCliente]: el cliente siempre pide "para llevar" y sin mesa.

final class ComandaControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ComandaController,
          ComandaState,
          ComandaState,
          ComandaState,
          bool
        > {
  ComandaControllerFamily._()
    : super(
        retry: null,
        name: r'comandaControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Estado de la pantalla de comanda (crear / editar / pedido del cliente).
  /// [esCliente]: el cliente siempre pide "para llevar" y sin mesa.

  ComandaControllerProvider call({required bool esCliente}) =>
      ComandaControllerProvider._(argument: esCliente, from: this);

  @override
  String toString() => r'comandaControllerProvider';
}

/// Estado de la pantalla de comanda (crear / editar / pedido del cliente).
/// [esCliente]: el cliente siempre pide "para llevar" y sin mesa.

abstract class _$ComandaController extends $Notifier<ComandaState> {
  late final _$args = ref.$arg as bool;
  bool get esCliente => _$args;

  ComandaState build({required bool esCliente});
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ComandaState, ComandaState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ComandaState, ComandaState>,
              ComandaState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(esCliente: _$args));
  }
}
