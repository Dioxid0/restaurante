import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../presentation/widgets/brand_mark.dart';
import 'auth_providers.dart';
import 'widgets/auth_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identificador = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _identificador.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(loginControllerProvider.notifier)
        .ingresar(_identificador.text, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(loginControllerProvider);
    final error = mensajeDeAuth(estado);

    return AuthFondo(
      child: AuthTarjeta(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: BrandMark()),
              const SizedBox(height: 22),
              const AuthTitulos(
                titulo: 'Iniciar Sesión',
                subtitulo: 'Ingresa tus credenciales para continuar',
              ),
              const SizedBox(height: 28),
              AuthCampo(
                etiqueta: 'Usuario o correo electrónico',
                controlador: _identificador,
                icono: Icons.person_outline,
                hint: 'Juan Perez',
                autofocus: true,
                validador: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Ingresa tu usuario o correo' : null,
              ),
              const SizedBox(height: 18),
              AuthCampo(
                etiqueta: 'Contraseña',
                controlador: _password,
                icono: Icons.lock_outline,
                hint: '••••••••',
                oculto: true,
                accion: TextInputAction.done,
                alEnviar: (_) => _enviar(),
                validador: (v) =>
                    (v == null || v.isEmpty) ? 'Ingresa tu contraseña' : null,
              ),
              if (error != null) ...[
                const SizedBox(height: 16),
                AuthMensajeError(error),
              ],
              const SizedBox(height: 22),
              AuthBoton(
                texto: 'Ingresar al Sistema',
                cargando: estado.isLoading,
                alPresionar: _enviar,
              ),
              const SizedBox(height: 14),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    '¿Eres cliente y no tienes cuenta?',
                    style: TextStyle(color: AppColors.textFaint, fontSize: 12.5),
                  ),
                  TextButton(
                    onPressed: () => context.go('/registro'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.amber,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      minimumSize: const Size(0, 30),
                      textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                    ),
                    child: const Text('Crear cuenta'),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 12, color: AppColors.textMuted),
                  SizedBox(width: 6),
                  Text(
                    'Acceso seguro y protegido',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
