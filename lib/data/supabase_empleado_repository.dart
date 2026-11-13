import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/entities/cuenta_personal.dart';
import '../domain/entities/perfil.dart';
import '../domain/errors.dart';
import '../domain/repositories/empleado_repository.dart';

class SupabaseEmpleadoRepository implements EmpleadoRepository {
  SupabaseEmpleadoRepository(this._client);
  final SupabaseClient _client;

  @override
  Future<List<CuentaPersonal>> listar() async {
    final filas = await _client
        .from('empleado')
        .select('id_empleado, nombre, usuario, rol, turno, activo')
        .order('nombre');
    return filas
        .map((f) => CuentaPersonal(
              idEmpleado: f['id_empleado'] as int,
              nombre: f['nombre'] as String,
              usuario: f['usuario'] as String,
              rol: RolUsuario.desdeBd(f['rol'] as String),
              activo: f['activo'] as bool,
              turno: f['turno'] as String?,
            ))
        .toList();
  }

  @override
  Future<void> crear({
    required String nombre,
    required String usuario,
    required String password,
    required RolUsuario rol,
    String? turno,
    String? pin,
  }) async {
    assert(rol.esPersonal, 'Solo se crean cuentas de personal desde Gerencia');
    try {
      await _client.rpc('crear_empleado', params: {
        'p_nombre': nombre,
        'p_usuario': usuario,
        'p_password': password,
        'p_rol': rol.name,
        'p_turno': turno,
        'p_pin': pin,
      });
    } on PostgrestException catch (e) {
      throw ErrorDeNegocio(e.message);
    }
  }

  @override
  Future<void> cambiarActivo(int idEmpleado, {required bool activo}) async {
    try {
      await _client.from('empleado').update({'activo': activo}).eq('id_empleado', idEmpleado);
    } on PostgrestException catch (e) {
      throw ErrorDeNegocio(e.message);
    }
  }

  @override
  Future<void> editar(int idEmpleado, {required String nombre, String? turno, required RolUsuario rol}) async {
    try {
      await _client.rpc('editar_empleado', params: {
        'p_id': idEmpleado,
        'p_nombre': nombre,
        'p_turno': turno,
        'p_rol': rol.name,
      });
    } on PostgrestException catch (e) {
      throw ErrorDeNegocio(e.message);
    }
  }
}
