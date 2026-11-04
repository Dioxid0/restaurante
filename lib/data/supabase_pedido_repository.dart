import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/entities/pedido.dart';
import '../domain/errors.dart';
import '../domain/repositories/pedido_repository.dart';

class SupabasePedidoRepository implements PedidoRepository {
  SupabasePedidoRepository(this._client);
  final SupabaseClient _client;

  static const _columnas =
      'folio, folio_dia, hora_ingreso, tipo_pedido, origen, estado, total, '
      'mesa:id_mesa(numero_mesa), mesero:empleado!pedido_id_empleado_fkey(nombre)';

  @override
  Future<List<PedidoResumen>> pedidosDelDia() async {
    final filas = await _client
        .from('pedido')
        .select(_columnas)
        .eq('fecha_operativa', _hoy())
        .order('hora_ingreso', ascending: false);
    return filas.map(_aPedido).toList();
  }

  @override
  Stream<void> cambios() {
    late final StreamController<void> controlador;
    RealtimeChannel? canal;
    controlador = StreamController<void>(
      onListen: () {
        canal = _client
            .channel('pedidos-cambios-${DateTime.now().microsecondsSinceEpoch}')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'pedido',
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
  Future<void> actualizarEstado(int folio, EstadoPedido nuevoEstado) async {
    try {
      await _client
          .from('pedido')
          .update({'estado': nuevoEstado.valorBd})
          .eq('folio', folio);
    } on PostgrestException catch (e) {
      // Los mensajes de las reglas (RN-03, etc.) vienen en español desde la base.
      throw ErrorDeNegocio(e.message);
    }
  }

  /// Fecha operativa de hoy (yyyy-MM-dd) según el reloj del equipo.
  String _hoy() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  PedidoResumen _aPedido(Map<String, dynamic> f) {
    final mesa = f['mesa'] as Map<String, dynamic>?;
    final mesero = f['mesero'] as Map<String, dynamic>?;
    return PedidoResumen(
      folio: f['folio'] as int,
      folioDia: f['folio_dia'] as int,
      horaIngreso: DateTime.parse(f['hora_ingreso'] as String).toLocal(),
      tipo: TipoPedido.desdeBd(f['tipo_pedido'] as String),
      estado: EstadoPedido.desdeBd(f['estado'] as String),
      total: (f['total'] as num).toDouble(),
      esEnLinea: f['origen'] == 'en_linea',
      numeroMesa: mesa?['numero_mesa'] as int?,
      nombreMesero: mesero?['nombre'] as String?,
    );
  }
}
