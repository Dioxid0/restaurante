import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/entities/pedido.dart';
import '../domain/entities/reporte_gerencial.dart';
import '../domain/errors.dart';
import '../domain/repositories/reporte_repository.dart';

class SupabaseReporteRepository implements ReporteRepository {
  SupabaseReporteRepository(this._client);
  final SupabaseClient _client;

  @override
  Future<ReporteGerencial> generar(DateTime desde, DateTime hasta) async {
    try {
      final r = await _client.rpc('reporte_gerencial', params: {
        'p_desde': _fecha(desde),
        'p_hasta': _fecha(hasta),
      });
      return _aReporte(Map<String, dynamic>.from(r as Map));
    } on PostgrestException catch (e) {
      throw ErrorDeNegocio(e.message);
    }
  }

  static String _fecha(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static double _n(Object? v) => (v as num?)?.toDouble() ?? 0;
  static int _i(Object? v) => (v as num?)?.toInt() ?? 0;
  static DateTime _d(Object? v) => DateTime.parse(v as String);
  static List<Map<String, dynamic>> _lista(Object? v) =>
      ((v as List?) ?? const []).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  static Map<String, dynamic> _mapa(Object? v) => Map<String, dynamic>.from((v as Map?) ?? const {});

  static List<VentaPorClave> _claves(Object? v) => _lista(v)
      .map((m) => VentaPorClave(clave: m['clave'] as String, pedidos: _i(m['pedidos']), ventas: _n(m['ventas'])))
      .toList();

  static ReporteGerencial _aReporte(Map<String, dynamic> j) {
    final canc = _mapa(j['cancelaciones']);
    final desc = _mapa(j['descuentos']);
    final d = _mapa(desc['descuentos']);
    final c = _mapa(desc['cortesias']);
    return ReporteGerencial(
      desde: _d(j['desde']),
      hasta: _d(j['hasta']),
      pedidosTotal: _i(j['pedidos_total']),
      pedidosValidos: _i(j['pedidos_validos']),
      ventas: _n(j['ventas']),
      ventasBrutas: _n(j['ventas_brutas']),
      ticketPromedio: _n(j['ticket_promedio']),
      porEstado: {
        for (final e in _mapa(j['por_estado']).entries) EstadoPedido.desdeBd(e.key): _i(e.value),
      },
      porTipo: _claves(j['por_tipo']),
      porOrigen: _claves(j['por_origen']),
      topPlatillos: _lista(j['top_platillos'])
          .map((m) => PlatilloVendido(
                nombre: m['nombre'] as String,
                cantidad: _i(m['cantidad']),
                importe: _n(m['importe']),
              ))
          .toList(),
      porDia: _lista(j['por_dia'])
          .map((m) => VentaDia(fecha: _d(m['fecha']), pedidos: _i(m['pedidos']), ventas: _n(m['ventas'])))
          .toList(),
      cancelacionesCantidad: _i(canc['cantidad']),
      cancelacionesPerdida: _n(canc['perdida']),
      cancelaciones: _lista(canc['lista'])
          .map((m) => CancelacionReporte(
                folioDia: _i(m['folio_dia']),
                fecha: _d(m['fecha']),
                motivo: m['motivo'] as String,
                costoPerdida: _n(m['costo_perdida']),
                canceladoPor: m['cancelado_por'] as String?,
              ))
          .toList(),
      descuentosPedidos: _i(d['pedidos']),
      descuentosMonto: _n(d['monto']),
      cortesiasPedidos: _i(c['pedidos']),
      cortesiasMonto: _n(c['monto']),
      descuentos: _lista(desc['lista'])
          .map((m) => DescuentoReporte(
                folioDia: _i(m['folio_dia']),
                fecha: _d(m['fecha']),
                esCortesia: m['es_cortesia'] as bool? ?? false,
                monto: _n(m['monto']),
                motivo: m['motivo'] as String?,
              ))
          .toList(),
    );
  }
}
