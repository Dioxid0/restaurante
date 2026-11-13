import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formato.dart';

typedef ResultadoDescuento = ({double monto, bool esCortesia, String motivo});

/// CU-09 (gerente): pide si es descuento o cortesía, el monto y el motivo.
/// [bruto] es lo que cuesta el pedido sin descuento; [descuentoActual] > 0 si ya tiene uno
/// (entonces se ofrece "Quitar descuento"). Devuelve null si el gerente cierra el cuadro.
Future<ResultadoDescuento?> mostrarDialogoDescuento(
  BuildContext context, {
  required String folio,
  required double bruto,
  required double descuentoActual,
}) =>
    showDialog<ResultadoDescuento>(
      context: context,
      builder: (_) => DialogoDescuento(folio: folio, bruto: bruto, descuentoActual: descuentoActual),
    );

class DialogoDescuento extends StatefulWidget {
  const DialogoDescuento({
    super.key,
    required this.folio,
    required this.bruto,
    required this.descuentoActual,
  });

  final String folio;
  final double bruto;
  final double descuentoActual;

  @override
  State<DialogoDescuento> createState() => _DialogoDescuentoState();
}

enum _Modo { porcentaje, monto, cortesia }

class _DialogoDescuentoState extends State<DialogoDescuento> {
  static const _atajos = [10, 15, 20, 25, 50];

  final _porcentaje = TextEditingController();
  final _monto = TextEditingController();
  final _motivo = TextEditingController();
  _Modo _modo = _Modo.porcentaje;

  @override
  void dispose() {
    _porcentaje.dispose();
    _monto.dispose();
    _motivo.dispose();
    super.dispose();
  }

  double? _numero(TextEditingController c) => double.tryParse(c.text.trim().replaceAll(',', '.'));

  /// Importe del descuento que resulta de lo escrito (null si todavía no es válido).
  double? get _importe {
    switch (_modo) {
      case _Modo.cortesia:
        return widget.bruto;
      case _Modo.porcentaje:
        final p = _numero(_porcentaje);
        if (p == null || p <= 0 || p > 100) return null;
        final importe = double.parse((widget.bruto * p / 100).toStringAsFixed(2));
        return importe > 0 ? importe : null;
      case _Modo.monto:
        final m = _numero(_monto);
        if (m == null || m <= 0 || m > widget.bruto) return null;
        return m;
    }
  }

  /// Mensaje bajo el campo (null si está bien o todavía vacío).
  String? get _error {
    if (_modo == _Modo.porcentaje) {
      if (_porcentaje.text.trim().isEmpty) return null;
      final p = _numero(_porcentaje);
      if (p == null || p <= 0) return 'Escribe un porcentaje mayor a 0';
      if (p > 100) return 'No puede pasar de 100 %';
    } else if (_modo == _Modo.monto) {
      if (_monto.text.trim().isEmpty) return null;
      final m = _numero(_monto);
      if (m == null || m <= 0) return 'Escribe un monto mayor a 0';
      if (m > widget.bruto) return 'No puede pasar de ${formatoMoneda(widget.bruto)}';
    }
    return null;
  }

  bool get _valido => _motivo.text.trim().isNotEmpty && _importe != null;

  @override
  Widget build(BuildContext context) {
    final importe = _importe;
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      title: Text('Descuento o cortesía · ${widget.folio}'),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total del pedido sin descuento: ${formatoMoneda(widget.bruto)}',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5),
              ),
              const SizedBox(height: 14),
              SegmentedButton<_Modo>(
                segments: const [
                  ButtonSegment<_Modo>(value: _Modo.porcentaje, label: Text('Porcentaje')),
                  ButtonSegment<_Modo>(value: _Modo.monto, label: Text('Monto')),
                  ButtonSegment<_Modo>(value: _Modo.cortesia, label: Text('Cortesía')),
                ],
                selected: {_modo},
                onSelectionChanged: (s) => setState(() => _modo = s.first),
              ),
              const SizedBox(height: 14),
              if (_modo == _Modo.cortesia)
                Text(
                  'Cortesía: el pedido completo (${formatoMoneda(widget.bruto)}) queda sin costo.',
                  style: const TextStyle(fontSize: 12.5),
                )
              else if (_modo == _Modo.porcentaje) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    for (final a in _atajos)
                      ActionChip(
                        label: Text('$a %'),
                        onPressed: () => setState(() => _porcentaje.text = '$a'),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _porcentaje,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Porcentaje de descuento',
                    suffixText: '%',
                    errorText: _error,
                  ),
                ),
              ] else
                TextField(
                  controller: _monto,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Monto del descuento',
                    prefixText: r'$ ',
                    errorText: _error,
                  ),
                ),
              if (importe != null && _modo != _Modo.cortesia) ...[
                const SizedBox(height: 8),
                Text(
                  'Se descuentan ${formatoMoneda(importe)} · Total final: ${formatoMoneda(widget.bruto - importe)}',
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
              ],
              const SizedBox(height: 12),
              TextField(
                controller: _motivo,
                maxLength: 200,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Motivo',
                  hintText: 'Ej. Queja por la demora',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Volver')),
        if (widget.descuentoActual > 0)
          TextButton(
            onPressed: () => Navigator.pop<ResultadoDescuento>(
              context,
              (monto: 0, esCortesia: false, motivo: 'Descuento retirado'),
            ),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Quitar descuento'),
          ),
        FilledButton(
          onPressed: !_valido
              ? null
              : () => Navigator.pop<ResultadoDescuento>(context, (
                    monto: _modo == _Modo.cortesia ? 0 : _importe!,
                    esCortesia: _modo == _Modo.cortesia,
                    motivo: _motivo.text.trim(),
                  )),
          style: FilledButton.styleFrom(backgroundColor: AppColors.amber),
          child: Text(_modo == _Modo.cortesia ? 'Aplicar cortesía' : 'Aplicar descuento'),
        ),
      ],
    );
  }
}
