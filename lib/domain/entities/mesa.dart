import 'package:freezed_annotation/freezed_annotation.dart';

part 'mesa.freezed.dart';

enum EstadoMesa {
  libre,
  ocupada,
  reservada;

  static EstadoMesa desdeBd(String valor) =>
      EstadoMesa.values.firstWhere((e) => e.name == valor);
}

@freezed
abstract class Mesa with _$Mesa {
  const Mesa._();

  const factory Mesa({
    required int idMesa,
    required int numeroMesa,
    required int capacidad,
    required EstadoMesa estado,
  }) = _Mesa;

  String get etiqueta => 'Mesa $numeroMesa';
}
