import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/mesa.dart';
import '../../../domain/errors.dart';

/// Formulario para crear o editar una mesa (número y capacidad).
class MesaDialog extends StatefulWidget {
  const MesaDialog({super.key, this.mesa, required this.alGuardar});
  final Mesa? mesa;
  final Future<void> Function(int numero, int capacidad) alGuardar;

  @override
  State<MesaDialog> createState() => _MesaDialogState();
}

class _MesaDialogState extends State<MesaDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _numero = TextEditingController(text: widget.mesa?.numeroMesa.toString() ?? '');
  late final _capacidad = TextEditingController(text: widget.mesa?.capacidad.toString() ?? '');
  bool _guardando = false;
  String? _error;

  @override
  void dispose() {
    _numero.dispose();
    _capacidad.dispose();
    super.dispose();
  }

  String? _entero(String? v, String campo) {
    final n = int.tryParse((v ?? '').trim());
    if (n == null || n < 1) return 'Indica $campo (mínimo 1)';
    return null;
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      await widget.alGuardar(int.parse(_numero.text.trim()), int.parse(_capacidad.text.trim()));
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _guardando = false;
          _error = mensajeDeError(e, porDefecto: 'No se pudo guardar la mesa');
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
      title: Text(widget.mesa == null ? 'Nueva mesa' : 'Editar mesa'),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _numero,
                autofocus: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Número de mesa'),
                validator: (v) => _entero(v, 'el número'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _capacidad,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Capacidad (personas)'),
                validator: (v) => _entero(v, 'la capacidad'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 14),
                Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
              ],
            ],
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
