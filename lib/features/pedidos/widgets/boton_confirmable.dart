import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'pedido_chips.dart';

/// Botón con ícono que, al tocarlo, abre una **burbuja pequeña** junto a él para
/// confirmar ("¿Marcar como Entregado? [Cancelar] [Confirmar]"). No bloquea la
/// pantalla: se cierra tocando fuera, con Esc o con "Cancelar".
class BotonConfirmable extends StatelessWidget {
  const BotonConfirmable({
    super.key,
    required this.icono,
    required this.tooltip,
    required this.titulo,
    required this.alConfirmar,
    this.detalle,
    this.textoConfirmar = 'Confirmar',
    this.etiqueta,
    this.color = AppColors.textMuted,
    this.fondo = Colors.white,
    this.borde = AppColors.border,
  });

  final IconData icono;
  final String tooltip;
  final String titulo;
  final String? detalle;
  final String textoConfirmar;

  /// Si se indica, el disparador es un botón con texto (p. ej. en Cocina) en vez de un ícono.
  final String? etiqueta;
  final VoidCallback alConfirmar;
  final Color color;
  final Color fondo;
  final Color borde;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      alignmentOffset: const Offset(-190, 6),
      style: MenuStyle(
        backgroundColor: const WidgetStatePropertyAll(Colors.white),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(8),
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.border),
          ),
        ),
      ),
      menuChildren: [
        _Burbuja(
          titulo: titulo,
          detalle: detalle,
          textoConfirmar: textoConfirmar,
          color: color,
          alConfirmar: alConfirmar,
        ),
      ],
      builder: (context, controlador, _) {
        void alternar() => controlador.isOpen ? controlador.close() : controlador.open();
        if (etiqueta == null) {
          return BotonIcono(
            icono: icono,
            tooltip: tooltip,
            color: color,
            fondo: fondo,
            borde: borde,
            alPresionar: alternar,
          );
        }
        return Tooltip(
          message: tooltip,
          child: FilledButton.icon(
            onPressed: alternar,
            icon: Icon(icono, size: 18),
            label: Text(etiqueta!),
            style: FilledButton.styleFrom(
              backgroundColor: color,
              minimumSize: const Size(0, 44),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              textStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
            ),
          ),
        );
      },
    );
  }
}

class _Burbuja extends StatelessWidget {
  const _Burbuja({
    required this.titulo,
    required this.textoConfirmar,
    required this.color,
    required this.alConfirmar,
    this.detalle,
  });

  final String titulo;
  final String? detalle;
  final String textoConfirmar;
  final Color color;
  final VoidCallback alConfirmar;

  @override
  Widget build(BuildContext context) {
    final controlador = MenuController.maybeOf(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 230, maxWidth: 260),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            if (detalle != null) ...[
              const SizedBox(height: 2),
              Text(detalle!, style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
            ],
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              children: [
                TextButton(
                  onPressed: () => controlador?.close(),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textMuted,
                    minimumSize: const Size(0, 34),
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    controlador?.close();
                    alConfirmar();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: color,
                    minimumSize: const Size(0, 34),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                  ),
                  child: Text(textoConfirmar),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
