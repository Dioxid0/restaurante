import 'package:freezed_annotation/freezed_annotation.dart';

part 'platillo.freezed.dart';

/// Categorías del menú (deben coincidir con el CHECK de `platillo.categoria`).
enum CategoriaPlatillo {
  bebidas('Bebidas'),
  antojitos('Antojitos/Entradas'),
  platosFuertes('Platos Fuertes'),
  postres('Postres'),
  especialidades('Especialidades');

  const CategoriaPlatillo(this.valorBd);

  /// Texto guardado en la base y mostrado en las pestañas.
  final String valorBd;

  static CategoriaPlatillo desdeBd(String valor) =>
      CategoriaPlatillo.values.firstWhere((c) => c.valorBd == valor);
}

@freezed
abstract class Platillo with _$Platillo {
  const factory Platillo({
    required int idPlatillo,
    required String nombre,
    required double precio,
    required CategoriaPlatillo categoria,
    required bool disponible,

    /// null => la app muestra un ícono de la categoría.
    String? imagenUrl,
  }) = _Platillo;
}
