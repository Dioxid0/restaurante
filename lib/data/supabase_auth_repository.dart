import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/entities/empleado.dart';
import '../domain/repositories/auth_repository.dart';

/// Dominio interno de los correos de empleados: `usuario@restaurante.local`.
const _dominioEmpleados = 'restaurante.local';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);
  final SupabaseClient _client;

  @override
  bool get haySesion => _client.auth.currentSession != null;

  @override
  Stream<bool> get cambiosDeSesion =>
      _client.auth.onAuthStateChange.map((e) => e.session != null).distinct();

  @override
  Future<Empleado> iniciarSesion({
    required String usuario,
    required String password,
  }) async {
    final email = '${usuario.trim().toLowerCase()}@$_dominioEmpleados';
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
    } on AuthRetryableFetchException {
      throw const AuthFailure('No se pudo conectar con el servidor');
    } on AuthException {
      throw const AuthFailure('Usuario o contraseña incorrectos');
    }

    final empleado = await empleadoActual();
    if (empleado == null) {
      await _client.auth.signOut();
      throw const AuthFailure('Esta cuenta no tiene acceso al sistema de personal');
    }
    return empleado;
  }

  @override
  Future<Empleado?> empleadoActual() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return null;
    final fila = await _client
        .from('empleado')
        .select('id_empleado, nombre, rol, turno, usuario')
        .eq('user_id', uid)
        .maybeSingle();
    if (fila == null) return null;
    return Empleado(
      idEmpleado: fila['id_empleado'] as int,
      nombre: fila['nombre'] as String,
      rol: RolEmpleado.desdeBd(fila['rol'] as String),
      usuario: fila['usuario'] as String,
      turno: fila['turno'] as String?,
    );
  }

  @override
  Future<void> cerrarSesion() => _client.auth.signOut();
}
