import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/pedido.dart';
import '../auth/auth_providers.dart';
import 'comanderia_screen.dart' show PaginadorPedidos, pedidosPorPagina;
import 'pedidos_providers.dart';
import 'widgets/pedidos_tabla.dart';

/// Inicio del cliente (CU-08): seguimiento de sus pedidos de hoy.
///
/// Es la Comandería del mesero simplificada: sin filtros ni buscador, sin Mesa/Tipo y sin
/// acciones; solo Folio, Hora, Estado y Total. La base (RLS) solo entrega los pedidos del
/// propio cliente, y se actualiza sola en tiempo real.
/// (Diseño provisional hasta recibir la pantalla de Figma.)
class MisPedidosScreen extends ConsumerStatefulWidget {
  const MisPedidosScreen({super.key});

  @override
  ConsumerState<MisPedidosScreen> createState() => _MisPedidosScreenState();
}

class _MisPedidosScreenState extends ConsumerState<MisPedidosScreen> {
  int _pagina = 0;

  @override
  Widget build(BuildContext context) {
    final pedidos = ref.watch(pedidosDelDiaProvider);
    final ahora = ref.watch(relojProvider).value ?? DateTime.now();
    final nombre = ref.watch(perfilActualProvider).value?.nombre ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 26, 28, 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Titulo(nombre: nombre, alNuevo: () => context.go('/pedido/nuevo')),
              const SizedBox(height: 22),
              if (pedidos.hasValue)
                _contenido(pedidos.requireValue, ahora)
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

  Widget _contenido(List<PedidoResumen> todos, DateTime ahora) {
    final paginas = (todos.length / pedidosPorPagina).ceil().clamp(1, 1 << 30);
    final pagina = _pagina.clamp(0, paginas - 1);
    final visibles = todos.skip(pagina * pedidosPorPagina).take(pedidosPorPagina).toList();

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
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pedidos de hoy', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Text(
                    todos.length == 1 ? '1 pedido' : '${todos.length} pedidos',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          if (todos.isEmpty)
            const _SinPedidos()
          else
            PedidosTabla.seguimiento(pedidos: visibles, ahora: ahora),
          PaginadorPedidos(
            mostrando: visibles.length,
            total: todos.length,
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
  const _Titulo({required this.nombre, required this.alNuevo});
  final String nombre;
  final VoidCallback alNuevo;

  @override
  Widget build(BuildContext context) {
    final textos = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MIS PEDIDOS',
          style: TextStyle(
            color: AppColors.amber,
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        const Text('Mis pedidos', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(
          nombre.isEmpty
              ? 'Sigue aquí el estado de tus pedidos de hoy.'
              : 'Hola, $nombre. Sigue aquí el estado de tus pedidos de hoy.',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
      ],
    );

    final boton = FilledButton.icon(
      onPressed: alNuevo,
      icon: const Icon(Icons.add, size: 20),
      label: const Text('Hacer un pedido'),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.amber,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      ),
    );

    // En pantallas angostas el botón pasa debajo del título, a todo el ancho.
    return LayoutBuilder(
      builder: (context, c) => c.maxWidth < 620
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [textos, const SizedBox(height: 14), boton],
            )
          : Row(crossAxisAlignment: CrossAxisAlignment.end, children: [Expanded(child: textos), boton]),
    );
  }
}

class _SinPedidos extends StatelessWidget {
  const _SinPedidos();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.shopping_bag_outlined, size: 38, color: AppColors.textFaint),
            SizedBox(height: 10),
            Text('Todavía no has hecho pedidos hoy', style: TextStyle(color: AppColors.textMuted)),
          ],
        ),
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
            const Text('No se pudieron cargar tus pedidos'),
            const SizedBox(height: 12),
            FilledButton(onPressed: alReintentar, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}
