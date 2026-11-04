// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// true mientras haya sesión abierta.

@ProviderFor(sesionActiva)
final sesionActivaProvider = SesionActivaProvider._();

/// true mientras haya sesión abierta.

final class SesionActivaProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// true mientras haya sesión abierta.
  SesionActivaProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sesionActivaProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sesionActivaHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return sesionActiva(ref);
  }
}

String _$sesionActivaHash() => r'ca35e15f4fe77116855d21dd21c4c8defce6789c';

/// Perfil de la sesión actual (null si no hay sesión).

@ProviderFor(perfilActual)
final perfilActualProvider = PerfilActualProvider._();

/// Perfil de la sesión actual (null si no hay sesión).

final class PerfilActualProvider
    extends $FunctionalProvider<AsyncValue<Perfil?>, Perfil?, FutureOr<Perfil?>>
    with $FutureModifier<Perfil?>, $FutureProvider<Perfil?> {
  /// Perfil de la sesión actual (null si no hay sesión).
  PerfilActualProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'perfilActualProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$perfilActualHash();

  @$internal
  @override
  $FutureProviderElement<Perfil?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Perfil?> create(Ref ref) {
    return perfilActual(ref);
  }
}

String _$perfilActualHash() => r'5fad6b8721766b868633d4ed6c9b341d02cdd97b';

/// Estado del formulario de login. keepAlive para conservar el mensaje de
/// error si la pantalla se reconstruye durante el cierre de sesión.

@ProviderFor(LoginController)
final loginControllerProvider = LoginControllerProvider._();

/// Estado del formulario de login. keepAlive para conservar el mensaje de
/// error si la pantalla se reconstruye durante el cierre de sesión.
final class LoginControllerProvider
    extends $AsyncNotifierProvider<LoginController, void> {
  /// Estado del formulario de login. keepAlive para conservar el mensaje de
  /// error si la pantalla se reconstruye durante el cierre de sesión.
  LoginControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loginControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loginControllerHash();

  @$internal
  @override
  LoginController create() => LoginController();
}

String _$loginControllerHash() => r'c60ef5ebb588614fc6bb9051843bbdce971ff3ef';

/// Estado del formulario de login. keepAlive para conservar el mensaje de
/// error si la pantalla se reconstruye durante el cierre de sesión.

abstract class _$LoginController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Registro de clientes. El estado es `true` si falta confirmar el correo.

@ProviderFor(RegistroController)
final registroControllerProvider = RegistroControllerProvider._();

/// Registro de clientes. El estado es `true` si falta confirmar el correo.
final class RegistroControllerProvider
    extends $AsyncNotifierProvider<RegistroController, bool?> {
  /// Registro de clientes. El estado es `true` si falta confirmar el correo.
  RegistroControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'registroControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$registroControllerHash();

  @$internal
  @override
  RegistroController create() => RegistroController();
}

String _$registroControllerHash() =>
    r'6595fd06b990c52d19cb3f49cbdbbed5bd6efa6b';

/// Registro de clientes. El estado es `true` si falta confirmar el correo.

abstract class _$RegistroController extends $AsyncNotifier<bool?> {
  FutureOr<bool?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool?>, bool?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool?>, bool?>,
              AsyncValue<bool?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
