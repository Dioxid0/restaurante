import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/entities/pedido.dart';
import '../domain/entities/pedido_detalle.dart';
import '../domain/errors.dart';
import '../domain/repositories/pedido_repository.dart';

class SupabasePedidoRepository implements PedidoRepository {
  SupabasePedidoRepository(this._client);
  final SupabaseClient _client;

  static const _columnas =
      'folio, folio_dia, hora_ingreso, tipo_pedido, origen, estado, total, '
      'mesa:id_mesa(numero_mesa), mesero:empleado!pedido_id_empleado_fkey(nombre), '
      'cliente:id_cliente(nombre)';

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

  List<Map<String, dynamic>> _itemsAJson(List<ItemPedido> items) => [
        for (final i in items)
          {
            'id_platillo': i.idPlatillo,
            'cantidad': i.cantidad,
            'notas_especiales': (i.nota == null || i.nota!.trim().isEmpty) ? null : i.nota!.trim(),
          },
      ];

  @override
  Future<int> crearPedido({
    required TipoPedido tipo,
    required List<ItemPedido> items,
    int? idMesa,
  }) async {
    try {
      final folio = await _client.rpc('crear_pedido', params: {
        'p_tipo_pedido': tipo.valorBd,
        'p_id_mesa': idMesa,
        'p_items': _itemsAJson(items),
      });
      return (folio as num).toInt();
    } on PostgrestException catch (e) {
      throw ErrorDeNegocio(e.message);
    }
  }

  @override
  Future<PedidoDetalle> obtenerPedido(int folio) async {
    try {
      final f = await _client
          .from('pedido')
          .select('folio, folio_dia, tipo_pedido, origen, estado, id_mesa, total, descuento, '
              'es_cortesia, motivo_descuento, mesa:id_mesa(numero_mesa), '
              'mesero:empleado!pedido_id_empleado_fkey(nombre), '
              'cliente:id_cliente(nombre), '
              'detalle_pedido(id_detalle, id_platillo, cantidad, precio_unitario, '
              'notas_especiales, platillo:id_platillo(nombre))')
          .eq('folio', folio)
          .single();
      final renglones = [...(f['detalle_pedido'] as List)]
        ..sort((a, b) => (a['id_detalle'] as int).compareTo(b['id_detalle'] as int));
      return PedidoDetalle(
        folio: f['folio'] as int,
        folioDia: f['folio_dia'] as int,
        tipo: TipoPedido.desdeBd(f['tipo_pedido'] as String),
        estado: EstadoPedido.desdeBd(f['estado'] as String),
        idMesa: f['id_mesa'] as int?,
        numeroMesa: (f['mesa'] as Map<String, dynamic>?)?['numero_mesa'] as int?,
        nombreMesero: (f['mesero'] as Map<String, dynamic>?)?['nombre'] as String?,
        nombreCliente: (f['cliente'] as Map<String, dynamic>?)?['nombre'] as String?,
        esEnLinea: f['origen'] == 'en_linea',
        total: (f['total'] as num).toDouble(),
        descuento: (f['descuento'] as num).toDouble(),
        esCortesia: f['es_cortesia'] as bool,
        motivoDescuento: f['motivo_descuento'] as String?,
        lineas: [
          for (final r in renglones)
            LineaPedido(
              idPlatillo: r['id_platillo'] as int,
              nombre: (r['platillo'] as Map<String, dynamic>)['nombre'] as String,
              precioUnitario: (r['precio_unitario'] as num).toDouble(),
              cantidad: r['cantidad'] as int,
              nota: r['notas_especiales'] as String?,
            ),
        ],
      );
    } on PostgrestException catch (e) {
      throw ErrorDeNegocio(e.message);
    }
  }

  @override
  Future<void> actualizarPedido({
    required int folio,
    required TipoPedido tipo,
    required List<ItemPedido> items,
    int? idMesa,
  }) async {
    try {
      await _client.rpc('actualizar_pedido', params: {
        'p_folio': folio,
        'p_tipo_pedido': tipo.valorBd,
        'p_id_mesa': idMesa,
        'p_items': _itemsAJson(items),
      });
    } on PostgrestException catch (e) {
      throw ErrorDeNegocio(e.message);
    }
  }

  @override
  Future<void> aplicarDescuento({
    required int folio,
    required double monto,
    required bool esCortesia,
    required String motivo,
  }) async {
    try {
      await _client.rpc('aplicar_descuento', params: {
        'p_folio': folio,
        'p_monto': monto,
        'p_es_cortesia': esCortesia,
        'p_motivo': motivo,
      });
    } on PostgrestException catch (e) {
      throw ErrorDeNegocio(e.message);
    }
  }

  @override
  Future<void> cancelarPedido(int folio, String motivo) async {
    try {
      await _client
          .from('pedido')
          .update({'estado': EstadoPedido.cancelado.valorBd, 'motivo_cancelacion': motivo})
          .eq('folio', folio);
    } on PostgrestException catch (e) {
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
      nombreCliente: (f['cliente'] as Map<String, dynamic>?)?['nombre'] as String?,
    );
  }
}
