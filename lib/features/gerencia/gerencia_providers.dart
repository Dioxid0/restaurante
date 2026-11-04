import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repository_providers.dart';
import '../../domain/entities/cuenta_personal.dart';
import '../../domain/entities/perfil.dart';

part 'gerencia_providers.g.dart';

/// Cuentas de personal (solo las ve y administra el gerente).
@riverpod
class CuentasPersonal extends _$CuentasPersonal {
  @override
  Future<List<CuentaPersonal>> build() => ref.watch(empleadoRepositoryProvider).listar();

  /// Crea la cuenta; si falla lanza [ErrorDeNegocio] con el motivo.
  Future<void> crear({
    required String nombre,
    required String usuario,
    required String password,
    required RolUsuario rol,
    String? turno,
    String? pin,
  }) async {
    await ref.read(empleadoRepositoryProvider).crear(
          nombre: nombre,
          usuario: usuario,
          password: password,
          rol: rol,
          turno: turno,
          pin: pin,
        );
    ref.invalidateSelf();
  }

  Future<void> cambiarActivo(int idEmpleado, {required bool activo}) async {
    await ref.read(empleadoRepositoryProvider).cambiarActivo(idEmpleado, activo: activo);
    ref.invalidateSelf();
  }
}
