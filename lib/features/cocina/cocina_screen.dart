import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/ui/toast.dart';
import '../../core/utils/formato.dart';
import '../../domain/entities/cocina.dart';
import '../../domain/entities/pedido.dart';
import '../../domain/errors.dart';
import '../pedidos/pedidos_providers.dart';
import '../pedidos/widgets/boton_confirmable.dart';
import '../pedidos/widgets/pedido_chips.dart';
import 'cocina_providers.dart';

/// Cocina (CU-03, CU-06, CU-15): tablero con los pedidos pendientes, en preparación y
/// listos. El chef inicia la preparación y marca "listo"; entregar es del mesero.
/// Diseño provisional (sin Figma): reutiliza los chips y la burbuja de confirmación de la Comandería.
class CocinaScreen extends ConsumerStatefulWidget {
  const CocinaScreen({super.key});

  @override
  ConsumerState<CocinaScreen> createState() => _CocinaScreenState();
}

class _CocinaScreenState extends ConsumerState<CocinaScreen> {
  /// Avisos ya vistos en esta sesión: solo los nuevos disparan el aviso flotante.
  Set<int>? _vistos;

  void _avisarNuevos(List<AvisoCocina> lista) {
    final ids = lista.map((a) => a.idNotificacion).toSet();
    final anteriores = _vistos;
    _vistos = ids;
    if (anteriores == null) return; // primera carga: no se avisa de lo que ya estaba
    final nuevos = lista.where((a) => !anteriores.contains(a.idNotificacion)).toList();
    if (nuevos.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) mostrarToast(context, nuevos.map((a) => a.mensaje).join('\n'));
    });
  }

  Future<void> _avanzar(PedidoCocina p, EstadoPedido nuevo) async {
    try {
      await ref.read(cocinaPedidosProvider.notifier).avanzar(p.folio, nuevo);
    } catch (e) {
      if (mounted) mostrarToast(context, mensajeDeError(e), tipo: TipoToast.error);
    }
  }

  Future<void> _atender(Future<void> Function() accion) async {
    try {
      await accion();
    } catch (e) {
      if (mounted) mostrarToast(context, mensajeDeError(e), tipo: TipoToast.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(avisosCocinaProvider, (_, siguiente) {
      final lista = siguiente.value;
      if (lista != null) _avisarNuevos(lista);
    });
    final pedidos = ref.watch(cocinaPedidosProvider);
    final avisos = ref.watch(avisosCocinaProvider).value ?? const <AvisoCocina>[];
    final ahora = ref.watch(relojProvider).value ?? DateTime.now();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 26, 28, 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Titulo(),
              const SizedBox(height: 22),
              if (avisos.isNotEmpty) ...[
                _PanelAvisos(
                  avisos: avisos,
                  ahora: ahora,
                  alAtender: (a) =>
                      _atender(() => ref.read(avisosCocinaProvider.notifier).atender(a.idNotificacion)),
                  alAtenderTodos: () =>
                      _atender(() => ref.read(avisosCocinaProvider.notifier).atenderTodos()),
                ),
                const SizedBox(height: 18),
              ],
              if (pedidos.hasValue)
                _Tablero(pedidos: pedidos.requireValue, ahora: ahora, alAvanzar: _avanzar)
              else if (pedidos.hasError)
                _Error(alReintentar: () => ref.invalidate(cocinaPedidosProvider))
              else
                const Padding(
                  padding: EdgeInsets.all(60),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Titulo extends StatelessWidget {
  const _Titulo();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'OPERACIÓN / COCINA',
          style: TextStyle(
            color: AppColors.amber,
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 6),
        Text('Cocina', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600)),
        SizedBox(height: 4),
        Text(
          'Comandas del turno en tiempo real. Inicia la preparación y márcala como lista al terminar.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------------ avisos (CU-06)

class _PanelAvisos extends StatelessWidget {
  const _PanelAvisos({
    required this.avisos,
    required this.ahora,
    required this.alAtender,
    required this.alAtenderTodos,
  });

  final List<AvisoCocina> avisos;
  final DateTime ahora;
  final ValueChanged<AvisoCocina> alAtender;
  final VoidCallback alAtenderTodos;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.amberRow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_active_outlined, size: 19, color: Color(0xFFB45309)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Avisos de cocina (${avisos.length})',
                  style: const TextStyle(
                    color: Color(0xFFB45309),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (avisos.length > 1)
                TextButton(
                  onPressed: alAtenderTodos,
                  child: const Text('Entendido todos'),
                ),
            ],
          ),
          for (final a in avisos) _FilaAviso(aviso: a, ahora: ahora, alAtender: () => alAtender(a)),
        ],
      ),
    );
  }
}

class _FilaAviso extends StatelessWidget {
  const _FilaAviso({required this.aviso, required this.ahora, required this.alAtender});

  final AvisoCocina aviso;
  final DateTime ahora;
  final VoidCallback alAtender;

  @override
  Widget build(BuildContext context) {
    final (icono, color) = switch (aviso.tipo) {
      TipoAviso.nuevo => (Icons.add_circle_outline, const Color(0xFF059669)),
      TipoAviso.modificado => (Icons.edit_outlined, const Color(0xFF2563EB)),
      TipoAviso.cancelado => (Icons.cancel_outlined, const Color(0xFFB91C1C)),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icono, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              aviso.mensaje,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            formatoHora(aviso.hora),
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5),
          ),
          const SizedBox(width: 8),
          TextButton(onPressed: alAtender, child: const Text('Entendido')),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------ tablero (CU-03)

class _Tablero extends StatelessWidget {
  const _Tablero({required this.pedidos, required this.ahora, required this.alAvanzar});

  final List<PedidoCocina> pedidos;
  final DateTime ahora;
  final void Function(PedidoCocina, EstadoPedido) alAvanzar;

  static const _columnas = [
    EstadoPedido.pendiente,
    EstadoPedido.enPreparacion,
    EstadoPedido.listo,
  ];

  @override
  Widget build(BuildContext context) {
    final columnas = [
      for (final e in _columnas)
        _Columna(
          estado: e,
          pedidos: pedidos.where((p) => p.estado == e).toList(),
          ahora: ahora,
          alAvanzar: alAvanzar,
        ),
    ];
    return LayoutBuilder(
      builder: (context, c) {
        // En ventanas angostas las columnas se apilan.
        if (c.maxWidth < 900) {
          return Column(
            children: [
              for (final col in columnas) ...[col, const SizedBox(height: 16)],
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < columnas.length; i++) ...[
              if (i > 0) const SizedBox(width: 16),
              Expanded(child: columnas[i]),
            ],
          ],
        );
      },
    );
  }
}

class _Columna extends StatelessWidget {
  const _Columna({
    required this.estado,
    required this.pedidos,
    required this.ahora,
    required this.alAvanzar,
  });

  final EstadoPedido estado;
  final List<PedidoCocina> pedidos;
  final DateTime ahora;
  final void Function(PedidoCocina, EstadoPedido) alAvanzar;

  @override
  Widget build(BuildContext context) {
    final vacio = switch (estado) {
      EstadoPedido.pendiente => 'No hay pedidos por preparar',
      EstadoPedido.enPreparacion => 'No hay pedidos en preparación',
      _ => 'No hay pedidos listos',
    };
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              EstadoChip(estado),
              const Spacer(),
              Text(
                '${pedidos.length}',
                key: Key('conteo_${estado.valorBd}'),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (pedidos.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: Text(vacio, style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
              ),
            ),
          for (final p in pedidos) ...[
            _Tarjeta(pedido: p, ahora: ahora, alAvanzar: alAvanzar),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _Tarjeta extends StatelessWidget {
  const _Tarjeta({required this.pedido, required this.ahora, required this.alAvanzar});

  final PedidoCocina pedido;
  final DateTime ahora;
  final void Function(PedidoCocina, EstadoPedido) alAvanzar;

  @override
  Widget build(BuildContext context) {
    final minutos = ahora.difference(pedido.horaIngreso).inMinutes;
    final mesa = pedido.mesaEtiqueta ?? (pedido.tipo == TipoPedido.paraLlevar ? 'Llevar' : '—');
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: const [BoxShadow(color: Color(0x0F0F172A), blurRadius: 10, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  pedido.folioEtiqueta,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ),
              TiempoChip(minutos: minutos < 0 ? 0 : minutos),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              TipoPedidoIcono(pedido.tipo),
              const SizedBox(width: 8),
              Text(mesa, style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
              if (pedido.esEnLinea) ...[
                const SizedBox(width: 8),
                const Text('· En línea', style: TextStyle(color: AppColors.textFaint, fontSize: 12)),
              ],
            ],
          ),
          const Divider(height: 22, color: AppColors.borderSoft),
          for (final r in pedido.renglones) _Renglon(r),
          const SizedBox(height: 10),
          _accion(),
        ],
      ),
    );
  }

  Widget _accion() {
    switch (pedido.estado) {
      case EstadoPedido.pendiente:
        return Align(
          alignment: Alignment.centerRight,
          child: BotonConfirmable(
            icono: Icons.play_arrow_rounded,
            etiqueta: 'Iniciar preparación',
            tooltip: 'Iniciar preparación',
            titulo: '¿Iniciar la preparación?',
            detalle: pedido.folioEtiqueta,
            textoConfirmar: 'Iniciar',
            color: const Color(0xFF2563EB),
            alConfirmar: () => alAvanzar(pedido, EstadoPedido.enPreparacion),
          ),
        );
      case EstadoPedido.enPreparacion:
        return Align(
          alignment: Alignment.centerRight,
          child: BotonConfirmable(
            icono: Icons.check_circle_outline,
            etiqueta: 'Marcar listo',
            tooltip: 'Marcar como listo',
            titulo: '¿Marcar como Listo?',
            detalle: pedido.folioEtiqueta,
            textoConfirmar: 'Listo',
            color: const Color(0xFF059669),
            alConfirmar: () => alAvanzar(pedido, EstadoPedido.listo),
          ),
        );
      default:
        return const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Esperando al mesero',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontStyle: FontStyle.italic),
          ),
        );
    }
  }
}

class _Renglon extends StatelessWidget {
  const _Renglon(this.r);
  final RenglonCocina r;

  @override
  Widget build(BuildContext context) {
    final nota = r.nota?.trim();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 34,
            child: Text(
              '${r.cantidad}×',
              style: const TextStyle(
                color: AppColors.amber,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.nombre, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                if (nota != null && nota.isNotEmpty)
                  Text(
                    'Nota: $nota',
                    style: const TextStyle(
                      color: Color(0xFFB45309),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.alReintentar});
  final VoidCallback alReintentar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Center(
        child: Column(
          children: [
            const Text('No se pudieron cargar las comandas'),
            const SizedBox(height: 12),
            FilledButton(onPressed: alReintentar, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}
