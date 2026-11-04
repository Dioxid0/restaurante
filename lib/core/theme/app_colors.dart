import 'package:flutter/material.dart';

/// Paleta tomada del diseño de Figma (estimada de las capturas).
abstract final class AppColors {
  // Oscuros (login y encabezado)
  static const navy900 = Color(0xFF0B1222);
  static const navy800 = Color(0xFF0F172A);
  static const navy700 = Color(0xFF151E33);
  static const navyBorder = Color(0xFF263148);

  // Acento
  static const amber = Color(0xFFD97706);
  static const amberSoft = Color(0xFFFEF3C7);
  static const amberRow = Color(0xFFFFFBEB);

  // Claros (contenido)
  static const pageBg = Color(0xFFF8FAFC);
  static const surface = Colors.white;
  static const border = Color(0xFFE2E8F0);
  static const borderSoft = Color(0xFFF1F5F9);

  // Texto
  static const text = Color(0xFF0F172A);
  static const textMuted = Color(0xFF64748B);
  static const textFaint = Color(0xFF94A3B8);

  // Semánticos
  static const green = Color(0xFF16A34A);
  static const danger = Color(0xFFDC2626);
}
