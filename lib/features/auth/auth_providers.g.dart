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

/// Empleado de la sesión actual (null si no hay sesión o no es personal).

@ProviderFor(empleadoActual)
final empleadoActualProvider = EmpleadoActualProvider._();

/// Empleado de la sesión actual (null si no hay sesión o no es personal).

final class EmpleadoActualProvider
    extends
        $FunctionalProvider<
          AsyncValue<Empleado?>,
          Empleado?,
          FutureOr<Empleado?>
        >
    with $FutureModifier<Empleado?>, $FutureProvider<Empleado?> {
  /// Empleado de la sesión actual (null si no hay sesión o no es personal).
  EmpleadoActualProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'empleadoActualProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$empleadoActualHash();

  @$internal
  @override
  $FutureProviderElement<Empleado?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Empleado?> create(Ref ref) {
    return empleadoActual(ref);
  }
}

String _$empleadoActualHash() => r'20aab3f1dc5337938319527b2398676bb869a631';

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

String _$loginControllerHash() => r'e73fd0012b34ae962bcdfa9c3266d460c9cc02d6';

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
