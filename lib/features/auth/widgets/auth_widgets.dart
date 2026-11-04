import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Fondo oscuro con resplandor ámbar + contenido centrado + pie de página.
class AuthFondo extends StatelessWidget {
  const AuthFondo({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy800,
      body: Stack(
        children: [
          Positioned(
            top: -220,
            right: -180,
            child: Container(
              width: 560,
              height: 560,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.amber.withValues(alpha: 0.22), Colors.transparent],
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
                      child: child,
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

class AuthTarjeta extends StatelessWidget {
  const AuthTarjeta({super.key, required this.child});
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

/// Encabezado de las tarjetas de auth: "BIENVENIDO / título / subtítulo".
class AuthTitulos extends StatelessWidget {
  const AuthTitulos({super.key, required this.titulo, required this.subtitulo});
  final String titulo;
  final String subtitulo;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'BIENVENIDO',
          style: TextStyle(
            color: AppColors.amber,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          titulo,
          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          subtitulo,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textFaint, fontSize: 13),
        ),
      ],
    );
  }
}

class AuthCampo extends StatelessWidget {
  const AuthCampo({
    super.key,
    required this.etiqueta,
    required this.controlador,
    required this.icono,
    required this.hint,
    required this.validador,
    this.accion = TextInputAction.next,
    this.oculto = false,
    this.autofocus = false,
    this.alEnviar,
    this.teclado,
  });

  final String etiqueta;
  final TextEditingController controlador;
  final IconData icono;
  final String hint;
  final bool oculto;
  final bool autofocus;
  final TextInputAction accion;
  final TextInputType? teclado;
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
          keyboardType: teclado,
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

class AuthMensajeError extends StatelessWidget {
  const AuthMensajeError(this.mensaje, {super.key});
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

class AuthBoton extends StatelessWidget {
  const AuthBoton({
    super.key,
    required this.texto,
    required this.cargando,
    required this.alPresionar,
    this.icono = Icons.arrow_forward,
  });

  final String texto;
  final bool cargando;
  final VoidCallback alPresionar;
  final IconData icono;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: FilledButton(
        onPressed: cargando ? null : alPresionar,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.amber,
          disabledBackgroundColor: AppColors.amber.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: cargando
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(texto, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  Icon(icono, size: 18),
                ],
              ),
      ),
    );
  }
}
