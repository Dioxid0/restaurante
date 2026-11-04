import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repository_providers.dart';
import '../../domain/entities/empleado.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_providers.g.dart';

/// true mientras haya sesión abierta.
@riverpod
Stream<bool> sesionActiva(Ref ref) async* {
  final repo = ref.watch(authRepositoryProvider);
  yield repo.haySesion;
  yield* repo.cambiosDeSesion;
}

/// Empleado de la sesión actual (null si no hay sesión o no es personal).
@riverpod
Future<Empleado?> empleadoActual(Ref ref) async {
  final activa = await ref.watch(sesionActivaProvider.future);
  if (!activa) return null;
  return ref.watch(authRepositoryProvider).empleadoActual();
}

/// Estado del formulario de login. keepAlive para conservar el mensaje de
/// error si la pantalla se reconstruye durante el cierre de sesión.
@Riverpod(keepAlive: true)
class LoginController extends _$LoginController {
  @override
  FutureOr<void> build() {}

  Future<void> ingresar(String usuario, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .iniciarSesion(usuario: usuario, password: password),
    );
  }

  Future<void> cerrarSesion() => ref.read(authRepositoryProvider).cerrarSesion();

  /// Mensaje de error legible (o null).
  static String? mensaje(AsyncValue<void> estado) {
    final error = estado.error;
    if (error == null) return null;
    if (error is AuthFailure) return error.mensaje;
    return 'Ocurrió un error inesperado. Intenta de nuevo';
  }
}
