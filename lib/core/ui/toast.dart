import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum TipoToast { exito, error }

/// Cuánto tiempo se muestra un aviso (se puede acortar en pruebas).
Duration duracionToast = const Duration(seconds: 4);

/// Aviso flotante arriba a la derecha. Vive en el Overlay raíz, así que
/// sigue visible aunque la pantalla que lo mostró se cierre.
void mostrarToast(BuildContext context, String mensaje, {TipoToast tipo = TipoToast.exito}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  late final OverlayEntry entrada;
  Timer? temporizador;

  void cerrar() {
    temporizador?.cancel();
    if (entrada.mounted) entrada.remove();
  }

  entrada = OverlayEntry(
    builder: (_) => _Toast(mensaje: mensaje, tipo: tipo, alCerrar: cerrar),
  );
  overlay.insert(entrada);
  temporizador = Timer(duracionToast, cerrar);
}

class _Toast extends StatelessWidget {
  const _Toast({required this.mensaje, required this.tipo, required this.alCerrar});

  final String mensaje;
  final TipoToast tipo;
  final VoidCallback alCerrar;

  @override
  Widget build(BuildContext context) {
    final exito = tipo == TipoToast.exito;
    final color = exito ? const Color(0xFF16A34A) : AppColors.danger;
    final fondo = exito ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2);

    return Positioned(
      top: 22,
      right: 22,
      child: Material(
        color: Colors.transparent,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 220),
          builder: (context, t, child) => Opacity(
            opacity: t,
            child: Transform.translate(offset: Offset(0, -12 * (1 - t)), child: child),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 380),
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            decoration: BoxDecoration(
              color: fondo,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withValues(alpha: 0.35)),
              boxShadow: const [
                BoxShadow(color: Color(0x26000000), blurRadius: 24, offset: Offset(0, 8)),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: exito ? const Color(0xFFDCFCE7) : color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    exito ? Icons.check_circle_outline : Icons.priority_high,
                    size: 20,
                    color: exito ? color : Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    mensaje,
                    style: TextStyle(
                      color: exito ? const Color(0xFF166534) : const Color(0xFFB91C1C),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: alCerrar,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.close, size: 18, color: color.withValues(alpha: 0.7)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
