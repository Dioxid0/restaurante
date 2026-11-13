import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Pide el motivo de la cancelación (obligatorio). Lo usan la pantalla de edición y "Mis pedidos".
class DialogoMotivo extends StatefulWidget {
  const DialogoMotivo({super.key, required this.folio});
  final String folio;

  @override
  State<DialogoMotivo> createState() => _DialogoMotivoState();
}

class _DialogoMotivoState extends State<DialogoMotivo> {
  final _controlador = TextEditingController();

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final motivo = _controlador.text.trim();
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      title: Text('Cancelar pedido ${widget.folio}'),
      content: SizedBox(
        width: 400,
        child: TextField(
          controller: _controlador,
          autofocus: true,
          maxLength: 200,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            labelText: 'Motivo de la cancelación',
            hintText: 'Ej. El cliente se retiró',
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Volver')),
        FilledButton(
          onPressed: motivo.isEmpty ? null : () => Navigator.pop(context, motivo),
          style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
          child: const Text('Cancelar pedido'),
        ),
      ],
    );
  }
}
