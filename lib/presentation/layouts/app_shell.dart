import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formato.dart';
import '../../domain/entities/empleado.dart';
import '../widgets/brand_mark.dart';

/// Marco común de las pantallas del personal: encabezado oscuro + contenido.
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.empleado,
    required this.alSalir,
    required this.child,
  });

  final Empleado empleado;
  final VoidCallback alSalir;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: Column(
        children: [
          _Encabezado(empleado: empleado, alSalir: alSalir),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado({required this.empleado, required this.alSalir});
  final Empleado empleado;
  final VoidCallback alSalir;

  @override
  Widget build(BuildContext context) {
    // En ventanas angostas se ocultan los textos secundarios.
    final compacto = MediaQuery.sizeOf(context).width < 900;
    return Container(
      color: AppColors.navy900,
      padding: EdgeInsets.symmetric(horizontal: compacto ? 14 : 26, vertical: 14),
      child: Row(
        children: [
          const BrandMark(size: 42, iniciales: 'BS'),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'El Buen Sabor',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (!compacto)
                  const Text(
                    'Gestión Restaurantera',
                    style: TextStyle(color: AppColors.textFaint, fontSize: 11),
                  ),
              ],
            ),
          ),
          const Spacer(),
          if (!compacto) ...[
            const _TurnoActivo(),
            const SizedBox(width: 18),
            Container(width: 1, height: 36, color: AppColors.navyBorder),
            const SizedBox(width: 18),
          ],
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF3B2A17),
            child: Text(
              iniciales(empleado.nombre),
              style: const TextStyle(
                color: Color(0xFFFBBF24),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          if (!compacto)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  empleado.nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  empleado.rol.etiqueta,
                  style: const TextStyle(color: AppColors.textFaint, fontSize: 11),
                ),
              ],
            ),
          const SizedBox(width: 16),
          OutlinedButton.icon(
            onPressed: alSalir,
            icon: const Icon(Icons.logout, size: 16),
            label: const Text('Salir'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFCBD5E1),
              side: const BorderSide(color: AppColors.navyBorder),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}

class _TurnoActivo extends StatelessWidget {
  const _TurnoActivo();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.green.withValues(alpha: 0.4)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: Color(0xFF22C55E)),
          SizedBox(width: 8),
          Text(
            'Turno Activo',
            style: TextStyle(
              color: Color(0xFF4ADE80),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
