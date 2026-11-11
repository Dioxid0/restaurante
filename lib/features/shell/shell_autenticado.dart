import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/destinos.dart';
import '../../domain/entities/perfil.dart';
import '../../presentation/layouts/app_shell.dart';
import '../../presentation/widgets/en_construccion.dart';
import '../auth/auth_providers.dart';
import '../reservaciones/avisos_reservaciones.dart';

/// Marco de todas las pantallas con sesión: carga el perfil y arma encabezado + pestañas.
class ShellAutenticado extends ConsumerWidget {
  const ShellAutenticado({super.key, required this.ubicacion, required this.child});

  final String ubicacion;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perfil = ref.watch(perfilActualProvider);

    return perfil.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No se pudo cargar tu perfil'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(perfilActualProvider),
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
      data: (p) {
        if (p == null) {
          // Sesión sin perfil asociado: se cierra.
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => ref.read(loginControllerProvider.notifier).cerrarSesion(),
          );
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final actual = Destino.values
            .where((d) => ubicacion.startsWith(d.ruta))
            .cast<Destino?>()
            .firstOrNull;
        return AppShell(
          perfil: p,
          destinoActual: actual,
          alSeleccionar: (d) => context.go(d.ruta),
          alSalir: () => ref.read(loginControllerProvider.notifier).cerrarSesion(),
          child: AvisosReservaciones(activo: p.rol == RolUsuario.cliente, child: child),
        );
      },
    );
  }
}

/// Muestra [child] solo si el rol puede entrar a [destino].
/// (La seguridad real la hace la base de datos; esto evita pantallas vacías o con errores.)
class AccesoPorRol extends ConsumerWidget {
  const AccesoPorRol({super.key, required this.destino, required this.child});

  final Destino destino;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perfil = ref.watch(perfilActualProvider).value;
    if (perfil == null) return const SizedBox.shrink();
    if (!destino.permite(perfil.rol)) {
      return const EnConstruccion(
        titulo: 'No tienes acceso a esta sección',
        icono: Icons.lock_outline,
      );
    }
    return child;
  }
}

/// Muestra [child] solo a los [roles] indicados (para pantallas fuera de las pestañas).
class AccesoRoles extends ConsumerWidget {
  const AccesoRoles({super.key, required this.roles, required this.child});

  final Set<RolUsuario> roles;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perfil = ref.watch(perfilActualProvider);
    return perfil.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => const Scaffold(body: Center(child: Text('No se pudo cargar tu perfil'))),
      data: (p) {
        if (p == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        if (!roles.contains(p.rol)) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const EnConstruccion(titulo: 'No tienes acceso a esta sección', icono: Icons.lock_outline),
                  FilledButton(
                    onPressed: () => context.go('/inicio'),
                    child: const Text('Ir al inicio'),
                  ),
                ],
              ),
            ),
          );
        }
        return child;
      },
    );
  }
}

/// Inicio según el rol: el personal ve la Comandería; el cliente, su espacio.
class InicioPorRol extends StatelessWidget {
  const InicioPorRol({super.key, required this.rol, required this.personal, required this.cliente});

  final RolUsuario? rol;
  final Widget personal;
  final Widget cliente;

  @override
  Widget build(BuildContext context) => rol == RolUsuario.cliente ? cliente : personal;
}
