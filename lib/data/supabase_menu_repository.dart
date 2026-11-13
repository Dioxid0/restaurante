import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/entities/mesa.dart';
import '../domain/entities/platillo.dart';
import '../domain/repositories/menu_repository.dart';
import 'errores_bd.dart';

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

  static const _repetido = 'Ya existe un platillo con ese nombre';
  static const _enUso = 'Este platillo ya aparece en pedidos y no se puede borrar: márcalo como no disponible';

  Map<String, dynamic> _datos(String nombre, double precio, CategoriaPlatillo categoria, bool disponible) => {
        'nombre': nombre.trim(),
        'precio': precio,
        'categoria': categoria.valorBd,
        'disponible': disponible,
      };

  @override
  Future<void> crear({
    required String nombre,
    required double precio,
    required CategoriaPlatillo categoria,
    required bool disponible,
  }) async {
    try {
      await _client.from('platillo').insert(_datos(nombre, precio, categoria, disponible));
    } on PostgrestException catch (e) {
      throw errorDeBd(e, repetido: _repetido);
    }
  }

  @override
  Future<void> actualizar(
    int idPlatillo, {
    required String nombre,
    required double precio,
    required CategoriaPlatillo categoria,
    required bool disponible,
  }) async {
    try {
      await _client
          .from('platillo')
          .update(_datos(nombre, precio, categoria, disponible))
          .eq('id_platillo', idPlatillo);
    } on PostgrestException catch (e) {
      throw errorDeBd(e, repetido: _repetido);
    }
  }

  @override
  Future<void> eliminar(int idPlatillo) async {
    try {
      await _client.from('platillo').delete().eq('id_platillo', idPlatillo);
    } on PostgrestException catch (e) {
      throw errorDeBd(e, enUso: _enUso);
    }
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

  static const _repetida = 'Ya existe una mesa con ese número';
  static const _enUso = 'Esta mesa ya tiene pedidos registrados y no se puede borrar';

  @override
  Future<void> crear({required int numeroMesa, required int capacidad}) async {
    try {
      await _client.from('mesa').insert({'numero_mesa': numeroMesa, 'capacidad': capacidad});
    } on PostgrestException catch (e) {
      throw errorDeBd(e, repetido: _repetida);
    }
  }

  @override
  Future<void> actualizar(int idMesa, {required int numeroMesa, required int capacidad}) async {
    try {
      await _client
          .from('mesa')
          .update({'numero_mesa': numeroMesa, 'capacidad': capacidad}).eq('id_mesa', idMesa);
    } on PostgrestException catch (e) {
      throw errorDeBd(e, repetido: _repetida);
    }
  }

  @override
  Future<void> eliminar(int idMesa) async {
    try {
      await _client.from('mesa').delete().eq('id_mesa', idMesa);
    } on PostgrestException catch (e) {
      throw errorDeBd(e, enUso: _enUso);
    }
  }
}
