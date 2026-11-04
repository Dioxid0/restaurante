import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/pedido.dart';

/// Chip de estado: ● Pendiente, ● En Preparación, ...
class EstadoChip extends StatelessWidget {
  const EstadoChip(this.estado, {super.key});
  final EstadoPedido estado;

  static (Color fondo, Color texto) _colores(EstadoPedido e) => switch (e) {
        EstadoPedido.pendiente => (const Color(0xFFFEF3C7), const Color(0xFFB45309)),
        EstadoPedido.enPreparacion => (const Color(0xFFEFF6FF), const Color(0xFF2563EB)),
        EstadoPedido.listo => (const Color(0xFFECFDF5), const Color(0xFF059669)),
        EstadoPedido.entregado => (const Color(0xFFE2E8F0), const Color(0xFF475569)),
        EstadoPedido.completado => (const Color(0xFFCCFBF1), const Color(0xFF0F766E)),
        EstadoPedido.cancelado => (const Color(0xFFFEE2E2), const Color(0xFFB91C1C)),
      };

  @override
  Widget build(BuildContext context) {
    final (fondo, texto) = _colores(estado);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: fondo, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 7, color: texto),
          const SizedBox(width: 6),
          Text(
            estado.etiqueta,
            style: TextStyle(color: texto, fontSize: 11.5, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

/// Ícono del tipo de pedido con tooltip.
class TipoPedidoIcono extends StatelessWidget {
  const TipoPedidoIcono(this.tipo, {super.key});
  final TipoPedido tipo;

  @override
  Widget build(BuildContext context) {
    final enMesa = tipo == TipoPedido.enMesa;
    final color = enMesa ? const Color(0xFFD97706) : const Color(0xFF2563EB);
    final fondo = enMesa ? const Color(0xFFFEF3C7) : const Color(0xFFEFF6FF);
    return Tooltip(
      message: tipo.descripcion,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: fondo,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Icon(
          enMesa ? Icons.room_service_outlined : Icons.shopping_bag_outlined,
          size: 18,
          color: color,
        ),
      ),
    );
  }
}

/// Minutos transcurridos: verde < 15, ámbar 15–19, rojo ≥ 20.
class TiempoChip extends StatelessWidget {
  const TiempoChip({super.key, required this.minutos});
  final int minutos;

  @override
  Widget build(BuildContext context) {
    final (fondo, texto) = minutos < 15
        ? (const Color(0xFFDCFCE7), const Color(0xFF15803D))
        : minutos < 20
            ? (const Color(0xFFFEF3C7), const Color(0xFFB45309))
            : (const Color(0xFFFFE4E6), const Color(0xFFBE123C));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: fondo, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 11, color: texto),
          const SizedBox(width: 3),
          Text(
            '$minutos min',
            style: TextStyle(color: texto, fontSize: 10, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

/// Botón cuadrado con ícono (ver, marcar entregado/completado).
class BotonIcono extends StatelessWidget {
  const BotonIcono({
    super.key,
    required this.icono,
    required this.tooltip,
    required this.alPresionar,
    this.color = AppColors.textMuted,
    this.fondo = Colors.white,
    this.borde = AppColors.border,
  });

  final IconData icono;
  final String tooltip;
  final VoidCallback alPresionar;
  final Color color;
  final Color fondo;
  final Color borde;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: alPresionar,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: fondo,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: borde),
          ),
          child: Icon(icono, size: 18, color: color),
        ),
      ),
    );
  }
}
