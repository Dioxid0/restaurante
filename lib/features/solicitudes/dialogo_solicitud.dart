import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/solicitud_cambio.dart';

/// Pide al mesero qué quiere hacer (modificar o cancelar) y el motivo. Devuelve null si cierra.
Future<({TipoSolicitud tipo, String motivo})?> mostrarDialogoSolicitud(
  BuildContext context, {
  required String folio,
}) =>
    showDialog<({TipoSolicitud tipo, String motivo})>(
      context: context,
      builder: (_) => DialogoSolicitud(folio: folio),
    );

class DialogoSolicitud extends StatefulWidget {
  const DialogoSolicitud({super.key, required this.folio});
  final String folio;

  @override
  State<DialogoSolicitud> createState() => _DialogoSolicitudState();
}

class _DialogoSolicitudState extends State<DialogoSolicitud> {
  final _motivo = TextEditingController();
  TipoSolicitud _tipo = TipoSolicitud.modificar;

  @override
  void dispose() {
    _motivo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final motivo = _motivo.text.trim();
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      title: Text('Solicitar cambio · ${widget.folio}'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'El pedido ya está en cocina. El gerente debe aprobar el cambio; si lo aprueba, '
              'tendrás 10 minutos para hacerlo.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12.5),
            ),
            const SizedBox(height: 14),
            SegmentedButton<TipoSolicitud>(
              segments: [
                for (final t in TipoSolicitud.values)
                  ButtonSegment<TipoSolicitud>(value: t, label: Text(t.etiqueta)),
              ],
              selected: {_tipo},
              onSelectionChanged: (s) => setState(() => _tipo = s.first),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _motivo,
              maxLength: 200,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Motivo de la solicitud',
                hintText: 'Ej. El cliente quiere cambiar su platillo',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Volver')),
        FilledButton(
          onPressed: motivo.isEmpty ? null : () => Navigator.pop(context, (tipo: _tipo, motivo: motivo)),
          style: FilledButton.styleFrom(backgroundColor: AppColors.amber),
          child: const Text('Enviar solicitud'),
        ),
      ],
    );
  }
}
