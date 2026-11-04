// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repository_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'5c55c13092c0c0039018a3f472e5c70ead6236c4';

@ProviderFor(pedidoRepository)
final pedidoRepositoryProvider = PedidoRepositoryProvider._();

final class PedidoRepositoryProvider
    extends
        $FunctionalProvider<
          PedidoRepository,
          PedidoRepository,
          PedidoRepository
        >
    with $Provider<PedidoRepository> {
  PedidoRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pedidoRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pedidoRepositoryHash();

  @$internal
  @override
  $ProviderElement<PedidoRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PedidoRepository create(Ref ref) {
    return pedidoRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PedidoRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PedidoRepository>(value),
    );
  }
}

String _$pedidoRepositoryHash() => r'767e146f7146158b2e9b37a20dea9f4e70dab312';

@ProviderFor(empleadoRepository)
final empleadoRepositoryProvider = EmpleadoRepositoryProvider._();

final class EmpleadoRepositoryProvider
    extends
        $FunctionalProvider<
          EmpleadoRepository,
          EmpleadoRepository,
          EmpleadoRepository
        >
    with $Provider<EmpleadoRepository> {
  EmpleadoRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'empleadoRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$empleadoRepositoryHash();

  @$internal
  @override
  $ProviderElement<EmpleadoRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EmpleadoRepository create(Ref ref) {
    return empleadoRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EmpleadoRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EmpleadoRepository>(value),
    );
  }
}

String _$empleadoRepositoryHash() =>
    r'047325c07d99dee4a27953c5c75caf7f4b738616';
