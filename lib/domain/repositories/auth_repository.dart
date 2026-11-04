import '../entities/perfil.dart';

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

  /// Inicia sesión. [identificador] es un usuario de personal ("Juan Perez")
  /// o el correo de un cliente. Lanza [AuthFailure].
  Future<Perfil> iniciarSesion({
    required String identificador,
    required String password,
  });

  /// Registro público: SIEMPRE crea una cuenta de cliente.
  /// Devuelve true si quedó con sesión abierta (false si debe confirmar su correo).
  Future<bool> registrarCliente({
    required String nombre,
    required String correo,
    required String password,
    String? telefono,
  });

  /// Perfil de la sesión actual, o null si no hay sesión o no tiene perfil.
  Future<Perfil?> perfilActual();

  Future<void> cerrarSesion();
}
