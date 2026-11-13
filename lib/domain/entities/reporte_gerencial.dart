import 'pedido.dart';

/// Pedidos y ventas agrupados por una clave (tipo de pedido u origen).
class VentaPorClave {
  const VentaPorClave({required this.clave, required this.pedidos, required this.ventas});
  final String clave;
  final int pedidos;
  final double ventas;
}

class PlatilloVendido {
  const PlatilloVendido({required this.nombre, required this.cantidad, required this.importe});
  final String nombre;
  final int cantidad;
  final double importe;
}

class VentaDia {
  const VentaDia({required this.fecha, required this.pedidos, required this.ventas});
  final DateTime fecha;
  final int pedidos;
  final double ventas;
}

class CancelacionReporte {
  const CancelacionReporte({
    required this.folioDia,
    required this.fecha,
    required this.motivo,
    required this.costoPerdida,
    this.canceladoPor,
  });
  final int folioDia;
  final DateTime fecha;
  final String motivo;
  final double costoPerdida;
  final String? canceladoPor;
}

class DescuentoReporte {
  const DescuentoReporte({
    required this.folioDia,
    required this.fecha,
    required this.esCortesia,
    required this.monto,
    this.motivo,
  });
  final int folioDia;
  final DateTime fecha;
  final bool esCortesia;
  final double monto;
  final String? motivo;
}

/// Reporte gerencial (CU-07) de un rango de fechas operativas.
/// "Venta" = pedido no cancelado (cobros y caja están fuera de alcance).
class ReporteGerencial {
  const ReporteGerencial({
    required this.desde,
    required this.hasta,
    required this.pedidosTotal,
    required this.pedidosValidos,
    required this.ventas,
    required this.ventasBrutas,
    required this.ticketPromedio,
    required this.porEstado,
    required this.porTipo,
    required this.porOrigen,
    required this.topPlatillos,
    required this.porDia,
    required this.cancelacionesCantidad,
    required this.cancelacionesPerdida,
    required this.cancelaciones,
    required this.descuentosPedidos,
    required this.descuentosMonto,
    required this.cortesiasPedidos,
    required this.cortesiasMonto,
    required this.descuentos,
  });

  final DateTime desde;
  final DateTime hasta;
  final int pedidosTotal;
  final int pedidosValidos;
  final double ventas;

  /// Ventas antes de descuentos y cortesías.
  final double ventasBrutas;
  final double ticketPromedio;
  final Map<EstadoPedido, int> porEstado;
  final List<VentaPorClave> porTipo;
  final List<VentaPorClave> porOrigen;
  final List<PlatilloVendido> topPlatillos;
  final List<VentaDia> porDia;
  final int cancelacionesCantidad;
  final double cancelacionesPerdida;
  final List<CancelacionReporte> cancelaciones;
  final int descuentosPedidos;
  final double descuentosMonto;
  final int cortesiasPedidos;
  final double cortesiasMonto;
  final List<DescuentoReporte> descuentos;

  bool get sinPedidos => pedidosTotal == 0;

  /// Lo que se dejó de cobrar por descuentos y cortesías.
  double get totalDescontado => descuentosMonto + cortesiasMonto;
}
