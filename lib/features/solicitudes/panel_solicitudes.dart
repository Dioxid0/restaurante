import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/ui/toast.dart';
import '../../core/utils/formato.dart';
import '../../domain/entities/solicitud_cambio.dart';
import '../../domain/errors.dart';
import 'solicitudes_providers.dart';

/// Solicitudes de cambio pendientes (RN-03), para el gerente: arriba de la Comandería.
/// Si no hay ninguna pendiente no ocupa espacio.
class PanelSolicitudes extends ConsumerWidget {
  const PanelSolicitudes({super.key});

  Future<void> _resolver(BuildContext context, WidgetRef ref, SolicitudCambio s, bool aprobar) async {
    try {
      await ref.read(solicitudesDeHoyProvider.notifier).resolver(s.idSolicitud, aprobar: aprobar);
      if (!context.mounted) return;
      mostrarToast(
        context,
        aprobar
            ? 'Solicitud aprobada: ${s.nombreMesero ?? 'el mesero'} tiene 10 minutos para el pedido ${s.folioEtiqueta}'
            : 'Solicitud rechazada',
      );
    } catch (e) {
      if (context.mounted) mostrarToast(context, mensajeDeError(e), tipo: TipoToast.error);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lista = ref.watch(solicitudesDeHoyProvider).value ?? const <SolicitudCambio>[];
    final pendientes = lista.where((s) => s.estaPendiente).toList().reversed.toList();
    if (pendientes.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      decoration: BoxDecoration(
        color: AppColors.amberRow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Solicitudes de cambio pendientes (${pendientes.length})',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
          const SizedBox(height: 4),
          const Text(
            'Si apruebas, el mesero tiene 10 minutos para modificar o cancelar ese pedido.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 8),
          for (final s in pendientes)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(s.folioEtiqueta, style: const TextStyle(fontWeight: FontWeight.w800)),
                  Text(
                    '${s.nombreMesero ?? 'Mesero'} quiere ${s.tipo == TipoSolicitud.cancelar ? 'cancelar' : 'modificar'}'
                    ' · ${formatoHora(s.fecha)}',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Text('«${s.motivo}»', style: const TextStyle(fontSize: 12.5)),
                  ),
                  OutlinedButton(
                    onPressed: () => _resolver(context, ref, s, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: Color(0xFFFECACA)),
                      minimumSize: const Size(0, 34),
                    ),
                    child: const Text('Rechazar'),
                  ),
                  FilledButton(
                    onPressed: () => _resolver(context, ref, s, true),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.green,
                      minimumSize: const Size(0, 34),
                    ),
                    child: const Text('Aprobar'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
