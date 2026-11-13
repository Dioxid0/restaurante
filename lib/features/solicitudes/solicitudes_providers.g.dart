// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'solicitudes_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Solicitudes de cambio de los pedidos de hoy (RN-03). Solo las ven el mesero y el
/// gerente (la base no entrega nada a los demás). Se actualiza sola por Realtime.

@ProviderFor(SolicitudesDeHoy)
final solicitudesDeHoyProvider = SolicitudesDeHoyProvider._();

/// Solicitudes de cambio de los pedidos de hoy (RN-03). Solo las ven el mesero y el
/// gerente (la base no entrega nada a los demás). Se actualiza sola por Realtime.
final class SolicitudesDeHoyProvider
    extends $AsyncNotifierProvider<SolicitudesDeHoy, List<SolicitudCambio>> {
  /// Solicitudes de cambio de los pedidos de hoy (RN-03). Solo las ven el mesero y el
  /// gerente (la base no entrega nada a los demás). Se actualiza sola por Realtime.
  SolicitudesDeHoyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'solicitudesDeHoyProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$solicitudesDeHoyHash();

  @$internal
  @override
  SolicitudesDeHoy create() => SolicitudesDeHoy();
}

String _$solicitudesDeHoyHash() => r'2cac3f4c3d12d30e65f145489576220cc5217337';

/// Solicitudes de cambio de los pedidos de hoy (RN-03). Solo las ven el mesero y el
/// gerente (la base no entrega nada a los demás). Se actualiza sola por Realtime.

abstract class _$SolicitudesDeHoy
    extends $AsyncNotifier<List<SolicitudCambio>> {
  FutureOr<List<SolicitudCambio>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<SolicitudCambio>>, List<SolicitudCambio>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<SolicitudCambio>>,
                List<SolicitudCambio>
              >,
              AsyncValue<List<SolicitudCambio>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
