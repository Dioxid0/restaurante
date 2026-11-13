import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/ui/zoom.dart';

// Se inyectan en tiempo de compilación con --dart-define (nunca en código).
const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw StateError(
      'Faltan SUPABASE_URL y/o SUPABASE_ANON_KEY. '
      'Ejecuta con --dart-define (ver CLAUDE.md).',
    );
  }

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  runApp(const ProviderScope(retry: _sinReintentos, child: RestaurantApp()));
}

/// Riverpod 3 reintenta providers fallidos por defecto; aquí preferimos mostrar el error.
Duration? _sinReintentos(int intento, Object error) => null;

class RestaurantApp extends ConsumerWidget {
  const RestaurantApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'El Buen Sabor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: ref.watch(appRouterProvider),
      // Escala automática en pantallas grandes + zoom del usuario (Ctrl +/−/0).
      builder: (context, child) => _MarcoDelSistema(
        child: EscalaInterfaz(child: child ?? const SizedBox.shrink()),
      ),
    );
  }
}

/// En el teléfono la app se dibuja a pantalla completa (Android 15): sin esto los
/// encabezados quedan debajo de la barra de estado (hora, batería). Deja ese espacio con el
/// color del encabezado y pone los íconos de la barra en claro. En escritorio no hay inset: no cambia nada.
class _MarcoDelSistema extends StatelessWidget {
  const _MarcoDelSistema({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: ColoredBox(
        color: AppColors.navy900,
        child: SafeArea(bottom: false, child: child),
      ),
    );
  }
}
