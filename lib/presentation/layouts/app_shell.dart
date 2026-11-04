import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/router/destinos.dart';
import '../../core/theme/app_colors.dart';
import '../../core/ui/zoom.dart';
import '../../core/utils/formato.dart';
import '../../domain/entities/perfil.dart';
import '../widgets/brand_mark.dart';

/// Marco común de las pantallas con sesión: encabezado oscuro, pestañas por rol y contenido.
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.perfil,
    required this.destinoActual,
    required this.alSeleccionar,
    required this.alSalir,
    required this.child,
  });

  final Perfil perfil;
  final Destino? destinoActual;
  final ValueChanged<Destino> alSeleccionar;
  final VoidCallback alSalir;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final destinos = destinosPara(perfil.rol);
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: Column(
        children: [
          _Encabezado(perfil: perfil, alSalir: alSalir),
          // Con una sola sección (mesero, cliente) no se muestran pestañas.
          if (destinos.length > 1)
            _BarraPestanas(
              destinos: destinos,
              actual: destinoActual,
              alSeleccionar: alSeleccionar,
            ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado({required this.perfil, required this.alSalir});
  final Perfil perfil;
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'El Buen Sabor',
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
          const Spacer(),
          const ControlZoom(),
          if (!compacto && perfil.rol.esPersonal) ...[
            const SizedBox(width: 14),
            const _TurnoActivo(),
          ],
          const SizedBox(width: 14),
          Container(width: 1, height: 36, color: AppColors.navyBorder),
          const SizedBox(width: 14),
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF3B2A17),
            child: Text(
              iniciales(perfil.nombre),
              style: const TextStyle(
                color: Color(0xFFFBBF24),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (!compacto) ...[
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  perfil.nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  perfil.rol.etiqueta,
                  style: const TextStyle(color: AppColors.textFaint, fontSize: 11),
                ),
              ],
            ),
          ],
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

class _BarraPestanas extends StatelessWidget {
  const _BarraPestanas({
    required this.destinos,
    required this.actual,
    required this.alSeleccionar,
  });

  final List<Destino> destinos;
  final Destino? actual;
  final ValueChanged<Destino> alSeleccionar;

  @override
  Widget build(BuildContext context) {
    final compacto = MediaQuery.sizeOf(context).width < 900;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: compacto ? 8 : 20),
      decoration: const BoxDecoration(
        color: AppColors.navy900,
        border: Border(top: BorderSide(color: AppColors.navyBorder)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final d in destinos)
              _Pestana(
                destino: d,
                seleccionada: d == actual,
                alTocar: () => alSeleccionar(d),
              ),
          ],
        ),
      ),
    );
  }
}

class _Pestana extends StatelessWidget {
  const _Pestana({
    required this.destino,
    required this.seleccionada,
    required this.alTocar,
  });

  final Destino destino;
  final bool seleccionada;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final color = seleccionada ? const Color(0xFFFBBF24) : AppColors.textFaint;
    return InkWell(
      onTap: alTocar,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: seleccionada ? AppColors.amber : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(destino.icono, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              destino.etiqueta,
              style: TextStyle(
                color: color,
                fontSize: 13.5,
                fontWeight: seleccionada ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
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

/// Botones − 100% + del encabezado (también funcionan Ctrl +, Ctrl − y Ctrl 0).
class ControlZoom extends ConsumerWidget {
  const ControlZoom({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zoom = ref.watch(zoomUsuarioProvider);
    final notifier = ref.read(zoomUsuarioProvider.notifier);

    Widget boton(IconData icono, String tooltip, VoidCallback alTocar, bool activo) => Tooltip(
          message: tooltip,
          child: InkWell(
            onTap: activo ? alTocar : null,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                icono,
                size: 18,
                color: activo ? const Color(0xFFCBD5E1) : AppColors.navyBorder,
              ),
            ),
          ),
        );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.navyBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          boton(Icons.remove, 'Alejar (Ctrl −)', notifier.alejar, zoom > ZoomUsuario.minimo + 0.001),
          Tooltip(
            message: 'Restablecer zoom (Ctrl 0)',
            child: InkWell(
              onTap: notifier.restablecer,
              child: SizedBox(
                width: 46,
                child: Text(
                  '${(zoom * 100).round()}%',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFCBD5E1),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          boton(Icons.add, 'Acercar (Ctrl +)', notifier.acercar, zoom < ZoomUsuario.maximo - 0.001),
        ],
      ),
    );
  }
}
