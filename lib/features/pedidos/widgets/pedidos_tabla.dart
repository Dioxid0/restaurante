import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formato.dart';
import '../../../domain/entities/pedido.dart';
import 'boton_confirmable.dart';
import 'pedido_chips.dart';

typedef AlCambiarEstado = void Function(PedidoResumen pedido, EstadoPedido nuevo);

void _ignorarEstado(PedidoResumen pedido, EstadoPedido nuevo) {}
void _ignorarPedido(PedidoResumen pedido) {}

/// Lista de comandas. Las filas se pasan ya paginadas.
///  * Escritorio / tablet: tabla de 6 columnas (el mesero va en gris bajo el folio).
///  * Pantallas angostas (< 700 px): una tarjeta por pedido.
///
/// Con [PedidosTabla.seguimiento] (el cliente) se muestra Folio, Hora, Estado, Total y una
/// sola acción: "Editar", solo en los pedidos pendientes (RN-03). Sin Mesa/Tipo ni mesero.
class PedidosTabla extends StatelessWidget {
  const PedidosTabla({
    super.key,
    required this.pedidos,
    required this.ahora,
    required this.alCambiarEstado,
    required this.alEditar,
    required this.alVer,
    this.puedeOperar = true,
  }) : soloSeguimiento = false;

  /// Vista del cliente: solo seguimiento (sin Mesa/Tipo, mesero ni acciones).
  const PedidosTabla.seguimiento({
    super.key,
    required this.pedidos,
    required this.ahora,
    required this.alEditar,
  })  : soloSeguimiento = true,
        puedeOperar = false,
        alCambiarEstado = _ignorarEstado,
        alVer = _ignorarPedido;

  final List<PedidoResumen> pedidos;
  final DateTime ahora;
  final bool soloSeguimiento;

  /// Mesero y gerente operan pedidos (editar, entregar, completar); el chef solo los consulta.
  final bool puedeOperar;
  final AlCambiarEstado alCambiarEstado;
  final ValueChanged<PedidoResumen> alEditar;
  final ValueChanged<PedidoResumen> alVer;

  /// Debajo de este ancho se usan tarjetas en vez de tabla.
  static const anchoTarjetas = 700.0;

  /// Ancho mínimo de la tabla; si la ventana es más angosta (pero < anchoTarjetas no ocurre) se desplaza.
  static const _anchoMinimo = 760.0;

  // Anchos relativos de las 6 columnas: folio, hora, mesa/tipo, estado, total, acciones.
  static const _flex = [16, 12, 15, 18, 12, 27];

  // Vista del cliente: folio, hora, estado, total, acciones (solo "Editar").
  static const _flexSeguimiento = [18, 18, 26, 16, 22];

  List<int> get _anchos => soloSeguimiento ? _flexSeguimiento : _flex;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth < anchoTarjetas) return _tarjetas();
        final contenido = _tabla();
        if (c.maxWidth >= _anchoMinimo) return contenido;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(width: _anchoMinimo, child: contenido),
        );
      },
    );
  }

  // ---------------------------------------------------------------- tabla

  Widget _tabla() {
    return Column(
      children: [
        _fila(
          fondo: const Color(0xFFF8FAFC),
          alto: 40,
          celdas: [
            const _Encabezado('FOLIO'),
            const _Encabezado('HORA'),
            if (!soloSeguimiento) const _Encabezado('MESA / TIPO'),
            const _Encabezado('ESTADO'),
            const _Encabezado('TOTAL'),
            const _Encabezado('ACCIONES', alinearDerecha: true),
          ],
        ),
        if (pedidos.isEmpty) const _SinResultados(),
        for (final p in pedidos) _filaPedido(p),
      ],
    );
  }

  Widget _filaPedido(PedidoResumen p) {
    return _fila(
      fondo: p.estado == EstadoPedido.pendiente ? AppColors.amberRow : Colors.white,
      alto: 58,
      celdas: [
        _Folio(p, mostrarMesero: !soloSeguimiento),
        _Hora(p, ahora),
        if (!soloSeguimiento) _MesaTipo(p),
        EstadoChip(p.estado),
        Text(
          formatoMoneda(p.total),
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
        ),
        Align(alignment: Alignment.centerRight, child: _acciones(p)),
      ],
    );
  }

  Widget _fila({
    required Color fondo,
    required double alto,
    required List<Widget> celdas,
  }) {
    return Container(
      height: alto,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: fondo,
        border: const Border(top: BorderSide(color: AppColors.borderSoft)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < celdas.length; i++)
            Expanded(
              flex: _anchos[i],
              child: Align(alignment: Alignment.centerLeft, child: celdas[i]),
            ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------ tarjetas

  Widget _tarjetas() {
    if (pedidos.isEmpty) return const _SinResultados();
    return Column(
      children: [
        for (final p in pedidos)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: BoxDecoration(
              color: p.estado == EstadoPedido.pendiente ? AppColors.amberRow : Colors.white,
              border: const Border(top: BorderSide(color: AppColors.borderSoft)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        p.folioEtiqueta,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                    ),
                    EstadoChip(p.estado),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (!soloSeguimiento) ...[_MesaTipo(p), const Spacer()],
                    _Hora(p, ahora, enLinea: true),
                    if (soloSeguimiento) const Spacer(),
                    if (soloSeguimiento)
                      Text(
                        formatoMoneda(p.total),
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                  ],
                ),
                if (soloSeguimiento && _puedeEditar(p)) ...[
                  const SizedBox(height: 10),
                  Align(alignment: Alignment.centerRight, child: _acciones(p)),
                ],
                if (!soloSeguimiento) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          p.nombreMesero ?? (p.esEnLinea ? 'En línea' : ''),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.textFaint, fontSize: 11.5),
                        ),
                      ),
                      Text(
                        formatoMoneda(p.total),
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Align(alignment: Alignment.centerRight, child: _acciones(p)),
                ],
              ],
            ),
          ),
      ],
    );
  }

  // ------------------------------------------------------------ acciones

  Widget _acciones(PedidoResumen p) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_puedeEditar(p)) ...[
          OutlinedButton.icon(
            onPressed: () => alEditar(p),
            icon: const Icon(Icons.edit_outlined, size: 15),
            label: const Text('Editar'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFB45309),
              backgroundColor: const Color(0xFFFFF7ED),
              side: const BorderSide(color: Color(0xFFFDBA74)),
              minimumSize: const Size(0, 34),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
            ),
          ),
          if (!soloSeguimiento) const SizedBox(width: 6),
        ],
        if (puedeOperar && p.estado == EstadoPedido.listo) ...[
          BotonConfirmable(
            icono: Icons.check_circle_outline,
            tooltip: 'Marcar como entregado',
            titulo: '¿Marcar como Entregado?',
            detalle: p.folioEtiqueta,
            color: const Color(0xFF2563EB),
            fondo: const Color(0xFFEFF6FF),
            borde: const Color(0xFFBFDBFE),
            alConfirmar: () => alCambiarEstado(p, EstadoPedido.entregado),
          ),
          const SizedBox(width: 6),
        ],
        if (puedeOperar && p.estado == EstadoPedido.entregado) ...[
          BotonConfirmable(
            icono: Icons.check_circle_outline,
            tooltip: 'Marcar como completado',
            titulo: '¿Marcar como Completado?',
            detalle: p.folioEtiqueta,
            color: const Color(0xFF047857),
            fondo: const Color(0xFFECFDF5),
            borde: const Color(0xFF6EE7B7),
            alConfirmar: () => alCambiarEstado(p, EstadoPedido.completado),
          ),
          const SizedBox(width: 6),
        ],
        if (!soloSeguimiento)
          BotonIcono(
            icono: Icons.visibility_outlined,
            tooltip: 'Ver detalle',
            alPresionar: () => alVer(p),
          ),
      ],
    );
  }

  /// "Editar": mesero/gerente en pedidos pendientes; el cliente también, y solo en los
  /// suyos pendientes (RN-03). La base de datos es la que lo exige de verdad.
  bool _puedeEditar(PedidoResumen p) =>
      (puedeOperar || soloSeguimiento) && p.estado == EstadoPedido.pendiente;
}

// ------------------------------------------------------------- celdas

/// "#PED-108" con el mesero en gris debajo.
class _Folio extends StatelessWidget {
  const _Folio(this.p, {this.mostrarMesero = true});
  final PedidoResumen p;
  final bool mostrarMesero;

  @override
  Widget build(BuildContext context) {
    final mesero = mostrarMesero ? (p.nombreMesero ?? (p.esEnLinea ? 'En línea' : null)) : null;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(p.folioEtiqueta, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
        if (mesero != null)
          Text(
            mesero,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textFaint, fontSize: 10.5),
          ),
      ],
    );
  }
}

/// Hora de ingreso + minutos transcurridos (solo pedidos activos).
class _Hora extends StatelessWidget {
  const _Hora(this.p, this.ahora, {this.enLinea = false});
  final PedidoResumen p;
  final DateTime ahora;

  /// true en tarjetas: hora y chip en la misma línea.
  final bool enLinea;

  @override
  Widget build(BuildContext context) {
    final minutos = ahora.difference(p.horaIngreso).inMinutes;
    final hora = Text(
      formatoHora(p.horaIngreso),
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
    );
    final chip = p.estado.esActivo ? TiempoChip(minutos: minutos < 0 ? 0 : minutos) : null;
    if (enLinea) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [hora, if (chip != null) ...[const SizedBox(width: 8), chip]],
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [hora, if (chip != null) ...[const SizedBox(height: 3), chip]],
    );
  }
}

/// Ícono del tipo (con tooltip) + mesa: "🍽 M-01" o "🛍 Llevar".
class _MesaTipo extends StatelessWidget {
  const _MesaTipo(this.p);
  final PedidoResumen p;

  @override
  Widget build(BuildContext context) {
    final texto = p.mesaEtiqueta ?? (p.tipo == TipoPedido.paraLlevar ? 'Llevar' : '—');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TipoPedidoIcono(p.tipo),
        const SizedBox(width: 8),
        Text(texto, style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
      ],
    );
  }
}

class _SinResultados extends StatelessWidget {
  const _SinResultados();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Text(
          'No hay pedidos con estos filtros',
          style: TextStyle(color: AppColors.textMuted),
        ),
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado(this.texto, {this.alinearDerecha = false});
  final String texto;
  final bool alinearDerecha;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Text(
        texto,
        textAlign: alinearDerecha ? TextAlign.right : TextAlign.left,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
