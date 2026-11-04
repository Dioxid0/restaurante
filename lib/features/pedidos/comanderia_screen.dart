import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/pedido.dart';
import '../../domain/entities/perfil.dart';
import '../../domain/errors.dart';
import '../auth/auth_providers.dart';
import 'pedidos_providers.dart';
import 'widgets/pedidos_tabla.dart';

/// Filtros del selector "Estado".
enum FiltroEstado {
  activos('Activos'),
  todos('Todos'),
  pendiente('Pendiente'),
  enPreparacion('En Preparación'),
  listo('Listo'),
  entregado('Entregado'),
  completado('Completado'),
  cancelado('Cancelado');

  const FiltroEstado(this.etiqueta);
  final String etiqueta;

  bool acepta(EstadoPedido e) => switch (this) {
        FiltroEstado.activos => e.esActivo,
        FiltroEstado.todos => true,
        FiltroEstado.pendiente => e == EstadoPedido.pendiente,
        FiltroEstado.enPreparacion => e == EstadoPedido.enPreparacion,
        FiltroEstado.listo => e == EstadoPedido.listo,
        FiltroEstado.entregado => e == EstadoPedido.entregado,
        FiltroEstado.completado => e == EstadoPedido.completado,
        FiltroEstado.cancelado => e == EstadoPedido.cancelado,
      };
}

/// Pedidos por página (igual que en el diseño).
const _porPagina = 5;

class ComanderiaScreen extends ConsumerStatefulWidget {
  const ComanderiaScreen({super.key});

  @override
  ConsumerState<ComanderiaScreen> createState() => _ComanderiaScreenState();
}

class _ComanderiaScreenState extends ConsumerState<ComanderiaScreen> {
  FiltroEstado _filtro = FiltroEstado.activos;
  String _busqueda = '';
  int _pagina = 0;

  void _aviso(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _cambiarEstado(PedidoResumen p, EstadoPedido nuevo) async {
    try {
      await ref.read(pedidosDelDiaProvider.notifier).cambiarEstado(p.folio, nuevo);
    } catch (e) {
      _aviso(mensajeDeError(e));
    }
  }

  List<PedidoResumen> _filtrar(List<PedidoResumen> todos) {
    final q = _busqueda.trim().toLowerCase();
    return todos.where((p) {
      if (!_filtro.acepta(p.estado)) return false;
      if (q.isEmpty) return true;
      return p.folioEtiqueta.toLowerCase().contains(q) ||
          (p.mesaEtiqueta ?? '').toLowerCase().contains(q) ||
          (p.nombreMesero ?? '').toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final pedidos = ref.watch(pedidosDelDiaProvider);
    final ahora = ref.watch(relojProvider).value ?? DateTime.now();
    final rol = ref.watch(perfilActualProvider).value?.rol;
    // Mesero y gerente operan pedidos; el chef solo los consulta (su flujo va en "Cocina").
    final puedeOperar = rol == RolUsuario.mesero || rol == RolUsuario.gerente;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 26, 28, 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Titulo(
                alNuevo: puedeOperar ? () => context.go('/pedido/nuevo') : null,
              ),
              const SizedBox(height: 22),
              if (pedidos.hasValue)
                _contenido(pedidos.requireValue, ahora, puedeOperar)
              else if (pedidos.hasError)
                _Error(alReintentar: () => ref.invalidate(pedidosDelDiaProvider))
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

  Widget _contenido(List<PedidoResumen> todos, DateTime ahora, bool puedeOperar) {
    final filtrados = _filtrar(todos);
    final paginas = (filtrados.length / _porPagina).ceil().clamp(1, 1 << 30);
    final pagina = _pagina.clamp(0, paginas - 1);
    final visibles = filtrados.skip(pagina * _porPagina).take(_porPagina).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: const [BoxShadow(color: Color(0x0F0F172A), blurRadius: 16, offset: Offset(0, 4))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Comandas del Turno',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${filtrados.length} pedidos encontrados',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 300,
                  child: TextField(
                    onChanged: (v) => setState(() {
                      _busqueda = v;
                      _pagina = 0;
                    }),
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Buscar folio, mesa o empleado...',
                      hintStyle: const TextStyle(color: AppColors.textFaint, fontSize: 13),
                      prefixIcon: const Icon(Icons.search, size: 19, color: AppColors.textFaint),
                      filled: true,
                      fillColor: AppColors.pageBg,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 13),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(11),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(11),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _SelectorEstado(
                  valor: _filtro,
                  alCambiar: (f) => setState(() {
                    _filtro = f;
                    _pagina = 0;
                  }),
                ),
              ],
            ),
          ),
          PedidosTabla(
            pedidos: visibles,
            ahora: ahora,
            puedeOperar: puedeOperar,
            alCambiarEstado: _cambiarEstado,
            alEditar: (p) => context.go('/pedido/${p.folio}/editar'),
            alVer: (p) => _aviso('Pantalla "Detalle ${p.folioEtiqueta}" pendiente de diseño'),
          ),
          _Paginador(
            mostrando: visibles.length,
            total: filtrados.length,
            pagina: pagina,
            paginas: paginas,
            alCambiar: (p) => setState(() => _pagina = p),
          ),
        ],
      ),
    );
  }
}

class _Titulo extends StatelessWidget {
  const _Titulo({required this.alNuevo});

  /// null => el rol no puede registrar pedidos y el botón no se muestra.
  final VoidCallback? alNuevo;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'OPERACIÓN / PEDIDOS',
                style: TextStyle(
                  color: AppColors.amber,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Comandería y Mesas',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 4),
              Text(
                'Gestión y seguimiento de comandas en tiempo real.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ],
          ),
        ),
        if (alNuevo != null)
        FilledButton.icon(
          onPressed: alNuevo,
          icon: const Icon(Icons.add, size: 20),
          label: const Text('Registrar Nuevo Pedido'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.amber,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
          ),
        ),
      ],
    );
  }
}

class _SelectorEstado extends StatelessWidget {
  const _SelectorEstado({required this.valor, required this.alCambiar});
  final FiltroEstado valor;
  final ValueChanged<FiltroEstado> alCambiar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 14, right: 8),
      decoration: BoxDecoration(
        color: AppColors.pageBg,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Estado', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          const SizedBox(width: 10),
          DropdownButtonHideUnderline(
            child: DropdownButton<FiltroEstado>(
              value: valor,
              isDense: true,
              borderRadius: BorderRadius.circular(10),
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              items: [
                for (final f in FiltroEstado.values)
                  DropdownMenuItem(value: f, child: Text(f.etiqueta)),
              ],
              onChanged: (f) {
                if (f != null) alCambiar(f);
              },
            ),
          ),
          const SizedBox(height: 44),
        ],
      ),
    );
  }
}

class _Paginador extends StatelessWidget {
  const _Paginador({
    required this.mostrando,
    required this.total,
    required this.pagina,
    required this.paginas,
    required this.alCambiar,
  });

  final int mostrando;
  final int total;
  final int pagina;
  final int paginas;
  final ValueChanged<int> alCambiar;

  @override
  Widget build(BuildContext context) {
    Widget boton(String texto, {required bool activo, VoidCallback? alTocar, bool seleccionado = false}) {
      return Padding(
        padding: const EdgeInsets.only(left: 6),
        child: InkWell(
          onTap: activo ? alTocar : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            constraints: const BoxConstraints(minWidth: 32),
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: seleccionado ? AppColors.amber : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: seleccionado ? AppColors.amber : AppColors.border),
            ),
            child: Text(
              texto,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: seleccionado
                    ? Colors.white
                    : activo
                        ? AppColors.text
                        : AppColors.textFaint,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFFFCFCFD),
        border: Border(top: BorderSide(color: AppColors.borderSoft)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Mostrando $mostrando de $total pedidos',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ),
          boton('Anterior', activo: pagina > 0, alTocar: () => alCambiar(pagina - 1)),
          for (var i = 0; i < paginas; i++)
            boton('${i + 1}', activo: true, seleccionado: i == pagina, alTocar: () => alCambiar(i)),
          boton('Siguiente', activo: pagina < paginas - 1, alTocar: () => alCambiar(pagina + 1)),
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
            const Text('No se pudieron cargar los pedidos'),
            const SizedBox(height: 12),
            FilledButton(onPressed: alReintentar, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}
