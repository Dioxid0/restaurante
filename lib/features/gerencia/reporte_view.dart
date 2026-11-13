import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formato.dart';
import '../../domain/entities/pedido.dart';
import '../../domain/entities/reporte_gerencial.dart';
import '../../domain/errors.dart';
import 'reporte_providers.dart';

/// Gerencia → Reporte (CU-07): ventas, pedidos, platillos, cancelaciones y descuentos.
/// (Diseño provisional hasta recibir la pantalla de Figma.)
class ReporteView extends ConsumerWidget {
  const ReporteView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periodo = ref.watch(periodoSeleccionadoProvider);
    final reporte = ref.watch(reporteGerencialProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 18, 28, 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'GERENCIA / REPORTE',
                style: TextStyle(
                  color: AppColors.amber,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              const Text('Reporte gerencial', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              const Text(
                'Ventas y operación del restaurante. Una venta es un pedido que no fue cancelado.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final p in PeriodoReporte.values)
                          ChoiceChip(
                            label: Text(p.etiqueta),
                            selected: p == periodo,
                            onSelected: (_) => ref.read(periodoSeleccionadoProvider.notifier).elegir(p),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Actualizar',
                    onPressed: () => ref.invalidate(reporteGerencialProvider),
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              reporte.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(60),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(48),
                  child: Center(
                    child: Column(
                      children: [
                        Text(mensajeDeError(e, porDefecto: 'No se pudo generar el reporte')),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () => ref.invalidate(reporteGerencialProvider),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (r) => _Contenido(reporte: r),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido({required this.reporte});
  final ReporteGerencial reporte;

  @override
  Widget build(BuildContext context) {
    final r = reporte;
    final mismoDia = r.desde == r.hasta;
    final rango = mismoDia ? formatoFecha(r.desde) : '${formatoFecha(r.desde)} – ${formatoFecha(r.hasta)}';

    if (r.sinPedidos) {
      return _Tarjeta(
        titulo: rango,
        hijo: const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text('No hay pedidos en este periodo', style: TextStyle(color: AppColors.textMuted)),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(rango, style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            _Kpi(titulo: 'VENTAS', valor: formatoMoneda(r.ventas), detalle: 'Ya con descuentos'),
            _Kpi(
              titulo: 'PEDIDOS',
              valor: '${r.pedidosValidos}',
              detalle: '${r.pedidosTotal} en total · ${r.cancelacionesCantidad} cancelados',
            ),
            _Kpi(titulo: 'TICKET PROMEDIO', valor: formatoMoneda(r.ticketPromedio), detalle: 'Por pedido'),
            _Kpi(
              titulo: 'PÉRDIDA POR CANCELACIONES',
              valor: formatoMoneda(r.cancelacionesPerdida),
              detalle: '${r.cancelacionesCantidad} cancelaciones',
              alerta: r.cancelacionesCantidad > 0,
            ),
          ],
        ),
        const SizedBox(height: 14),
        _Fila(hijos: [
          _Tarjeta(titulo: 'Pedidos por estado', hijo: _PorEstado(r.porEstado)),
          _Tarjeta(
            titulo: 'Ventas por tipo y origen',
            hijo: _PorClave(porTipo: r.porTipo, porOrigen: r.porOrigen),
          ),
        ]),
        const SizedBox(height: 14),
        _Fila(hijos: [
          _Tarjeta(titulo: 'Platillos más vendidos', hijo: _TopPlatillos(r.topPlatillos)),
          if (r.porDia.length > 1) _Tarjeta(titulo: 'Ventas por día', hijo: _PorDia(r.porDia)),
        ]),
        const SizedBox(height: 14),
        _Fila(hijos: [
          _Tarjeta(titulo: 'Descuentos y cortesías', hijo: _Descuentos(r)),
          _Tarjeta(titulo: 'Cancelaciones', hijo: _Cancelaciones(r.cancelaciones)),
        ]),
      ],
    );
  }
}

/// Tarjetas lado a lado en pantallas anchas; una debajo de otra en pantallas angostas.
class _Fila extends StatelessWidget {
  const _Fila({required this.hijos});
  final List<Widget> hijos;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      if (c.maxWidth < 900 || hijos.length == 1) {
        return Column(
          children: [
            for (var i = 0; i < hijos.length; i++) ...[
              if (i > 0) const SizedBox(height: 14),
              SizedBox(width: double.infinity, child: hijos[i]),
            ],
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < hijos.length; i++) ...[
            if (i > 0) const SizedBox(width: 14),
            Expanded(child: hijos[i]),
          ],
        ],
      );
    });
  }
}

class _Tarjeta extends StatelessWidget {
  const _Tarjeta({required this.titulo, required this.hijo});
  final String titulo;
  final Widget hijo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          hijo,
        ],
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({required this.titulo, required this.valor, required this.detalle, this.alerta = false});
  final String titulo;
  final String valor;
  final String detalle;
  final bool alerta;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            valor,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: alerta ? AppColors.danger : AppColors.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(detalle, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        ],
      ),
    );
  }
}

/// Fila "etiqueta ........ valor" con una barra proporcional opcional.
class _Linea extends StatelessWidget {
  const _Linea({required this.etiqueta, required this.valor, this.proporcion});
  final String etiqueta;
  final String valor;
  final double? proporcion;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(etiqueta, style: const TextStyle(fontSize: 13))),
              Text(valor, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            ],
          ),
          if (proporcion != null) ...[
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: proporcion!.clamp(0.0, 1.0),
                minHeight: 7,
                color: AppColors.amber,
                backgroundColor: AppColors.borderSoft,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PorEstado extends StatelessWidget {
  const _PorEstado(this.porEstado);
  final Map<EstadoPedido, int> porEstado;

  @override
  Widget build(BuildContext context) {
    final total = porEstado.values.fold<int>(0, (a, b) => a + b);
    return Column(
      children: [
        for (final e in EstadoPedido.values)
          if ((porEstado[e] ?? 0) > 0)
            _Linea(
              etiqueta: e.etiqueta,
              valor: '${porEstado[e]}',
              proporcion: total == 0 ? 0 : porEstado[e]! / total,
            ),
      ],
    );
  }
}

String _etiquetaClave(String clave) => switch (clave) {
      'en_mesa' => 'En mesa',
      'para_llevar' => 'Para llevar',
      'mesero' => 'Tomados por el mesero',
      'en_linea' => 'Pedidos en línea',
      _ => clave,
    };

class _PorClave extends StatelessWidget {
  const _PorClave({required this.porTipo, required this.porOrigen});
  final List<VentaPorClave> porTipo;
  final List<VentaPorClave> porOrigen;

  @override
  Widget build(BuildContext context) {
    Widget grupo(String titulo, List<VentaPorClave> l) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            for (final c in l)
              _Linea(
                etiqueta: '${_etiquetaClave(c.clave)} (${c.pedidos})',
                valor: formatoMoneda(c.ventas),
              ),
          ],
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        grupo('POR TIPO', porTipo),
        const SizedBox(height: 10),
        grupo('POR ORIGEN', porOrigen),
      ],
    );
  }
}

class _TopPlatillos extends StatelessWidget {
  const _TopPlatillos(this.platillos);
  final List<PlatilloVendido> platillos;

  @override
  Widget build(BuildContext context) {
    if (platillos.isEmpty) {
      return const Text('Sin ventas en este periodo', style: TextStyle(color: AppColors.textMuted));
    }
    final maximo = platillos.map((p) => p.cantidad).reduce((a, b) => a > b ? a : b);
    return Column(
      children: [
        for (final p in platillos)
          _Linea(
            etiqueta: '${p.nombre} · ${p.cantidad} vendidos',
            valor: formatoMoneda(p.importe),
            proporcion: maximo == 0 ? 0 : p.cantidad / maximo,
          ),
      ],
    );
  }
}

class _PorDia extends StatelessWidget {
  const _PorDia(this.dias);
  final List<VentaDia> dias;

  @override
  Widget build(BuildContext context) {
    final maximo = dias.map((d) => d.ventas).reduce((a, b) => a > b ? a : b);
    return Column(
      children: [
        for (final d in dias)
          _Linea(
            etiqueta: '${formatoFechaCorta(d.fecha)} · ${d.pedidos} pedidos',
            valor: formatoMoneda(d.ventas),
            proporcion: maximo == 0 ? 0 : d.ventas / maximo,
          ),
      ],
    );
  }
}

class _Descuentos extends StatelessWidget {
  const _Descuentos(this.r);
  final ReporteGerencial r;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Linea(
          etiqueta: 'Descuentos (${r.descuentosPedidos})',
          valor: formatoMoneda(r.descuentosMonto),
        ),
        _Linea(
          etiqueta: 'Cortesías (${r.cortesiasPedidos})',
          valor: formatoMoneda(r.cortesiasMonto),
        ),
        _Linea(etiqueta: 'Total descontado', valor: formatoMoneda(r.totalDescontado)),
        if (r.descuentos.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('Sin descuentos ni cortesías', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
          )
        else ...[
          const Divider(height: 24),
          for (final d in r.descuentos)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'Pedido #${d.folioDia} (${formatoFechaCorta(d.fecha)}) · '
                '${d.esCortesia ? 'Cortesía' : 'Descuento'} ${formatoMoneda(d.monto)}'
                '${(d.motivo ?? '').isEmpty ? '' : ' · ${d.motivo}'}',
                style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
              ),
            ),
        ],
      ],
    );
  }
}

class _Cancelaciones extends StatelessWidget {
  const _Cancelaciones(this.lista);
  final List<CancelacionReporte> lista;

  @override
  Widget build(BuildContext context) {
    if (lista.isEmpty) {
      return const Text('Sin cancelaciones', style: TextStyle(color: AppColors.textMuted, fontSize: 13));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final c in lista)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text(
              'Pedido #${c.folioDia} (${formatoFechaCorta(c.fecha)}) · ${c.motivo}'
              '${c.canceladoPor == null ? '' : ' · por ${c.canceladoPor}'}'
              ' · pérdida ${formatoMoneda(c.costoPerdida)}',
              style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
            ),
          ),
      ],
    );
  }
}
