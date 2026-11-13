import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/cuenta_personal.dart';
import '../../domain/errors.dart';
import '../auth/auth_providers.dart';
import 'gerencia_providers.dart';
import 'widgets/nueva_cuenta_dialog.dart';

/// Gerencia → Cuentas: administración de cuentas de personal.
/// (Diseño provisional hasta recibir la pantalla de Figma.)
class CuentasView extends ConsumerWidget {
  const CuentasView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cuentas = ref.watch(cuentasPersonalProvider);
    final yo = ref.watch(perfilActualProvider).value;

    Future<void> nueva() async {
      final creada = await showDialog<bool>(
        context: context,
        builder: (_) => const NuevaCuentaDialog(),
      );
      if (creada == true && context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('Cuenta creada')));
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 26, 28, 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GERENCIA / CUENTAS',
                          style: TextStyle(
                            color: AppColors.amber,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Cuentas de personal',
                          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Crea y administra las cuentas de meseros, chefs y gerentes.',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: nueva,
                    icon: const Icon(Icons.person_add_alt, size: 20),
                    label: const Text('Nueva cuenta'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.amber,
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                      textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                clipBehavior: Clip.antiAlias,
                child: cuentas.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(60),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => Padding(
                    padding: const EdgeInsets.all(48),
                    child: Center(
                      child: Column(
                        children: [
                          const Text('No se pudieron cargar las cuentas'),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: () => ref.invalidate(cuentasPersonalProvider),
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  data: (lista) => _Tabla(
                    cuentas: lista,
                    idPropio: yo?.id,
                    alCambiarActivo: (c, activo) async {
                      try {
                        await ref
                            .read(cuentasPersonalProvider.notifier)
                            .cambiarActivo(c.idEmpleado, activo: activo);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(mensajeDeError(e))));
                        }
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tabla extends StatelessWidget {
  const _Tabla({required this.cuentas, required this.idPropio, required this.alCambiarActivo});

  final List<CuentaPersonal> cuentas;
  final int? idPropio;
  final Future<void> Function(CuentaPersonal, bool) alCambiarActivo;

  static const _flex = [24, 20, 14, 14, 12, 16];

  Widget _fila(List<Widget> celdas, {Color fondo = Colors.white, double alto = 52}) => Container(
        height: alto,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: fondo,
          border: const Border(top: BorderSide(color: AppColors.borderSoft)),
        ),
        child: Row(
          children: [
            for (var i = 0; i < celdas.length; i++)
              Expanded(
                flex: _flex[i],
                child: Align(alignment: Alignment.centerLeft, child: celdas[i]),
              ),
          ],
        ),
      );

  Widget _th(String t) => Text(
        t,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _fila([_th('NOMBRE'), _th('USUARIO'), _th('ROL'), _th('TURNO'), _th('ESTADO'), _th('ACCIONES')],
            fondo: const Color(0xFFF8FAFC), alto: 40),
        for (final c in cuentas)
          _fila([
            Text(c.nombre, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            Text(c.usuario, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
            Text(c.rol.etiqueta, style: const TextStyle(fontSize: 13)),
            Text(c.turno ?? '—', style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
            _EstadoCuenta(activo: c.activo),
            Align(
              alignment: Alignment.centerRight,
              child: c.idEmpleado == idPropio
                  ? const Text('(tú)', style: TextStyle(color: AppColors.textFaint, fontSize: 12))
                  : TextButton(
                      onPressed: () => alCambiarActivo(c, !c.activo),
                      child: Text(c.activo ? 'Desactivar' : 'Activar'),
                    ),
            ),
          ]),
      ],
    );
  }
}

class _EstadoCuenta extends StatelessWidget {
  const _EstadoCuenta({required this.activo});
  final bool activo;

  @override
  Widget build(BuildContext context) {
    final color = activo ? const Color(0xFF059669) : AppColors.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: activo ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        activo ? 'Activa' : 'Inactiva',
        style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.w700),
      ),
    );
  }
}
