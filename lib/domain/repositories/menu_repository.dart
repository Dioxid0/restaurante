import '../entities/mesa.dart';
import '../entities/platillo.dart';

abstract interface class MenuRepository {
  /// Todos los platillos (disponibles y agotados), por categoría y nombre.
  Future<List<Platillo>> platillos();
}

abstract interface class MesaRepository {
  /// Todas las mesas (libres y ocupadas), por número.
  Future<List<Mesa>> mesas();
}
