import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/entities/mesa.dart';
import '../domain/entities/platillo.dart';
import '../domain/repositories/menu_repository.dart';

class SupabaseMenuRepository implements MenuRepository {
  SupabaseMenuRepository(this._client);
  final SupabaseClient _client;

  @override
  Future<List<Platillo>> platillos() async {
    final filas = await _client
        .from('platillo')
        .select('id_platillo, nombre, precio, categoria, disponible, imagen_url')
        .order('nombre');
    return filas
        .map((f) => Platillo(
              idPlatillo: f['id_platillo'] as int,
              nombre: f['nombre'] as String,
              precio: (f['precio'] as num).toDouble(),
              categoria: CategoriaPlatillo.desdeBd(f['categoria'] as String),
              disponible: f['disponible'] as bool,
              imagenUrl: f['imagen_url'] as String?,
            ))
        .toList();
  }
}

class SupabaseMesaRepository implements MesaRepository {
  SupabaseMesaRepository(this._client);
  final SupabaseClient _client;

  @override
  Future<List<Mesa>> mesas() async {
    final filas = await _client
        .from('mesa')
        .select('id_mesa, numero_mesa, capacidad, estado')
        .order('numero_mesa');
    return filas
        .map((f) => Mesa(
              idMesa: f['id_mesa'] as int,
              numeroMesa: f['numero_mesa'] as int,
              capacidad: f['capacidad'] as int,
              estado: EstadoMesa.desdeBd(f['estado'] as String),
            ))
        .toList();
  }
}
