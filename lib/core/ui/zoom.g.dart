// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zoom.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Zoom elegido por el usuario (Ctrl +, Ctrl -, Ctrl 0 o los botones del encabezado).
/// Se recuerda entre sesiones.

@ProviderFor(ZoomUsuario)
final zoomUsuarioProvider = ZoomUsuarioProvider._();

/// Zoom elegido por el usuario (Ctrl +, Ctrl -, Ctrl 0 o los botones del encabezado).
/// Se recuerda entre sesiones.
final class ZoomUsuarioProvider extends $NotifierProvider<ZoomUsuario, double> {
  /// Zoom elegido por el usuario (Ctrl +, Ctrl -, Ctrl 0 o los botones del encabezado).
  /// Se recuerda entre sesiones.
  ZoomUsuarioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'zoomUsuarioProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$zoomUsuarioHash();

  @$internal
  @override
  ZoomUsuario create() => ZoomUsuario();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$zoomUsuarioHash() => r'4fbb8785904aa5b711731f30ba8eaf9a25598af7';

/// Zoom elegido por el usuario (Ctrl +, Ctrl -, Ctrl 0 o los botones del encabezado).
/// Se recuerda entre sesiones.

abstract class _$ZoomUsuario extends $Notifier<double> {
  double build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<double, double>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<double, double>,
              double,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
