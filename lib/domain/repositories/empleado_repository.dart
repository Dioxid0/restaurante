import '../entities/cuenta_personal.dart';
import '../entities/perfil.dart';

abstract interface class EmpleadoRepository {
  Future<List<CuentaPersonal>> listar();

  /// Solo el gerente puede crear cuentas (lo exige la base de datos).
  /// Lanza [ErrorDeNegocio] con el motivo si no se pudo.
  Future<void> crear({
    required String nombre,
    required String usuario,
    required String password,
    required RolUsuario rol,
    String? turno,
    String? pin,
  });

  Future<void> cambiarActivo(int idEmpleado, {required bool activo});

  /// Cambia nombre, turno y rol (RPC `editar_empleado`, solo gerente).
  /// La base impide cambiarte tu propio rol o dejar el sistema sin gerente.
  Future<void> editar(int idEmpleado, {required String nombre, String? turno, required RolUsuario rol});
}
