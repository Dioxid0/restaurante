import 'package:restaurant_app/domain/entities/pedido.dart';
import 'package:restaurant_app/domain/entities/reporte_gerencial.dart';
import 'package:restaurant_app/domain/errors.dart';
import 'package:restaurant_app/domain/repositories/reporte_repository.dart';

/// Reporte de ejemplo: 3 pedidos válidos y 1 cancelado.
ReporteGerencial reporteDePrueba({DateTime? desde, DateTime? hasta, bool vacio = false}) {
  final d = desde ?? DateTime(2026, 11, 12);
  final h = hasta ?? d;
  if (vacio) {
    return ReporteGerencial(
      desde: d, hasta: h, pedidosTotal: 0, pedidosValidos: 0, ventas: 0, ventasBrutas: 0,
      ticketPromedio: 0, porEstado: const {}, porTipo: const [], porOrigen: const [],
      topPlatillos: const [], porDia: const [], cancelacionesCantidad: 0,
      cancelacionesPerdida: 0, cancelaciones: const [], descuentosPedidos: 0,
      descuentosMonto: 0, cortesiasPedidos: 0, cortesiasMonto: 0, descuentos: const [],
    );
  }
  return ReporteGerencial(
    desde: d,
    hasta: h,
    pedidosTotal: 4,
    pedidosValidos: 3,
    ventas: 1000,
    ventasBrutas: 1100,
    ticketPromedio: 333.33,
    porEstado: const {
      EstadoPedido.completado: 2,
      EstadoPedido.pendiente: 1,
      EstadoPedido.cancelado: 1,
    },
    porTipo: const [
      VentaPorClave(clave: 'en_mesa', pedidos: 2, ventas: 700),
      VentaPorClave(clave: 'para_llevar', pedidos: 1, ventas: 300),
    ],
    porOrigen: const [
      VentaPorClave(clave: 'en_linea', pedidos: 1, ventas: 300),
      VentaPorClave(clave: 'mesero', pedidos: 2, ventas: 700),
    ],
    topPlatillos: const [
      PlatilloVendido(nombre: 'Tacos al pastor', cantidad: 9, importe: 450),
      PlatilloVendido(nombre: 'Flan', cantidad: 3, importe: 120),
    ],
    porDia: h == d
        ? const []
        : [
            VentaDia(fecha: d, pedidos: 1, ventas: 400),
            VentaDia(fecha: h, pedidos: 2, ventas: 600),
          ],
    cancelacionesCantidad: 1,
    cancelacionesPerdida: 85,
    cancelaciones: [
      CancelacionReporte(
        folioDia: 4, fecha: d, motivo: 'El cliente se fue', costoPerdida: 85, canceladoPor: 'mesero'),
    ],
    descuentosPedidos: 1,
    descuentosMonto: 60,
    cortesiasPedidos: 1,
    cortesiasMonto: 40,
    descuentos: [
      DescuentoReporte(folioDia: 2, fecha: d, esCortesia: false, monto: 60, motivo: 'Cliente frecuente'),
      DescuentoReporte(folioDia: 3, fecha: d, esCortesia: true, monto: 40, motivo: 'Error de cocina'),
    ],
  );
}

/// Repositorio falso del reporte gerencial: guarda los rangos pedidos.
class FakeReporteRepository implements ReporteRepository {
  FakeReporteRepository({this.vacio = false, this.error});

  final bool vacio;
  final String? error;
  final pedidos = <(DateTime, DateTime)>[];

  @override
  Future<ReporteGerencial> generar(DateTime desde, DateTime hasta) async {
    pedidos.add((desde, hasta));
    if (error != null) throw ErrorDeNegocio(error!);
    return reporteDePrueba(desde: desde, hasta: hasta, vacio: vacio);
  }
}
