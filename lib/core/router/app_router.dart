import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repository_providers.dart';
import '../../features/auth/login_screen.dart';
import '../../features/home/home_screen.dart';

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

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final auth = ref.watch(authRepositoryProvider);
  final refresco = _RefrescoPorStream(auth.cambiosDeSesion);
  ref.onDispose(refresco.dispose);

  final router = GoRouter(
    initialLocation: '/',
    refreshListenable: refresco,
    redirect: (context, state) {
      final enLogin = state.matchedLocation == '/login';
      if (!auth.haySesion) return enLogin ? null : '/login';
      return enLogin ? '/' : null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
}
