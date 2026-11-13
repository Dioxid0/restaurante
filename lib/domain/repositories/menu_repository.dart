import '../entities/mesa.dart';
import '../entities/platillo.dart';

abstract interface class MenuRepository {
  /// Todos los platillos (disponibles y agotados), por categoría y nombre.
  Future<List<Platillo>> platillos();

  /// Solo el gerente (lo exige la base). Lanza [ErrorDeNegocio] con el motivo si falla.
  Future<void> crear({
    required String nombre,
    required double precio,
    required CategoriaPlatillo categoria,
    required bool disponible,
  });

  Future<void> actualizar(
    int idPlatillo, {
    required String nombre,
    required double precio,
    required CategoriaPlatillo categoria,
    required bool disponible,
  });

  /// Solo si el platillo nunca se ha pedido; si no, la base lo rechaza (usa "no disponible").
  Future<void> eliminar(int idPlatillo);
}

abstract interface class MesaRepository {
  /// Todas las mesas (libres y ocupadas), por número.
  Future<List<Mesa>> mesas();

  /// Solo el gerente (lo exige la base). Lanza [ErrorDeNegocio] con el motivo si falla.
  Future<void> crear({required int numeroMesa, required int capacidad});

  Future<void> actualizar(int idMesa, {required int numeroMesa, required int capacidad});

  /// Solo si la mesa nunca se ha usado en un pedido.
  Future<void> eliminar(int idMesa);
}
