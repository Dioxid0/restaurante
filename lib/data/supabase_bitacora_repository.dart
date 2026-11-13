import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/entities/entrada_bitacora.dart';
import '../domain/errors.dart';
import '../domain/repositories/bitacora_repository.dart';

class SupabaseBitacoraRepository implements BitacoraRepository {
  SupabaseBitacoraRepository(this._client);
  final SupabaseClient _client;

  @override
  Future<List<EntradaBitacora>> recientes({String? tabla, int limite = 100}) async {
    try {
      final r = await _client.rpc('bitacora_gerencial', params: {'p_tabla': tabla, 'p_limite': limite});
      return ((r as List?) ?? const []).map((e) {
        final m = Map<String, dynamic>.from(e as Map);
        final cambios = m['cambios'];
        return EntradaBitacora(
          id: (m['id'] as num).toInt(),
          fechaHora: DateTime.parse(m['fecha_hora'] as String).toLocal(),
          tabla: m['tabla'] as String,
          accion: m['accion'] as String,
          idRegistro: m['id_registro'] as String?,
          rol: m['rol'] as String?,
          empleado: m['empleado'] as String?,
          cambios: cambios is Map ? Map<String, dynamic>.from(cambios) : null,
        );
      }).toList();
    } on PostgrestException catch (e) {
      throw ErrorDeNegocio(e.message);
    }
  }
}
