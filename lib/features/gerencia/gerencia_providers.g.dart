// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gerencia_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Cuentas de personal (solo las ve y administra el gerente).

@ProviderFor(CuentasPersonal)
final cuentasPersonalProvider = CuentasPersonalProvider._();

/// Cuentas de personal (solo las ve y administra el gerente).
final class CuentasPersonalProvider
    extends $AsyncNotifierProvider<CuentasPersonal, List<CuentaPersonal>> {
  /// Cuentas de personal (solo las ve y administra el gerente).
  CuentasPersonalProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cuentasPersonalProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cuentasPersonalHash();

  @$internal
  @override
  CuentasPersonal create() => CuentasPersonal();
}

String _$cuentasPersonalHash() => r'6d2fd68a36dc2817d99005059950acac44115b61';

/// Cuentas de personal (solo las ve y administra el gerente).

abstract class _$CuentasPersonal extends $AsyncNotifier<List<CuentaPersonal>> {
  FutureOr<List<CuentaPersonal>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<CuentaPersonal>>, List<CuentaPersonal>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<CuentaPersonal>>,
                List<CuentaPersonal>
              >,
              AsyncValue<List<CuentaPersonal>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
