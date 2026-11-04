import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/empleado.dart';
import '../../presentation/layouts/app_shell.dart';
import '../auth/auth_providers.dart';
import '../pedidos/comanderia_screen.dart';

/// Inicio: muestra la pantalla principal según el rol del empleado.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final empleado = ref.watch(empleadoActualProvider);

    return empleado.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No se pudo cargar tu perfil'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(empleadoActualProvider),
                child: const Text('Reintentar'),
              ),
              TextButton(
                onPressed: () => ref.read(loginControllerProvider.notifier).cerrarSesion(),
                child: const Text('Salir'),
              ),
            ],
          ),
        ),
      ),
      data: (e) {
        if (e == null) {
          // Sesión de una cuenta que no es de personal: se cierra.
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => ref.read(loginControllerProvider.notifier).cerrarSesion(),
          );
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return AppShell(
          empleado: e,
          alSalir: () => ref.read(loginControllerProvider.notifier).cerrarSesion(),
          child: switch (e.rol) {
            RolEmpleado.mesero => const ComanderiaScreen(),
            RolEmpleado.chef || RolEmpleado.gerente => _EnConstruccion(rol: e.rol),
          },
        );
      },
    );
  }
}

class _EnConstruccion extends StatelessWidget {
  const _EnConstruccion({required this.rol});
  final RolEmpleado rol;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Pantalla de ${rol.etiqueta} en construcción',
        style: const TextStyle(color: AppColors.textMuted, fontSize: 16),
      ),
    );
  }
}
