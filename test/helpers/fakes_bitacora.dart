import 'package:restaurant_app/domain/entities/entrada_bitacora.dart';
import 'package:restaurant_app/domain/repositories/bitacora_repository.dart';

EntradaBitacora entradaDePrueba({
  int id = 1,
  String tabla = 'pedido',
  String accion = 'UPDATE',
  String? empleado = 'Juan Pérez',
  String? rol = 'mesero',
  Map<String, dynamic>? cambios,
}) =>
    EntradaBitacora(
      id: id,
      fechaHora: DateTime(2026, 11, 12, 14, 5),
      tabla: tabla,
      accion: accion,
      idRegistro: '$id',
      rol: rol,
      empleado: empleado,
      cambios: cambios ??
          (accion == 'UPDATE'
              ? {
                  'estado': {'antes': 'pendiente', 'despues': 'en_preparacion'}
                }
              : {'nombre': 'Flan'}),
    );

/// Bitácora falsa: guarda las tablas pedidas para comprobar el filtro.
class FakeBitacoraRepository implements BitacoraRepository {
  FakeBitacoraRepository([List<EntradaBitacora>? entradas]) : entradas = entradas ?? [];
  final List<EntradaBitacora> entradas;
  final filtros = <String?>[];

  @override
  Future<List<EntradaBitacora>> recientes({String? tabla, int limite = 100}) async {
    filtros.add(tabla);
    return entradas.where((e) => tabla == null || e.tabla == tabla).toList();
  }
}
