import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/cocina/cocina_screen.dart';
import '../../features/reservaciones/reservaciones_screen.dart';

import '../../data/repository_providers.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/registro_screen.dart';
import '../../features/gerencia/gerencia_screen.dart';
import '../../domain/entities/perfil.dart';
import '../../features/home/inicio_screen.dart';
import '../../features/pedidos/comanda/pedido_form_screen.dart';
import '../../features/shell/shell_autenticado.dart';
import 'destinos.dart';

part 'app_router.g.dart';

/// Avisa a go_router cuando cambia la sesión para reevaluar el `redirect`.
class _RefrescoPorStream extends ChangeNotifier {
  _RefrescoPorStream(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

/// Quién puede crear pedidos: mesero y cliente (el gerente y el chef no).
const _rolesCrearPedido = {RolUsuario.mesero, RolUsuario.cliente};

/// Quién puede editar/cancelar pedidos: también el gerente (el chef no).
const _rolesDePedido = {RolUsuario.mesero, RolUsuario.gerente, RolUsuario.cliente};

/// Rutas públicas (sin sesión).
const _rutasPublicas = {'/login', '/registro'};

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final auth = ref.watch(authRepositoryProvider);
  final refresco = _RefrescoPorStream(auth.cambiosDeSesion);
  ref.onDispose(refresco.dispose);

  final router = GoRouter(
    initialLocation: '/inicio',
    refreshListenable: refresco,
    redirect: (context, state) {
      final enPublica = _rutasPublicas.contains(state.matchedLocation);
      if (!auth.haySesion) return enPublica ? null : '/login';
      if (enPublica || state.matchedLocation == '/') return '/inicio';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/registro', builder: (_, _) => const RegistroScreen()),
      // Pantalla completa de comanda (sin encabezado general): crear, editar y pedido del cliente.
      GoRoute(
        path: '/pedido/nuevo',
        builder: (_, _) => const AccesoRoles(roles: _rolesCrearPedido, child: PedidoFormScreen()),
      ),
      GoRoute(
        path: '/pedido/:folio/editar',
        builder: (_, state) => AccesoRoles(
          roles: _rolesDePedido,
          child: PedidoFormScreen(folio: int.tryParse(state.pathParameters['folio'] ?? '')),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            ShellAutenticado(ubicacion: state.uri.path, child: child),
        routes: [
          GoRoute(path: '/inicio', builder: (_, _) => const InicioScreen()),
          GoRoute(
              path: '/reservaciones',
              builder: (_, _) => const AccesoPorRol(
                destino: Destino.reservaciones,
                child: ReservacionesScreen(),
              ),
            ),
          GoRoute(
            path: '/cocina',
            builder: (_, _) => const AccesoPorRol(
              destino: Destino.cocina,
              child: CocinaScreen(),
            ),
          ),
          GoRoute(
            path: '/gerencia',
            builder: (_, _) => const AccesoPorRol(
              destino: Destino.gerencia,
              child: GerenciaScreen(),
            ),
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
}
