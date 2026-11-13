import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/perfil.dart';
import '../../../domain/errors.dart';
import '../gerencia_providers.dart';

/// Formulario para crear una cuenta de personal (usuario, contraseña y rol).
class NuevaCuentaDialog extends ConsumerStatefulWidget {
  const NuevaCuentaDialog({super.key});

  @override
  ConsumerState<NuevaCuentaDialog> createState() => _NuevaCuentaDialogState();
}

class _NuevaCuentaDialogState extends ConsumerState<NuevaCuentaDialog> {
  static const _turnos = ['Matutino', 'Vespertino', 'Nocturno'];

  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _usuario = TextEditingController();
  final _password = TextEditingController();
  RolUsuario _rol = RolUsuario.mesero;
  String _turno = _turnos.first;
  bool _verPassword = false;
  bool _guardando = false;
  String? _error;

  @override
  void dispose() {
    _nombre.dispose();
    _usuario.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      await ref.read(cuentasPersonalProvider.notifier).crear(
            nombre: _nombre.text,
            usuario: _usuario.text,
            password: _password.text,
            rol: _rol,
            turno: _turno.toLowerCase(),
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _guardando = false;
          _error = mensajeDeError(e, porDefecto: 'No se pudo crear la cuenta');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Text('Nueva cuenta de personal'),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nombre,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Nombre completo'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Indica el nombre' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _usuario,
                  decoration: const InputDecoration(
                    labelText: 'Usuario',
                    hintText: 'Juan Perez',
                    helperText: 'Con este nombre inicia sesión (sin importar mayúsculas ni acentos)',
                  ),
                  validator: (v) {
                    final t = (v ?? '').trim();
                    if (t.contains('@')) return 'No puede ser un correo';
                    return t.length < 3 ? 'Mínimo 3 caracteres' : null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _password,
                  obscureText: !_verPassword,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    helperText: 'Mínimo 8 caracteres',
                    suffixIcon: IconButton(
                      icon: Icon(_verPassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _verPassword = !_verPassword),
                    ),
                  ),
                  validator: (v) => (v == null || v.length < 8) ? 'Mínimo 8 caracteres' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<RolUsuario>(
                        initialValue: _rol,
                        decoration: const InputDecoration(labelText: 'Rol'),
                        items: [
                          for (final r in RolUsuario.values.where((r) => r.esPersonal))
                            DropdownMenuItem(value: r, child: Text(r.etiqueta)),
                        ],
                        onChanged: (r) => setState(() => _rol = r ?? _rol),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _turno,
                        decoration: const InputDecoration(labelText: 'Turno'),
                        items: [for (final t in _turnos) DropdownMenuItem(value: t, child: Text(t))],
                        onChanged: (t) => setState(() => _turno = t ?? _turno),
                      ),
                    ),
                  ],
                ),
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _guardando ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _guardando ? null : _guardar,
          style: FilledButton.styleFrom(backgroundColor: AppColors.amber),
          child: _guardando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                )
              : const Text('Crear cuenta'),
        ),
      ],
    );
  }
}
