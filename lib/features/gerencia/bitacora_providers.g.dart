// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bitacora_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Tabla elegida en el filtro de la bitácora (null = todas).

@ProviderFor(BitacoraFiltro)
final bitacoraFiltroProvider = BitacoraFiltroProvider._();

/// Tabla elegida en el filtro de la bitácora (null = todas).
final class BitacoraFiltroProvider
    extends $NotifierProvider<BitacoraFiltro, String?> {
  /// Tabla elegida en el filtro de la bitácora (null = todas).
  BitacoraFiltroProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bitacoraFiltroProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bitacoraFiltroHash();

  @$internal
  @override
  BitacoraFiltro create() => BitacoraFiltro();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$bitacoraFiltroHash() => r'bb175ffef437feff5b1403b39e2a9af146b24c83';

/// Tabla elegida en el filtro de la bitácora (null = todas).

abstract class _$BitacoraFiltro extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Últimas 100 entradas de la bitácora (según el filtro).

@ProviderFor(bitacora)
final bitacoraProvider = BitacoraProvider._();

/// Últimas 100 entradas de la bitácora (según el filtro).

final class BitacoraProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<EntradaBitacora>>,
          List<EntradaBitacora>,
          FutureOr<List<EntradaBitacora>>
        >
    with
        $FutureModifier<List<EntradaBitacora>>,
        $FutureProvider<List<EntradaBitacora>> {
  /// Últimas 100 entradas de la bitácora (según el filtro).
  BitacoraProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bitacoraProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bitacoraHash();

  @$internal
  @override
  $FutureProviderElement<List<EntradaBitacora>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<EntradaBitacora>> create(Ref ref) {
    return bitacora(ref);
  }
}

String _$bitacoraHash() => r'3c2e16cea5a9aa753b5dd3d444d890f67fcd77f2';
