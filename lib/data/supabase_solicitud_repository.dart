import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/entities/solicitud_cambio.dart';
import '../domain/errors.dart';
import '../domain/repositories/solicitud_repository.dart';

class SupabaseSolicitudRepository implements SolicitudRepository {
  SupabaseSolicitudRepository(this._client);
  final SupabaseClient _client;

  @override
  Future<List<SolicitudCambio>> deHoy() async {
    try {
      final filas = await _client
          .from('solicitud_cambio')
          // `solicitud_cambio` tiene dos FK hacia `empleado`: se indica cuál es el mesero.
          // `pedido!inner` + filtro: solo solicitudes de pedidos de hoy.
          .select('id_solicitud, fecha_solicitud, folio, tipo, motivo, estado, '
              'id_empleado_solicita, vigente_hasta, pedido!inner(folio_dia, fecha_operativa), '
              'mesero:empleado!solicitud_cambio_id_empleado_solicita_fkey(nombre)')
          .eq('pedido.fecha_operativa', _hoy())
          .order('fecha_solicitud', ascending: true);
      return filas.map(_aSolicitud).toList();
    } on PostgrestException catch (e) {
      throw ErrorDeNegocio(e.message);
    }
  }

  @override
  Stream<void> cambios() {
    late final StreamController<void> controlador;
    RealtimeChannel? canal;
    controlador = StreamController<void>(
      onListen: () {
        canal = _client
            .channel('solicitudes-cambios-${DateTime.now().microsecondsSinceEpoch}')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'solicitud_cambio',
              callback: (_) => controlador.add(null),
            )
            .subscribe();
      },
      onCancel: () async {
        final c = canal;
        if (c != null) await _client.removeChannel(c);
      },
    );
    return controlador.stream;
  }

  @override
  Future<void> solicitar(int folio, TipoSolicitud tipo, String motivo) async {
    try {
      await _client.rpc('solicitar_cambio', params: {
        'p_folio': folio,
        'p_tipo': tipo.valorBd,
        'p_motivo': motivo,
      });
    } on PostgrestException catch (e) {
      throw ErrorDeNegocio(e.message);
    }
  }

  @override
  Future<void> resolver(int idSolicitud, {required bool aprobar}) async {
    try {
      await _client.rpc('resolver_solicitud', params: {
        'p_id': idSolicitud,
        'p_aprobar': aprobar,
      });
    } on PostgrestException catch (e) {
      throw ErrorDeNegocio(e.message);
    }
  }

  /// Fecha operativa de hoy (yyyy-MM-dd) según el reloj del equipo.
  String _hoy() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  SolicitudCambio _aSolicitud(Map<String, dynamic> f) {
    final vigente = f['vigente_hasta'] as String?;
    return SolicitudCambio(
      idSolicitud: f['id_solicitud'] as int,
      folio: f['folio'] as int,
      folioDia: (f['pedido'] as Map<String, dynamic>)['folio_dia'] as int,
      tipo: TipoSolicitud.desdeBd(f['tipo'] as String),
      motivo: f['motivo'] as String,
      estado: EstadoSolicitud.desdeBd(f['estado'] as String),
      fecha: DateTime.parse(f['fecha_solicitud'] as String).toLocal(),
      idEmpleadoSolicita: f['id_empleado_solicita'] as int,
      nombreMesero: (f['mesero'] as Map<String, dynamic>?)?['nombre'] as String?,
      vigenteHasta: vigente == null ? null : DateTime.parse(vigente).toLocal(),
    );
  }
}
