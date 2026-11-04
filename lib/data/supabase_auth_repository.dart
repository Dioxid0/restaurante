import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/utils/usuario.dart';
import '../domain/entities/perfil.dart';
import '../domain/repositories/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);
  final SupabaseClient _client;

  @override
  bool get haySesion => _client.auth.currentSession != null;

  @override
  Stream<bool> get cambiosDeSesion =>
      _client.auth.onAuthStateChange.map((e) => e.session != null).distinct();

  @override
  Future<Perfil> iniciarSesion({
    required String identificador,
    required String password,
  }) async {
    try {
      await _client.auth.signInWithPassword(
        email: identificadorACorreo(identificador),
        password: password,
      );
    } on AuthRetryableFetchException {
      throw const AuthFailure('No se pudo conectar con el servidor');
    } on AuthException catch (e) {
      if (e.code == 'over_request_rate_limit' || e.statusCode == '429') {
        throw const AuthFailure('Demasiados intentos. Espera unos minutos');
      }
      // Mensaje genérico a propósito: no revela si el usuario existe.
      throw const AuthFailure('Usuario o contraseña incorrectos');
    }

    final perfil = await perfilActual();
    if (perfil == null) {
      await _client.auth.signOut();
      throw const AuthFailure('Tu cuenta no tiene un perfil asociado. Contacta al gerente');
    }
    return perfil;
  }

  @override
  Future<bool> registrarCliente({
    required String nombre,
    required String correo,
    required String password,
    String? telefono,
  }) async {
    try {
      final respuesta = await _client.auth.signUp(
        email: correo.trim().toLowerCase(),
        password: password,
        // Solo datos del perfil: el rol NUNCA se envía; el servidor siempre crea "cliente".
        data: {
          'nombre': nombre.trim(),
          if (telefono != null && telefono.trim().isNotEmpty) 'telefono': telefono.trim(),
        },
      );
      return respuesta.session != null;
    } on AuthRetryableFetchException {
      throw const AuthFailure('No se pudo conectar con el servidor');
    } on AuthException catch (e) {
      throw AuthFailure(switch (e.code) {
        'user_already_exists' || 'email_exists' => 'Ya existe una cuenta con ese correo',
        'weak_password' => 'La contraseña es muy débil. Usa al menos 8 caracteres',
        'over_request_rate_limit' || 'over_email_send_rate_limit' =>
          'Demasiados intentos. Espera unos minutos',
        'email_address_invalid' || 'validation_failed' => 'Revisa el correo electrónico',
        _ => 'No se pudo crear la cuenta. Intenta de nuevo',
      });
    }
  }

  @override
  Future<Perfil?> perfilActual() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return null;

    final empleado = await _client
        .from('empleado')
        .select('id_empleado, nombre, rol, turno, usuario')
        .eq('user_id', uid)
        .maybeSingle();
    if (empleado != null) {
      return Perfil(
        id: empleado['id_empleado'] as int,
        nombre: empleado['nombre'] as String,
        rol: RolUsuario.desdeBd(empleado['rol'] as String),
        usuario: empleado['usuario'] as String,
        turno: empleado['turno'] as String?,
      );
    }

    final cliente = await _client
        .from('cliente')
        .select('id_cliente, nombre, correo')
        .eq('user_id', uid)
        .maybeSingle();
    if (cliente != null) {
      return Perfil(
        id: cliente['id_cliente'] as int,
        nombre: cliente['nombre'] as String,
        rol: RolUsuario.cliente,
        correo: cliente['correo'] as String?,
      );
    }
    return null;
  }

  @override
  Future<void> cerrarSesion() => _client.auth.signOut();
}
