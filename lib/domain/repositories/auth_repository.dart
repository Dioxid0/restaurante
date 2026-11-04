import '../entities/empleado.dart';

/// Error de autenticación con un mensaje listo para mostrar al usuario.
class AuthFailure implements Exception {
  const AuthFailure(this.mensaje);
  final String mensaje;

  @override
  String toString() => mensaje;
}

abstract interface class AuthRepository {
  /// Hay una sesión abierta (incluye sesión recuperada al abrir la app).
  bool get haySesion;

  /// Emite true/false cada vez que se abre o cierra la sesión.
  Stream<bool> get cambiosDeSesion;

  /// Inicia sesión con usuario + contraseña. Lanza [AuthFailure].
  Future<Empleado> iniciarSesion({
    required String usuario,
    required String password,
  });

  /// Empleado de la sesión actual, o null si no hay sesión o la cuenta no es de personal.
  Future<Empleado?> empleadoActual();

  Future<void> cerrarSesion();
}
