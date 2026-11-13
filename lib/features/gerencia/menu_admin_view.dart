import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formato.dart';
import '../../data/repository_providers.dart';
import '../../domain/entities/platillo.dart';
import '../../domain/errors.dart';
import '../pedidos/comanda/comanda_providers.dart';
import 'widgets/platillo_dialog.dart';
import 'widgets/vista_comun.dart';

/// Gerencia → Menú: alta, edición, disponibilidad y baja de platillos.
/// (Diseño provisional hasta recibir la pantalla de Figma.)
class MenuAdminView extends ConsumerWidget {
  const MenuAdminView({super.key});

  static const _flex = [30, 20, 14, 16, 20];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menu = ref.watch(menuProvider);
    final repo = ref.read(menuRepositoryProvider);

    Future<void> nuevo() async {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => PlatilloDialog(
          alGuardar: (n, p, c, d) => repo.crear(nombre: n, precio: p, categoria: c, disponible: d),
        ),
      );
      if (ok == true) {
        ref.invalidate(menuProvider);
        if (context.mounted) avisar(context, 'Platillo creado');
      }
    }

    Future<void> editar(Platillo p) async {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => PlatilloDialog(
          platillo: p,
          alGuardar: (n, pr, c, d) =>
              repo.actualizar(p.idPlatillo, nombre: n, precio: pr, categoria: c, disponible: d),
        ),
      );
      if (ok == true) {
        ref.invalidate(menuProvider);
        if (context.mounted) avisar(context, 'Platillo actualizado');
      }
    }

    Future<void> cambiarDisponible(Platillo p, bool disponible) async {
      try {
        await repo.actualizar(p.idPlatillo,
            nombre: p.nombre, precio: p.precio, categoria: p.categoria, disponible: disponible);
        ref.invalidate(menuProvider);
      } catch (e) {
        if (context.mounted) avisar(context, mensajeDeError(e));
      }
    }

    Future<void> eliminar(Platillo p) async {
      final si = await confirmar(
        context,
        titulo: 'Eliminar platillo',
        mensaje: '¿Eliminar "${p.nombre}" del menú? Esta acción no se puede deshacer.',
      );
      if (!si) return;
      try {
        await repo.eliminar(p.idPlatillo);
        ref.invalidate(menuProvider);
        if (context.mounted) avisar(context, 'Platillo eliminado');
      } catch (e) {
        if (context.mounted) avisar(context, mensajeDeError(e));
      }
    }

    return SeccionGerencia(
      kicker: 'GERENCIA / MENÚ',
      titulo: 'Menú',
      descripcion: 'Agrega platillos, cambia precios y marca lo que se agotó.',
      accion: BotonAccion(etiqueta: 'Nuevo platillo', icono: Icons.add, alPresionar: nuevo),
      hijo: PanelBlanco(
        hijo: menu.when(
          loading: () => const CargandoOError(),
          error: (e, _) => CargandoOError(
            mensaje: 'No se pudo cargar el menú',
            alReintentar: () => ref.invalidate(menuProvider),
          ),
          data: (lista) => Column(
            children: [
              FilaTabla(
                flex: _flex,
                encabezado: true,
                celdas: [
                  encabezadoTabla('NOMBRE'),
                  encabezadoTabla('CATEGORÍA'),
                  encabezadoTabla('PRECIO'),
                  encabezadoTabla('DISPONIBLE'),
                  encabezadoTabla('ACCIONES'),
                ],
              ),
              if (lista.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Todavía no hay platillos', style: TextStyle(color: AppColors.textMuted)),
                ),
              for (final p in lista)
                FilaTabla(
                  flex: _flex,
                  celdas: [
                    Text(p.nombre, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    Text(p.categoria.valorBd, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                    Text(formatoMoneda(p.precio), style: const TextStyle(fontSize: 13)),
                    Switch(
                      value: p.disponible,
                      onChanged: (v) => cambiarDisponible(p, v),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(onPressed: () => editar(p), child: const Text('Editar')),
                        TextButton(
                          onPressed: () => eliminar(p),
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
