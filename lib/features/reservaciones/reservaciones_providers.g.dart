// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservaciones_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Reservaciones que el usuario puede ver (CU-12).
/// El cliente recibe solo las suyas; el mesero y el gerente, todas (lo decide la base).
/// Se actualiza sola vía Realtime cuando alguien crea, cambia o cancela una reservación.

@ProviderFor(ReservacionesLista)
final reservacionesListaProvider = ReservacionesListaProvider._();

/// Reservaciones que el usuario puede ver (CU-12).
/// El cliente recibe solo las suyas; el mesero y el gerente, todas (lo decide la base).
/// Se actualiza sola vía Realtime cuando alguien crea, cambia o cancela una reservación.
final class ReservacionesListaProvider
    extends $AsyncNotifierProvider<ReservacionesLista, List<Reservacion>> {
  /// Reservaciones que el usuario puede ver (CU-12).
  /// El cliente recibe solo las suyas; el mesero y el gerente, todas (lo decide la base).
  /// Se actualiza sola vía Realtime cuando alguien crea, cambia o cancela una reservación.
  ReservacionesListaProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reservacionesListaProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reservacionesListaHash();

  @$internal
  @override
  ReservacionesLista create() => ReservacionesLista();
}

String _$reservacionesListaHash() =>
    r'43dcb611bf7c76c9616659986fcf5cafcdb293e0';

/// Reservaciones que el usuario puede ver (CU-12).
/// El cliente recibe solo las suyas; el mesero y el gerente, todas (lo decide la base).
/// Se actualiza sola vía Realtime cuando alguien crea, cambia o cancela una reservación.

abstract class _$ReservacionesLista extends $AsyncNotifier<List<Reservacion>> {
  FutureOr<List<Reservacion>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<Reservacion>>, List<Reservacion>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Reservacion>>, List<Reservacion>>,
              AsyncValue<List<Reservacion>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
