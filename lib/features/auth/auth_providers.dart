import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repository_providers.dart';
import '../../domain/entities/perfil.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_providers.g.dart';

/// true mientras haya sesión abierta.
@riverpod
Stream<bool> sesionActiva(Ref ref) async* {
  final repo = ref.watch(authRepositoryProvider);
  yield repo.haySesion;
  yield* repo.cambiosDeSesion;
}

/// Perfil de la sesión actual (null si no hay sesión).
@riverpod
Future<Perfil?> perfilActual(Ref ref) async {
  final activa = await ref.watch(sesionActivaProvider.future);
  if (!activa) return null;
  return ref.watch(authRepositoryProvider).perfilActual();
}

/// Mensaje legible de un error de autenticación (o null si no hay error).
String? mensajeDeAuth(AsyncValue<void> estado) {
  final error = estado.error;
  if (error == null) return null;
  if (error is AuthFailure) return error.mensaje;
  return 'Ocurrió un error inesperado. Intenta de nuevo';
}

/// Estado del formulario de login. keepAlive para conservar el mensaje de
/// error si la pantalla se reconstruye durante el cierre de sesión.
@Riverpod(keepAlive: true)
class LoginController extends _$LoginController {
  @override
  FutureOr<void> build() {}

  Future<void> ingresar(String identificador, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .iniciarSesion(identificador: identificador, password: password),
    );
  }

  Future<void> cerrarSesion() => ref.read(authRepositoryProvider).cerrarSesion();
}

/// Registro de clientes. El estado es `true` si falta confirmar el correo.
@riverpod
class RegistroController extends _$RegistroController {
  @override
  FutureOr<bool?> build() => null;

  Future<void> registrar({
    required String nombre,
    required String correo,
    required String password,
    String? telefono,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final conSesion = await ref.read(authRepositoryProvider).registrarCliente(
            nombre: nombre,
            correo: correo,
            password: password,
            telefono: telefono,
          );
      return !conSesion; // true => debe confirmar su correo
    });
  }
}
