import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/repository_providers.dart';
import '../../domain/entities/mesa.dart';
import '../../domain/errors.dart';
import '../pedidos/comanda/comanda_providers.dart';
import 'widgets/mesa_dialog.dart';
import 'widgets/vista_comun.dart';

/// Gerencia → Mesas: alta, edición y baja de mesas.
/// El estado (libre / ocupada) lo calcula la base según los pedidos; aquí no se edita.
/// (Diseño provisional hasta recibir la pantalla de Figma.)
class MesasAdminView extends ConsumerWidget {
  const MesasAdminView({super.key});

  static const _flex = [20, 20, 20, 24];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mesas = ref.watch(mesasProvider);
    final repo = ref.read(mesaRepositoryProvider);

    Future<void> nueva() async {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => MesaDialog(alGuardar: (n, c) => repo.crear(numeroMesa: n, capacidad: c)),
      );
      if (ok == true) {
        ref.invalidate(mesasProvider);
        if (context.mounted) avisar(context, 'Mesa creada');
      }
    }

    Future<void> editar(Mesa m) async {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => MesaDialog(
          mesa: m,
          alGuardar: (n, c) => repo.actualizar(m.idMesa, numeroMesa: n, capacidad: c),
        ),
      );
      if (ok == true) {
        ref.invalidate(mesasProvider);
        if (context.mounted) avisar(context, 'Mesa actualizada');
      }
    }

    Future<void> eliminar(Mesa m) async {
      final si = await confirmar(
        context,
        titulo: 'Eliminar mesa',
        mensaje: '¿Eliminar la ${m.etiqueta.toLowerCase()}? Esta acción no se puede deshacer.',
      );
      if (!si) return;
      try {
        await repo.eliminar(m.idMesa);
        ref.invalidate(mesasProvider);
        if (context.mounted) avisar(context, 'Mesa eliminada');
      } catch (e) {
        if (context.mounted) avisar(context, mensajeDeError(e));
      }
    }

    return SeccionGerencia(
      kicker: 'GERENCIA / MESAS',
      titulo: 'Mesas',
      descripcion: 'Administra las mesas del restaurante y su capacidad.',
      accion: BotonAccion(etiqueta: 'Nueva mesa', icono: Icons.add, alPresionar: nueva),
      hijo: PanelBlanco(
        anchoMinimo: 560,
        hijo: mesas.when(
          loading: () => const CargandoOError(),
          error: (e, _) => CargandoOError(
            mensaje: 'No se pudieron cargar las mesas',
            alReintentar: () => ref.invalidate(mesasProvider),
          ),
          data: (lista) => Column(
            children: [
              FilaTabla(
                flex: _flex,
                encabezado: true,
                celdas: [
                  encabezadoTabla('MESA'),
                  encabezadoTabla('CAPACIDAD'),
                  encabezadoTabla('ESTADO'),
                  encabezadoTabla('ACCIONES'),
                ],
              ),
              if (lista.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Todavía no hay mesas', style: TextStyle(color: AppColors.textMuted)),
                ),
              for (final m in lista)
                FilaTabla(
                  flex: _flex,
                  celdas: [
                    Text(m.etiqueta, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    Text('${m.capacidad} personas', style: const TextStyle(fontSize: 13)),
                    Text(
                      switch (m.estado) {
                        EstadoMesa.libre => 'Libre',
                        EstadoMesa.ocupada => 'Ocupada',
                        EstadoMesa.reservada => 'Reservada',
                      },
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        TextButton(onPressed: () => editar(m), child: const Text('Editar')),
                        TextButton(
                          onPressed: () => eliminar(m),
                          style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                          child: const Text('Eliminar'),
                        ),
                      ],
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
