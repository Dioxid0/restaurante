import 'package:freezed_annotation/freezed_annotation.dart';

part 'empleado.freezed.dart';

enum RolEmpleado {
  mesero('Mesero'),
  chef('Chef'),
  gerente('Gerente');

  const RolEmpleado(this.etiqueta);
  final String etiqueta;

  static RolEmpleado desdeBd(String valor) =>
      RolEmpleado.values.firstWhere((r) => r.name == valor);
}

@freezed
abstract class Empleado with _$Empleado {
  const factory Empleado({
    required int idEmpleado,
    required String nombre,
    required RolEmpleado rol,
    required String usuario,
    String? turno,
  }) = _Empleado;
}
