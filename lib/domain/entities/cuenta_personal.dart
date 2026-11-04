import 'package:freezed_annotation/freezed_annotation.dart';

import 'perfil.dart';

part 'cuenta_personal.freezed.dart';

/// Fila de la lista de cuentas de personal (pantalla Gerencia).
@freezed
abstract class CuentaPersonal with _$CuentaPersonal {
  const factory CuentaPersonal({
    required int idEmpleado,
    required String nombre,
    required String usuario,
    required RolUsuario rol,
    required bool activo,
    String? turno,
  }) = _CuentaPersonal;
}
