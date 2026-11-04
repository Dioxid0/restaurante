import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/usuario.dart';
import '../../presentation/widgets/brand_mark.dart';
import 'auth_providers.dart';
import 'widgets/auth_widgets.dart';

/// Registro público: solo crea cuentas de cliente.
class RegistroScreen extends ConsumerStatefulWidget {
  const RegistroScreen({super.key});

  @override
  ConsumerState<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends ConsumerState<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _correo = TextEditingController();
  final _telefono = TextEditingController();
  final _password = TextEditingController();
  final _confirmar = TextEditingController();

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    _telefono.dispose();
    _password.dispose();
    _confirmar.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(registroControllerProvider.notifier).registrar(
          nombre: _nombre.text,
          correo: _correo.text,
          telefono: _telefono.text,
          password: _password.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(registroControllerProvider);
    final error = mensajeDeAuth(estado);
    final faltaConfirmar = estado.value == true;

    return AuthFondo(
      child: AuthTarjeta(
        child: faltaConfirmar
            ? _ConfirmaTuCorreo(alVolver: () => context.go('/login'))
            : Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: BrandMark()),
                    const SizedBox(height: 22),
                    const AuthTitulos(
                      titulo: 'Crear cuenta',
                      subtitulo: 'Regístrate para reservar y hacer pedidos en línea',
                    ),
                    const SizedBox(height: 26),
                    AuthCampo(
                      etiqueta: 'Nombre completo',
                      controlador: _nombre,
                      icono: Icons.person_outline,
                      hint: 'Juan Perez',
                      autofocus: true,
                      validador: (v) =>
                          (v == null || v.trim().length < 2) ? 'Ingresa tu nombre' : null,
                    ),
                    const SizedBox(height: 16),
                    AuthCampo(
                      etiqueta: 'Correo electrónico',
                      controlador: _correo,
                      icono: Icons.mail_outline,
                      hint: 'correo@ejemplo.com',
                      teclado: TextInputType.emailAddress,
                      validador: (v) {
                        if (v == null || !esCorreoValido(v)) return 'Ingresa un correo válido';
                        if (v.trim().toLowerCase().endsWith('@$dominioEmpleados')) {
                          return 'Ese correo no está permitido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AuthCampo(
                      etiqueta: 'Teléfono (opcional)',
                      controlador: _telefono,
                      icono: Icons.phone_outlined,
                      hint: '777 123 4567',
                      teclado: TextInputType.phone,
                      validador: (_) => null,
                    ),
                    const SizedBox(height: 16),
                    AuthCampo(
                      etiqueta: 'Contraseña',
                      controlador: _password,
                      icono: Icons.lock_outline,
                      hint: 'Mínimo 8 caracteres',
                      oculto: true,
                      validador: (v) => (v == null || v.length < 8)
                          ? 'La contraseña debe tener al menos 8 caracteres'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    AuthCampo(
                      etiqueta: 'Confirmar contraseña',
                      controlador: _confirmar,
                      icono: Icons.lock_outline,
                      hint: '••••••••',
                      oculto: true,
                      accion: TextInputAction.done,
                      alEnviar: (_) => _enviar(),
                      validador: (v) =>
                          v != _password.text ? 'Las contraseñas no coinciden' : null,
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 16),
                      AuthMensajeError(error),
                    ],
                    const SizedBox(height: 22),
                    AuthBoton(
                      texto: 'Crear cuenta',
                      icono: Icons.check,
                      cargando: estado.isLoading,
                      alPresionar: _enviar,
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text(
                          '¿Ya tienes cuenta?',
                          style: TextStyle(color: AppColors.textFaint, fontSize: 12.5),
                        ),
                        TextButton(
                          onPressed: () => context.go('/login'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.amber,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            minimumSize: const Size(0, 30),
                            textStyle:
                                const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                          ),
                          child: const Text('Inicia sesión'),
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

class _ConfirmaTuCorreo extends StatelessWidget {
  const _ConfirmaTuCorreo({required this.alVolver});
  final VoidCallback alVolver;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.mark_email_read_outlined, color: AppColors.amber, size: 48),
        const SizedBox(height: 16),
        const Text(
          'Revisa tu correo',
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        const Text(
          'Te enviamos un enlace para confirmar tu cuenta. Después podrás iniciar sesión.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textFaint, fontSize: 13),
        ),
        const SizedBox(height: 22),
        AuthBoton(
          texto: 'Ir a iniciar sesión',
          cargando: false,
          alPresionar: alVolver,
        ),
      ],
    );
  }
}
