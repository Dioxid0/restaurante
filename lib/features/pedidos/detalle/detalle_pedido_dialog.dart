import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/ui/toast.dart';
import '../../../core/utils/formato.dart';
import '../../../domain/entities/pedido.dart';
import '../../../domain/entities/pedido_detalle.dart';
import '../../../domain/entities/perfil.dart';
import '../../../data/repository_providers.dart';
import '../../../domain/errors.dart';
import '../../auth/auth_providers.dart';
import '../comanda/comanda_providers.dart';
import '../pedidos_providers.dart';
import '../widgets/pedido_chips.dart';
import 'dialogo_descuento.dart';

/// Muestra el modal con todos los datos de un pedido.
Future<void> mostrarDetallePedido(BuildContext context, int folio) => showDialog<void>(
      context: context,
      builder: (_) => DetallePedidoDialog(folio: folio),
    );

/// Modal "Detalle de Comanda - #PED-108": datos generales, renglones y totales.
class DetallePedidoDialog extends ConsumerWidget {
  const DetallePedidoDialog({super.key, required this.folio});
  final int folio;

  /// CU-09: el gerente aplica (o quita) un descuento o una cortesía y se recarga el detalle.
  Future<void> _ajustar(BuildContext context, WidgetRef ref, PedidoDetalle d) async {
    final r = await mostrarDialogoDescuento(
      context,
      folio: d.folioEtiqueta,
      bruto: d.totalSinDescuento,
      descuentoActual: d.descuento,
    );
    if (r == null || !context.mounted) return;
    try {
      await ref.read(pedidoRepositoryProvider).aplicarDescuento(
            folio: d.folio,
            monto: r.monto,
            esCortesia: r.esCortesia,
            motivo: r.motivo,
          );
      ref.invalidate(detallePedidoProvider(folio));
      ref.invalidate(pedidosDelDiaProvider);
      if (context.mounted) {
        mostrarToast(
          context,
          r.esCortesia
              ? 'Cortesía aplicada'
              : (r.monto == 0 ? 'Descuento retirado' : 'Descuento aplicado'),
        );
      }
    } catch (e) {
      if (context.mounted) mostrarToast(context, mensajeDeError(e), tipo: TipoToast.error);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detalle = ref.watch(detallePedidoProvider(folio));
    final esGerente = ref.watch(perfilActualProvider).value?.rol == RolUsuario.gerente;

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(26),
          child: detalle.when(
            loading: () => const SizedBox(
              height: 220,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => _Error(
              mensaje: mensajeDeError(e, porDefecto: 'No se pudo cargar el pedido'),
              alCerrar: () => Navigator.of(context).pop(),
            ),
            data: (d) => _Contenido(
              detalle: d,
              alCerrar: () => Navigator.of(context).pop(),
              // Solo el gerente (la base también lo exige) y no en pedidos cancelados.
              alAjustar: esGerente && d.estado != EstadoPedido.cancelado
                  ? () => _ajustar(context, ref, d)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido({required this.detalle, required this.alCerrar, this.alAjustar});
  final PedidoDetalle detalle;
  final VoidCallback alCerrar;

  /// Gerente: abre el cuadro de descuento o cortesía. Null = no se ofrece.
  final VoidCallback? alAjustar;

  @override
  Widget build(BuildContext context) {
    // Subtotal e IVA se calculan sobre lo que costaba el pedido; el descuento se resta después.
    final iva = desgloseIva(detalle.totalSinDescuento);
    final tipo = detalle.tipo == TipoPedido.enMesa ? 'Presencial' : 'Para Llevar';
    final mesero = detalle.nombreMesero ?? (detalle.esEnLinea ? 'En línea' : '—');
    final cliente = detalle.nombreCliente;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DETALLE DEL PEDIDO',
                    style: TextStyle(
                      color: AppColors.amber,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Detalle de Comanda - ${detalle.folioEtiqueta}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: alCerrar,
              borderRadius: BorderRadius.circular(11),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(Icons.close, size: 18, color: AppColors.textMuted),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        // --- Datos generales ---
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.pageBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Wrap(
            spacing: 36,
            runSpacing: 14,
            children: [
              _Dato('Folio', detalle.folioEtiqueta),
              _Dato('Mesa', detalle.mesaEtiqueta ?? '—'),
              _Dato('Tipo de pedido', tipo),
              if (detalle.esEnLinea && cliente != null)
                _Dato('Cliente', cliente)
              else
                _Dato('Mesero asignado', mesero),
              _Dato('Estado', null, hijo: EstadoChip(detalle.estado)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // --- Renglones ---
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              const _FilaRenglon(
                fondo: AppColors.pageBg,
                platillo: Text('PLATILLO', style: _estiloEncabezado),
                cantidad: Text('CANT.', style: _estiloEncabezado),
                unitario: Text('P. UNITARIO', style: _estiloEncabezado),
                importe: Text('IMPORTE', style: _estiloEncabezado),
              ),
              for (final l in detalle.lineas)
                _FilaRenglon(
                  platillo: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.nombre, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                      if (l.nota != null && l.nota!.isNotEmpty)
                        Text(
                          'Nota: ${l.nota}',
                          style: const TextStyle(color: Color(0xFFD97706), fontSize: 10.5),
                        ),
                    ],
                  ),
                  cantidad: Text('${l.cantidad}', style: const TextStyle(fontSize: 12)),
                  unitario: Text(
                    formatoMoneda(l.precioUnitario),
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                  importe: Text(
                    formatoMoneda(l.importe),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // --- Totales ---
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.pageBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _FilaTotal('Subtotal', formatoMoneda(iva.subtotal)),
                const SizedBox(height: 8),
                _FilaTotal('IVA (16%)', formatoMoneda(iva.iva)),
                if (detalle.descuento > 0) ...[
                  const SizedBox(height: 8),
                  _FilaTotal(
                    detalle.esCortesia ? 'Cortesía' : 'Descuento',
                    '-${formatoMoneda(detalle.descuento)}',
                  ),
                  if ((detalle.motivoDescuento ?? '').isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Motivo: ${detalle.motivoDescuento}',
                          style: const TextStyle(color: AppColors.textFaint, fontSize: 10.5),
                        ),
                      ),
                    ),
                ],
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1, color: AppColors.border),
                ),
                Row(
                  children: [
                    const Expanded(child: Text('Total', style: TextStyle(fontWeight: FontWeight.w600))),
                    Text(
                      formatoMoneda(detalle.total),
                      key: const Key('total_detalle'),
                      style: const TextStyle(
                        color: Color(0xFFB45309),
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        if (alAjustar != null) ...[
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              onPressed: alAjustar,
              icon: const Icon(Icons.sell_outlined, size: 18),
              label: Text(detalle.descuento > 0 ? 'Cambiar descuento o cortesía' : 'Aplicar descuento o cortesía'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFB45309),
                side: const BorderSide(color: Color(0xFFFDBA74)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton(
            onPressed: alCerrar,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.navy900,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
              textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            child: const Text('Cerrar'),
          ),
        ),
      ],
    );
  }
}

const _estiloEncabezado = TextStyle(
  color: AppColors.textMuted,
  fontSize: 10,
  fontWeight: FontWeight.w800,
  letterSpacing: 0.8,
);

class _Dato extends StatelessWidget {
  const _Dato(this.etiqueta, this.valor, {this.hijo});
  final String etiqueta;
  final String? valor;
  final Widget? hijo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(etiqueta, style: const TextStyle(color: AppColors.textFaint, fontSize: 10.5)),
        const SizedBox(height: 4),
        hijo ?? Text(valor ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _FilaRenglon extends StatelessWidget {
  const _FilaRenglon({
    required this.platillo,
    required this.cantidad,
    required this.unitario,
    required this.importe,
    this.fondo = Colors.white,
  });

  final Widget platillo;
  final Widget cantidad;
  final Widget unitario;
  final Widget importe;
  final Color fondo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
      decoration: BoxDecoration(
        color: fondo,
        border: const Border(top: BorderSide(color: AppColors.borderSoft)),
      ),
      child: Row(
        children: [
          Expanded(flex: 5, child: platillo),
          Expanded(flex: 1, child: cantidad),
          Expanded(flex: 2, child: unitario),
          Expanded(flex: 2, child: importe),
        ],
      ),
    );
  }
}

class _FilaTotal extends StatelessWidget {
  const _FilaTotal(this.etiqueta, this.valor);
  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(etiqueta, style: const TextStyle(color: AppColors.textMuted, fontSize: 12))),
        Text(valor, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.mensaje, required this.alCerrar});
  final String mensaje;
  final VoidCallback alCerrar;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        const Icon(Icons.error_outline, size: 36, color: AppColors.danger),
        const SizedBox(height: 12),
        Text(mensaje, textAlign: TextAlign.center),
        const SizedBox(height: 18),
        FilledButton(onPressed: alCerrar, child: const Text('Cerrar')),
      ],
    );
  }
}
