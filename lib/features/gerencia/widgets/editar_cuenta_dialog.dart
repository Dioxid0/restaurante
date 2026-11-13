import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/cuenta_personal.dart';
import '../../../domain/entities/perfil.dart';
import '../../../domain/errors.dart';
import '../gerencia_providers.dart';

/// Edita nombre, turno y rol de una cuenta de personal. El usuario y la contraseña no cambian aquí.
class EditarCuentaDialog extends ConsumerStatefulWidget {
  const EditarCuentaDialog({super.key, required this.cuenta, required this.esPropia});
  final CuentaPersonal cuenta;

  /// Tu propia cuenta: el rol no se puede cambiar (también lo impide la base).
  final bool esPropia;

  @override
  ConsumerState<EditarCuentaDialog> createState() => _EditarCuentaDialogState();
}

class _EditarCuentaDialogState extends ConsumerState<EditarCuentaDialog> {
  static const _turnos = ['Matutino', 'Vespertino', 'Nocturno'];

  final _formKey = GlobalKey<FormState>();
  late final _nombre = TextEditingController(text: widget.cuenta.nombre);
  late RolUsuario _rol = widget.cuenta.rol;
  late String? _turno = _turnos
      .cast<String?>()
      .firstWhere((t) => t!.toLowerCase() == widget.cuenta.turno?.toLowerCase(), orElse: () => null);
  bool _guardando = false;
  String? _error;

  @override
  void dispose() {
    _nombre.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      await ref.read(cuentasPersonalProvider.notifier).editar(
            widget.cuenta.idEmpleado,
            nombre: _nombre.text.trim(),
            turno: _turno?.toLowerCase(),
            rol: _rol,
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _guardando = false;
          _error = mensajeDeError(e, porDefecto: 'No se pudo guardar la cuenta');
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
      title: const Text('Editar cuenta'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nombre,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Nombre completo',
                    helperText: 'Usuario: ${widget.cuenta.usuario}',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Indica el nombre' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<RolUsuario>(
                        initialValue: _rol,
                        decoration: InputDecoration(
                          labelText: 'Rol',
                          helperText: widget.esPropia ? 'No puedes cambiar tu rol' : null,
                        ),
                        items: [
                          for (final r in RolUsuario.values.where((r) => r.esPersonal))
                            DropdownMenuItem(value: r, child: Text(r.etiqueta)),
                        ],
                        onChanged: widget.esPropia ? null : (r) => setState(() => _rol = r ?? _rol),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        initialValue: _turno,
                        decoration: const InputDecoration(labelText: 'Turno'),
                        items: [
                          const DropdownMenuItem<String?>(value: null, child: Text('Sin turno')),
                          for (final t in _turnos) DropdownMenuItem<String?>(value: t, child: Text(t)),
                        ],
                        onChanged: (t) => setState(() => _turno = t),
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
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
