// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reporte_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PeriodoSeleccionado)
final periodoSeleccionadoProvider = PeriodoSeleccionadoProvider._();

final class PeriodoSeleccionadoProvider
    extends $NotifierProvider<PeriodoSeleccionado, PeriodoReporte> {
  PeriodoSeleccionadoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'periodoSeleccionadoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$periodoSeleccionadoHash();

  @$internal
  @override
  PeriodoSeleccionado create() => PeriodoSeleccionado();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PeriodoReporte value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PeriodoReporte>(value),
    );
  }
}

String _$periodoSeleccionadoHash() =>
    r'caaa4775a173f696036fd1c6ef1de7210a1b5521';

abstract class _$PeriodoSeleccionado extends $Notifier<PeriodoReporte> {
  PeriodoReporte build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PeriodoReporte, PeriodoReporte>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PeriodoReporte, PeriodoReporte>,
              PeriodoReporte,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Reporte del periodo elegido. `ref.invalidate(reporteGerencialProvider)` lo recalcula.

@ProviderFor(reporteGerencial)
final reporteGerencialProvider = ReporteGerencialProvider._();

/// Reporte del periodo elegido. `ref.invalidate(reporteGerencialProvider)` lo recalcula.

final class ReporteGerencialProvider
    extends
        $FunctionalProvider<
          AsyncValue<ReporteGerencial>,
          ReporteGerencial,
          FutureOr<ReporteGerencial>
        >
    with $FutureModifier<ReporteGerencial>, $FutureProvider<ReporteGerencial> {
  /// Reporte del periodo elegido. `ref.invalidate(reporteGerencialProvider)` lo recalcula.
  ReporteGerencialProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reporteGerencialProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reporteGerencialHash();

  @$internal
  @override
  $FutureProviderElement<ReporteGerencial> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ReporteGerencial> create(Ref ref) {
    return reporteGerencial(ref);
  }
}

String _$reporteGerencialHash() => r'5267280893e81379979aae77627659be94f0e618';
