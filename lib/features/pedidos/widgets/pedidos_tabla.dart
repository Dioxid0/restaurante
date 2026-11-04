import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formato.dart';
import '../../../domain/entities/pedido.dart';
import 'pedido_chips.dart';

typedef AlCambiarEstado = void Function(PedidoResumen pedido, EstadoPedido nuevo);

/// Tabla de comandas (encabezado + filas). Las filas se pasan ya paginadas.
class PedidosTabla extends StatelessWidget {
  const PedidosTabla({
    super.key,
    required this.pedidos,
    required this.ahora,
    required this.alCambiarEstado,
    required this.alEditar,
    required this.alVer,
    this.puedeOperar = true,
  });

  final List<PedidoResumen> pedidos;
  final DateTime ahora;

  /// Mesero y gerente operan pedidos (editar, entregar, completar); el chef solo los consulta.
  final bool puedeOperar;
  final AlCambiarEstado alCambiarEstado;
  final ValueChanged<PedidoResumen> alEditar;
  final ValueChanged<PedidoResumen> alVer;

  // Anchos relativos de las columnas.
  static const _flex = [12, 12, 14, 8, 15, 16, 12, 18];

  /// Ancho mínimo para que las columnas no se aprieten; si la ventana es
  /// más angosta la tabla se desplaza horizontalmente.
  static const _anchoMinimo = 1000.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final contenido = _contenido();
        if (c.maxWidth >= _anchoMinimo) return contenido;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(width: _anchoMinimo, child: contenido),
        );
      },
    );
  }

  Widget _contenido() {
    return Column(
      children: [
        _fila(
          fondo: const Color(0xFFF8FAFC),
          alto: 40,
          celdas: const [
            _Encabezado('FOLIO'),
            _Encabezado('HORA'),
            _Encabezado('TIPO DE PEDIDO'),
            _Encabezado('MESA'),
            _Encabezado('MESERO'),
            _Encabezado('ESTADO'),
            _Encabezado('TOTAL'),
            _Encabezado('ACCIONES', alinearDerecha: true),
          ],
        ),
        if (pedidos.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Text(
              'No hay pedidos con estos filtros',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
        for (final p in pedidos) _filaPedido(p),
      ],
    );
  }

  Widget _filaPedido(PedidoResumen p) {
    final minutos = ahora.difference(p.horaIngreso).inMinutes;
    return _fila(
      fondo: p.estado == EstadoPedido.pendiente ? AppColors.amberRow : Colors.white,
      alto: 54,
      celdas: [
        Text(
          p.folioEtiqueta,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formatoHora(p.horaIngreso),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
            ),
            if (p.estado.esActivo) ...[
              const SizedBox(height: 3),
              TiempoChip(minutos: minutos < 0 ? 0 : minutos),
            ],
          ],
        ),
        Align(alignment: Alignment.centerLeft, child: TipoPedidoIcono(p.tipo)),
        Text(
          p.mesaEtiqueta ?? '—',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5),
        ),
        Text(
          p.nombreMesero ?? (p.esEnLinea ? 'En línea' : '—'),
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5),
          overflow: TextOverflow.ellipsis,
        ),
        Align(alignment: Alignment.centerLeft, child: EstadoChip(p.estado)),
        Text(
          formatoMoneda(p.total),
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (puedeOperar && p.estado == EstadoPedido.pendiente) ...[
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
              const SizedBox(width: 6),
            ],
            if (puedeOperar && p.estado == EstadoPedido.listo) ...[
              BotonIcono(
                icono: Icons.check_circle_outline,
                tooltip: 'Marcar como entregado',
                color: const Color(0xFF2563EB),
                fondo: const Color(0xFFEFF6FF),
                borde: const Color(0xFFBFDBFE),
                alPresionar: () => alCambiarEstado(p, EstadoPedido.entregado),
              ),
              const SizedBox(width: 6),
            ],
            if (puedeOperar && p.estado == EstadoPedido.entregado) ...[
              BotonIcono(
                icono: Icons.check_circle_outline,
                tooltip: 'Marcar como completado',
                color: const Color(0xFF047857),
                fondo: const Color(0xFFECFDF5),
                borde: const Color(0xFF6EE7B7),
                alPresionar: () => alCambiarEstado(p, EstadoPedido.completado),
              ),
              const SizedBox(width: 6),
            ],
            BotonIcono(
              icono: Icons.visibility_outlined,
              tooltip: 'Ver detalle',
              alPresionar: () => alVer(p),
            ),
          ],
        ),
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
              flex: _flex[i],
              child: Align(alignment: Alignment.centerLeft, child: celdas[i]),
            ),
        ],
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
