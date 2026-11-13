import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/cuenta_personal.dart';
import '../../domain/errors.dart';
import '../auth/auth_providers.dart';
import 'gerencia_providers.dart';
import 'widgets/editar_cuenta_dialog.dart';
import 'widgets/nueva_cuenta_dialog.dart';
import 'widgets/vista_comun.dart';

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

    // Mismo marco que Menú, Mesas y Bitácora: en teléfono el botón baja y la tabla se desplaza.
    return SeccionGerencia(
      kicker: 'GERENCIA / CUENTAS',
      titulo: 'Cuentas de personal',
      descripcion:
          'Crea y administra las cuentas de meseros, chefs y gerentes.',
      accion: BotonAccion(
        etiqueta: 'Nueva cuenta',
        icono: Icons.person_add_alt,
        alPresionar: nueva,
      ),
      hijo: PanelBlanco(
        anchoMinimo: 760,
        hijo: cuentas.when(
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
            alEditar: (c) async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => EditarCuentaDialog(
                  cuenta: c,
                  esPropia: c.idEmpleado == yo?.id,
                ),
              );
              if (ok == true && context.mounted) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(content: Text('Cuenta actualizada')),
                  );
              }
            },
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
    );
  }
}

class _Tabla extends StatelessWidget {
  const _Tabla({
    required this.cuentas,
    required this.idPropio,
    required this.alCambiarActivo,
    required this.alEditar,
  });

  final List<CuentaPersonal> cuentas;
  final int? idPropio;
  final Future<void> Function(CuentaPersonal, bool) alCambiarActivo;
  final Future<void> Function(CuentaPersonal) alEditar;

  static const _flex = [22, 18, 12, 12, 12, 24];

  Widget _fila(
    List<Widget> celdas, {
    Color fondo = Colors.white,
    double alto = 52,
  }) => Container(
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
        _fila(
          [
            _th('NOMBRE'),
            _th('USUARIO'),
            _th('ROL'),
            _th('TURNO'),
            _th('ESTADO'),
            _th('ACCIONES'),
          ],
          fondo: const Color(0xFFF8FAFC),
          alto: 40,
        ),
        for (final c in cuentas)
          _fila([
            Text(
              c.nombre,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            Text(
              c.usuario,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            Text(c.rol.etiqueta, style: const TextStyle(fontSize: 13)),
            Text(
              c.turno ?? '—',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            _EstadoCuenta(activo: c.activo),
            Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                TextButton(
                  onPressed: () => alEditar(c),
                  child: const Text('Editar'),
                ),
                if (c.idEmpleado == idPropio)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '(tú)',
                      style: TextStyle(
                        color: AppColors.textFaint,
                        fontSize: 12,
                      ),
                    ),
                  )
                else
                  TextButton(
                    onPressed: () => alCambiarActivo(c, !c.activo),
                    child: Text(c.activo ? 'Desactivar' : 'Activar'),
                  ),
              ],
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
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
