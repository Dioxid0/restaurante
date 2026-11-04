import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Marcador de una pantalla que aún no está diseñada.
class EnConstruccion extends StatelessWidget {
  const EnConstruccion({super.key, required this.titulo, this.descripcion, this.icono = Icons.construction});

  final String titulo;
  final String? descripcion;
  final IconData icono;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 44, color: AppColors.textFaint),
            const SizedBox(height: 14),
            Text(titulo, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            if (descripcion != null) ...[
              const SizedBox(height: 6),
              Text(
                descripcion!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 13.5),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
