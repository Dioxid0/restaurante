import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'cuentas_view.dart';
import 'reporte_view.dart';

enum _Seccion { reporte, cuentas }

/// Gerencia: reporte gerencial (CU-07) y cuentas de personal.
/// (Diseño provisional hasta recibir la pantalla de Figma.)
class GerenciaScreen extends StatefulWidget {
  const GerenciaScreen({super.key});

  @override
  State<GerenciaScreen> createState() => _GerenciaScreenState();
}

class _GerenciaScreenState extends State<GerenciaScreen> {
  _Seccion _seccion = _Seccion.reporte;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 18, 28, 0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1500),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SegmentedButton<_Seccion>(
                  showSelectedIcon: false,
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: AppColors.navy800,
                    selectedForegroundColor: Colors.white,
                  ),
                  segments: const [
                    ButtonSegment(
                      value: _Seccion.reporte,
                      label: Text('Reporte'),
                      icon: Icon(Icons.bar_chart_rounded, size: 18),
                    ),
                    ButtonSegment(
                      value: _Seccion.cuentas,
                      label: Text('Cuentas'),
                      icon: Icon(Icons.group_outlined, size: 18),
                    ),
                  ],
                  selected: {_seccion},
                  onSelectionChanged: (s) => setState(() => _seccion = s.first),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: switch (_seccion) {
            _Seccion.reporte => const ReporteView(),
            _Seccion.cuentas => const CuentasView(),
          },
        ),
      ],
    );
  }
}
