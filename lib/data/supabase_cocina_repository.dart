import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/entities/cocina.dart';
import '../domain/entities/pedido.dart';
import '../domain/errors.dart';
import '../domain/repositories/cocina_repository.dart';

class SupabaseCocinaRepository implements CocinaRepository {
  SupabaseCocinaRepository(this._client);
  final SupabaseClient _client;

  static const _estadosDeCocina = ['pendiente', 'en_preparacion', 'listo'];

  @override
  Future<List<PedidoCocina>> pedidos() async {
    try {
      final filas = await _client
          .from('pedido')
          .select('folio, folio_dia, hora_ingreso, tipo_pedido, origen, estado, '
              'mesa:id_mesa(numero_mesa), '
              'detalle_pedido(id_detalle, cantidad, notas_especiales, platillo:id_platillo(nombre))')
          .eq('fecha_operativa', _hoy())
          .inFilter('estado', _estadosDeCocina)
          .order('hora_ingreso', ascending: true);
      return filas.map(_aPedido).toList();
    } on PostgrestException catch (e) {
      throw ErrorDeNegocio(e.message);
    }
  }

  @override
  Future<List<AvisoCocina>> avisosPendientes() async {
    try {
      final filas = await _client
          .from('notificacion_cocina')
          .select('id_notificacion, hora_emision, mensaje, tipo_evento, folio')
          .eq('atendida', false)
          .order('hora_emision', ascending: false)
          .limit(30);
      return filas
          .map((f) => AvisoCocina(
                idNotificacion: f['id_notificacion'] as int,
                hora: DateTime.parse(f['hora_emision'] as String).toLocal(),
                mensaje: f['mensaje'] as String,
                tipo: TipoAviso.desdeBd(f['tipo_evento'] as String),
                folio: f['folio'] as int,
              ))
          .toList();
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
        // Un mismo canal escucha los pedidos y los avisos: cualquier cambio recarga el tablero.
        canal = _client
            .channel('cocina-cambios-${DateTime.now().microsecondsSinceEpoch}')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'pedido',
              callback: (_) => controlador.add(null),
            )
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'notificacion_cocina',
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
  Future<void> marcarAtendido(int idNotificacion) async {
    try {
      await _client
          .from('notificacion_cocina')
          .update({'atendida': true}).eq('id_notificacion', idNotificacion);
    } on PostgrestException catch (e) {
      throw ErrorDeNegocio(e.message);
    }
  }

  @override
  Future<void> marcarTodosAtendidos() async {
    try {
      await _client.from('notificacion_cocina').update({'atendida': true}).eq('atendida', false);
    } on PostgrestException catch (e) {
      throw ErrorDeNegocio(e.message);
    }
  }

  /// Fecha operativa de hoy (yyyy-MM-dd) según el reloj del equipo.
  String _hoy() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  PedidoCocina _aPedido(Map<String, dynamic> f) {
    final renglones = [...(f['detalle_pedido'] as List)]
      ..sort((a, b) => (a['id_detalle'] as int).compareTo(b['id_detalle'] as int));
    return PedidoCocina(
      folio: f['folio'] as int,
      folioDia: f['folio_dia'] as int,
      horaIngreso: DateTime.parse(f['hora_ingreso'] as String).toLocal(),
      tipo: TipoPedido.desdeBd(f['tipo_pedido'] as String),
      estado: EstadoPedido.desdeBd(f['estado'] as String),
      esEnLinea: f['origen'] == 'en_linea',
      numeroMesa: (f['mesa'] as Map<String, dynamic>?)?['numero_mesa'] as int?,
      renglones: [
        for (final r in renglones)
          RenglonCocina(
            nombre: (r['platillo'] as Map<String, dynamic>)['nombre'] as String,
            cantidad: r['cantidad'] as int,
            nota: r['notas_especiales'] as String?,
          ),
      ],
    );
  }
}
