import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../auth/auth_providers.dart';
import '../pedidos/comanderia_screen.dart';
import '../shell/shell_autenticado.dart';

/// "Inicio": el personal (mesero, chef, gerente) ve la Comandería; el cliente, su espacio.
class InicioScreen extends ConsumerWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perfil = ref.watch(perfilActualProvider).value;
    return InicioPorRol(
      rol: perfil?.rol,
      personal: const ComanderiaScreen(),
      cliente: _InicioCliente(nombre: perfil?.nombre ?? ''),
    );
  }
}

/// Espacio del cliente (provisional hasta recibir su diseño de Figma).
class _InicioCliente extends StatelessWidget {
  const _InicioCliente({required this.nombre});
  final String nombre;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.restaurant_menu, size: 44, color: AppColors.textFaint),
            const SizedBox(height: 14),
            Text('Hola, $nombre', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            const Text(
              'Pide en línea para llevar y administra tus reservaciones.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 13.5),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => context.go('/pedido/nuevo'),
              icon: const Icon(Icons.shopping_bag_outlined, size: 18),
              label: const Text('Hacer un pedido'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.amber,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
