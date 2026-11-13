import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formato.dart';
import '../../domain/entities/entrada_bitacora.dart';
import '../../domain/errors.dart';
import 'bitacora_providers.dart';
import 'widgets/vista_comun.dart';

/// Gerencia → Bitácora (RNF-04): quién registró o modificó qué, y cuándo.
/// (Diseño provisional hasta recibir la pantalla de Figma.)
class BitacoraView extends ConsumerWidget {
  const BitacoraView({super.key});

  static const _flex = [16, 20, 18, 14, 14, 10];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtro = ref.watch(bitacoraFiltroProvider);
    final datos = ref.watch(bitacoraProvider);

    return SeccionGerencia(
      kicker: 'GERENCIA / BITÁCORA',
      titulo: 'Bitácora de auditoría',
      descripcion: 'Las últimas 100 acciones registradas por el sistema.',
      accion: Row(
        children: [
          SizedBox(
            width: 240,
            child: DropdownButtonFormField<String?>(
              initialValue: filtro,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Mostrar', isDense: true),
              items: [
                const DropdownMenuItem<String?>(value: null, child: Text('Todo')),
                for (final e in EntradaBitacora.tablas.entries)
                  DropdownMenuItem<String?>(value: e.key, child: Text(e.value)),
              ],
              onChanged: (t) => ref.read(bitacoraFiltroProvider.notifier).elegir(t),
            ),
          ),
          IconButton(
            tooltip: 'Actualizar',
            onPressed: () => ref.invalidate(bitacoraProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      hijo: PanelBlanco(
        anchoMinimo: 860,
        hijo: datos.when(
          loading: () => const CargandoOError(),
          error: (e, _) => CargandoOError(
            mensaje: mensajeDeError(e, porDefecto: 'No se pudo cargar la bitácora'),
            alReintentar: () => ref.invalidate(bitacoraProvider),
          ),
          data: (lista) => Column(
            children: [
              FilaTabla(
                flex: _flex,
                encabezado: true,
                celdas: [
                  encabezadoTabla('FECHA Y HORA'),
                  encabezadoTabla('QUIÉN'),
                  encabezadoTabla('SECCIÓN'),
                  encabezadoTabla('REGISTRO'),
                  encabezadoTabla('ACCIÓN'),
                  encabezadoTabla(''),
                ],
              ),
              if (lista.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No hay registros', style: TextStyle(color: AppColors.textMuted)),
                ),
              for (final b in lista)
                FilaTabla(
                  flex: _flex,
                  celdas: [
                    Text('${formatoFecha(b.fechaHora)} ${formatoHora(b.fechaHora)}',
                        style: const TextStyle(fontSize: 13)),
                    Text(b.quien, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    Text(b.tablaEtiqueta, style: const TextStyle(fontSize: 13)),
                    Text('#${b.idRegistro ?? '—'}',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                    Text(b.accionEtiqueta, style: const TextStyle(fontSize: 13)),
                    TextButton(
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (_) => _DetalleBitacora(entrada: b),
                      ),
                      child: const Text('Ver'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

String _texto(Object? v) => v == null ? '—' : '$v';

class _DetalleBitacora extends StatelessWidget {
  const _DetalleBitacora({required this.entrada});
  final EntradaBitacora entrada;

  @override
  Widget build(BuildContext context) {
    final cambios = entrada.cambios ?? const <String, dynamic>{};
    final lineas = <String>[
      for (final e in cambios.entries)
        if (entrada.esCambio && e.value is Map)
          '${e.key}: ${_texto((e.value as Map)['antes'])} → ${_texto((e.value as Map)['despues'])}'
        else
          '${e.key}: ${_texto(e.value)}',
    ];
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      title: Text('${entrada.accionEtiqueta} · ${entrada.tablaEtiqueta} #${entrada.idRegistro ?? '—'}'),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${entrada.quien} · ${formatoFecha(entrada.fechaHora)} ${formatoHora(entrada.fechaHora)}',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
              const SizedBox(height: 12),
              if (lineas.isEmpty)
                const Text('Sin cambios en los datos')
              else
                for (final l in lineas)
                  Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Text(l, style: const TextStyle(fontSize: 13))),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cerrar')),
      ],
    );
  }
}
