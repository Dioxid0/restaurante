import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../presentation/widgets/brand_mark.dart';
import 'auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usuario = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _usuario.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(loginControllerProvider.notifier)
        .ingresar(_usuario.text, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(loginControllerProvider);
    final cargando = estado.isLoading;
    final error = LoginController.mensaje(estado);

    return Scaffold(
      backgroundColor: AppColors.navy800,
      body: Stack(
        children: [
          // Resplandor ámbar de la esquina superior derecha
          Positioned(
            top: -220,
            right: -180,
            child: Container(
              width: 560,
              height: 560,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.amber.withValues(alpha: 0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: _Tarjeta(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Center(child: BrandMark()),
                              const SizedBox(height: 22),
                              const Center(
                                child: Text(
                                  'BIENVENIDO',
                                  style: TextStyle(
                                    color: AppColors.amber,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.6,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Center(
                                child: Text(
                                  'Iniciar Sesión',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Center(
                                child: Text(
                                  'Ingresa tus credenciales para continuar',
                                  style: TextStyle(
                                    color: AppColors.textFaint,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),
                              _Campo(
                                etiqueta: 'Usuario / ID Empleado',
                                controlador: _usuario,
                                icono: Icons.person_outline,
                                hint: 'Ej. EMP-1024',
                                autofocus: true,
                                accion: TextInputAction.next,
                                validador: (v) => (v == null || v.trim().isEmpty)
                                    ? 'Ingresa tu usuario'
                                    : null,
                              ),
                              const SizedBox(height: 18),
                              _Campo(
                                etiqueta: 'Contraseña',
                                controlador: _password,
                                icono: Icons.lock_outline,
                                hint: '••••••••',
                                oculto: true,
                                accion: TextInputAction.done,
                                alEnviar: (_) => _enviar(),
                                validador: (v) => (v == null || v.isEmpty)
                                    ? 'Ingresa tu contraseña'
                                    : null,
                              ),
                              if (error != null) ...[
                                const SizedBox(height: 16),
                                _MensajeError(error),
                              ],
                              const SizedBox(height: 22),
                              SizedBox(
                                height: 48,
                                child: FilledButton(
                                  onPressed: cargando ? null : _enviar,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.amber,
                                    disabledBackgroundColor:
                                        AppColors.amber.withValues(alpha: 0.6),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: cargando
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Ingresar al Sistema',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Icon(Icons.arrow_forward, size: 18),
                                          ],
                                        ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.lock_outline,
                                      size: 12, color: AppColors.textMuted),
                                  SizedBox(width: 6),
                                  Text(
                                    'Acceso seguro y protegido',
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 18),
                child: Text(
                  'El Buen Sabor v1.0 — Sistema Restringido',
                  style: TextStyle(color: Color(0xFF475A7A), fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tarjeta extends StatelessWidget {
  const _Tarjeta({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(36, 32, 36, 26),
      decoration: BoxDecoration(
        color: AppColors.navy700,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.navyBorder),
        boxShadow: const [
          BoxShadow(color: Color(0x66000000), blurRadius: 40, offset: Offset(0, 20)),
        ],
      ),
      child: child,
    );
  }
}

class _Campo extends StatelessWidget {
  const _Campo({
    required this.etiqueta,
    required this.controlador,
    required this.icono,
    required this.hint,
    required this.validador,
    required this.accion,
    this.oculto = false,
    this.autofocus = false,
    this.alEnviar,
  });

  final String etiqueta;
  final TextEditingController controlador;
  final IconData icono;
  final String hint;
  final bool oculto;
  final bool autofocus;
  final TextInputAction accion;
  final ValueChanged<String>? alEnviar;
  final String? Function(String?) validador;

  OutlineInputBorder _borde(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          etiqueta,
          style: const TextStyle(
            color: Color(0xFFCBD5E1),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controlador,
          obscureText: oculto,
          autofocus: autofocus,
          textInputAction: accion,
          onFieldSubmitted: alEnviar,
          validator: validador,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          cursorColor: AppColors.amber,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF475A7A)),
            prefixIcon: Icon(icono, color: AppColors.textMuted, size: 20),
            filled: true,
            fillColor: AppColors.navy800,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            enabledBorder: _borde(AppColors.navyBorder),
            focusedBorder: _borde(AppColors.amber),
            errorBorder: _borde(AppColors.danger),
            focusedErrorBorder: _borde(AppColors.danger),
            errorStyle: const TextStyle(color: Color(0xFFF87171)),
          ),
        ),
      ],
    );
  }
}

class _MensajeError extends StatelessWidget {
  const _MensajeError(this.mensaje);
  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFF87171), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              mensaje,
              style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
