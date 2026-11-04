import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formato.dart';
import '../../../../domain/entities/platillo.dart';

/// Ícono que sustituye a la foto cuando el platillo no tiene `imagen_url`.
IconData iconoDeCategoria(CategoriaPlatillo c) => switch (c) {
      CategoriaPlatillo.bebidas => Icons.local_drink_outlined,
      CategoriaPlatillo.antojitos => Icons.tapas_outlined,
      CategoriaPlatillo.platosFuertes => Icons.restaurant_outlined,
      CategoriaPlatillo.postres => Icons.cake_outlined,
      CategoriaPlatillo.especialidades => Icons.workspace_premium_outlined,
    };

class PlatilloCard extends StatefulWidget {
  const PlatilloCard({super.key, required this.platillo, required this.alAgregar});

  final Platillo platillo;

  /// Recibe el platillo y la nota escrita en la tarjeta.
  final void Function(Platillo platillo, String nota) alAgregar;

  @override
  State<PlatilloCard> createState() => _PlatilloCardState();
}

class _PlatilloCardState extends State<PlatilloCard> {
  final _nota = TextEditingController();

  @override
  void dispose() {
    _nota.dispose();
    super.dispose();
  }

  void _agregar() {
    widget.alAgregar(widget.platillo, _nota.text);
    _nota.clear();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.platillo;
    return Opacity(
      opacity: p.disponible ? 1 : 0.62,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: const [BoxShadow(color: Color(0x0A0F172A), blurRadius: 10, offset: Offset(0, 3))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 130,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _Imagen(platillo: p),
                  Positioned(right: 8, bottom: 8, child: _Disponibilidad(p.disponible)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          p.nombre,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formatoMoneda(p.precio),
                        style: const TextStyle(
                          color: Color(0xFFB45309),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (p.disponible) ...[
                    const Text(
                      'Nota para este platillo',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      controller: _nota,
                      maxLength: 200,
                      style: const TextStyle(fontSize: 12),
                      onSubmitted: (_) => _agregar(),
                      decoration: InputDecoration(
                        hintText: 'Ej. Sin cebolla, extra salsa',
                        hintStyle: const TextStyle(color: AppColors.textFaint, fontSize: 12),
                        counterText: '',
                        isDense: true,
                        filled: true,
                        fillColor: AppColors.pageBg,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 38,
                      child: OutlinedButton.icon(
                        onPressed: _agregar,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Agregar al Pedido'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFB45309),
                          backgroundColor: const Color(0xFFFFF7ED),
                          side: const BorderSide(color: Color(0xFFFDBA74)),
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ] else
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        'No disponible por el momento',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Imagen extends StatelessWidget {
  const _Imagen({required this.platillo});
  final Platillo platillo;

  @override
  Widget build(BuildContext context) {
    final marcador = Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFEF3C7), Color(0xFFFFEDD5)],
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        iconoDeCategoria(platillo.categoria),
        size: 54,
        color: AppColors.amber.withValues(alpha: 0.55),
      ),
    );
    final url = platillo.imagenUrl;
    if (url == null || url.isEmpty) return marcador;
    return Image.network(url, fit: BoxFit.cover, errorBuilder: (_, _, _) => marcador);
  }
}

class _Disponibilidad extends StatelessWidget {
  const _Disponibilidad(this.disponible);
  final bool disponible;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xE60F172A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 7, color: disponible ? const Color(0xFF22C55E) : AppColors.danger),
          const SizedBox(width: 5),
          Text(
            disponible ? 'Disponible' : 'Agotado',
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
