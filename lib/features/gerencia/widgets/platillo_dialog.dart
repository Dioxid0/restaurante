import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/platillo.dart';
import '../../../domain/errors.dart';

/// Formulario para crear o editar un platillo. [alGuardar] hace el guardado y puede lanzar
/// [ErrorDeNegocio]; el mensaje se muestra dentro del diálogo.
class PlatilloDialog extends StatefulWidget {
  const PlatilloDialog({super.key, this.platillo, required this.alGuardar});
  final Platillo? platillo;
  final Future<void> Function(String nombre, double precio, CategoriaPlatillo categoria, bool disponible)
      alGuardar;

  @override
  State<PlatilloDialog> createState() => _PlatilloDialogState();
}

class _PlatilloDialogState extends State<PlatilloDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _nombre = TextEditingController(text: widget.platillo?.nombre ?? '');
  late final _precio = TextEditingController(
    text: widget.platillo == null ? '' : widget.platillo!.precio.toStringAsFixed(2),
  );
  late CategoriaPlatillo _categoria = widget.platillo?.categoria ?? CategoriaPlatillo.platosFuertes;
  late bool _disponible = widget.platillo?.disponible ?? true;
  bool _guardando = false;
  String? _error;

  @override
  void dispose() {
    _nombre.dispose();
    _precio.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      await widget.alGuardar(
        _nombre.text.trim(),
        double.parse(_precio.text.trim().replaceAll(',', '.')),
        _categoria,
        _disponible,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _guardando = false;
          _error = mensajeDeError(e, porDefecto: 'No se pudo guardar el platillo');
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
      title: Text(widget.platillo == null ? 'Nuevo platillo' : 'Editar platillo'),
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
                  maxLength: 80,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Indica el nombre' : null,
                ),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _precio,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Precio (con IVA)', prefixText: '\$ '),
                  validator: (v) {
                    final n = double.tryParse((v ?? '').trim().replaceAll(',', '.'));
                    if (n == null) return 'Indica un precio válido';
                    return n < 0 ? 'No puede ser negativo' : null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<CategoriaPlatillo>(
                  initialValue: _categoria,
                  decoration: const InputDecoration(labelText: 'Categoría'),
                  items: [
                    for (final c in CategoriaPlatillo.values)
                      DropdownMenuItem(value: c, child: Text(c.valorBd)),
                  ],
                  onChanged: (c) => setState(() => _categoria = c ?? _categoria),
                ),
                const SizedBox(height: 4),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Disponible'),
                  subtitle: const Text('Si se apaga, no se puede pedir (agotado)'),
                  value: _disponible,
                  onChanged: (v) => setState(() => _disponible = v),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 10),
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
