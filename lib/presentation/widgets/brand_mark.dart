import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Cuadro con el logo del restaurante (ícono o iniciales).
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 62, this.iniciales});

  final double size;

  /// Si se indica, muestra texto en vez del ícono de cubiertos.
  final String? iniciales;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.amber.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(size * 0.29),
        border: Border.all(color: AppColors.amber.withValues(alpha: 0.4)),
      ),
      child: iniciales != null
          ? Text(
              iniciales!,
              style: TextStyle(
                color: const Color(0xFFFBBF24),
                fontWeight: FontWeight.w800,
                fontSize: size * 0.34,
              ),
            )
          : Icon(Icons.restaurant, color: AppColors.amber, size: size * 0.45),
    );
  }
}
