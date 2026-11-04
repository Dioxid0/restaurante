import 'package:freezed_annotation/freezed_annotation.dart';

part 'perfil.freezed.dart';

/// Rol dentro de la aplicación. Lo decide la base de datos, nunca el cliente.
enum RolUsuario {
  mesero('Mesero'),
  chef('Chef'),
  gerente('Gerente'),
  cliente('Cliente');

  const RolUsuario(this.etiqueta);
  final String etiqueta;

  bool get esPersonal => this != cliente;

  static RolUsuario desdeBd(String valor) =>
      RolUsuario.values.firstWhere((r) => r.name == valor);
}

/// Quién tiene la sesión abierta: un empleado o un cliente.
@freezed
abstract class Perfil with _$Perfil {
  const factory Perfil({
    /// id_empleado (personal) o id_cliente (cliente).
    required int id,
    required String nombre,
    required RolUsuario rol,
    String? usuario,
    String? correo,
    String? turno,
  }) = _Perfil;
}
