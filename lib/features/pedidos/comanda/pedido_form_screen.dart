import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/ui/toast.dart';
import '../../../domain/entities/mesa.dart';
import '../../../domain/entities/pedido.dart';
import '../../../domain/entities/pedido_detalle.dart';
import '../../../domain/entities/perfil.dart';
import '../../../domain/entities/platillo.dart';
import '../../../domain/errors.dart';
import '../../auth/auth_providers.dart';
import 'comanda_controller.dart';
import 'comanda_providers.dart';
import 'comanda_state.dart';
import '../widgets/dialogo_motivo.dart';
import 'widgets/barra_comanda.dart';
import 'widgets/panel_comanda.dart';
import 'widgets/platillo_card.dart';

/// Pantalla de comanda. Una sola vista para:
///  * crear un pedido (mesero / gerente),
///  * editar un pedido pendiente ([folio] != null),
///  * que el cliente pida en línea (siempre para llevar y sin mesa).
class PedidoFormScreen extends ConsumerWidget {
  const PedidoFormScreen({super.key, this.folio});

  /// null => crear; con valor => editar ese pedido.
  final int? folio;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perfil = ref.watch(perfilActualProvider);
    return perfil.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => const Scaffold(body: Center(child: Text('No se pudo cargar tu perfil'))),
      data: (p) => p == null
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : _Formulario(perfil: p, folio: folio),
    );
  }
}

class _Formulario extends ConsumerStatefulWidget {
  const _Formulario({required this.perfil, required this.folio});
  final Perfil perfil;
  final int? folio;

  @override
  ConsumerState<_Formulario> createState() => _FormularioState();
}

class _FormularioState extends ConsumerState<_Formulario> {
  CategoriaPlatillo? _categoria; // null = Todas
  bool _cargando = false;
  Object? _errorDeCarga;
  PedidoDetalle? _detalle;

  bool get _esCliente => widget.perfil.rol == RolUsuario.cliente;
  bool get _editando => widget.folio != null;
  ComandaController get _controlador =>
      ref.read(comandaControllerProvider(esCliente: _esCliente).notifier);

  @override
  void initState() {
    super.initState();
    if (_editando) {
      _cargando = true;
      _cargarPedido();
    }
  }

  Future<void> _cargarPedido() async {
    try {
      final detalle = await ref.read(detallePedidoProvider(widget.folio!).future);
      if (!mounted) return;
      _controlador.cargar(detalle);
      setState(() {
        _detalle = detalle;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorDeCarga = e;
        _cargando = false;
      });
    }
  }

  void _irAlDashboard() => context.go('/inicio');

  Future<bool> _confirmar(String titulo, String texto, String accion) async {
    final r = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(titulo),
        content: Text(texto),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Seguir editando')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.amber),
            child: Text(accion),
          ),
        ],
      ),
    );
    return r ?? false;
  }

  Future<void> _volver(ComandaState estado) async {
    if (estado.modificado) {
      final salir = await _confirmar(
        '¿Descartar los cambios?',
        'Hay platillos o cambios sin enviar. Si sales, se perderán.',
        'Descartar',
      );
      if (!salir) return;
    }
    if (mounted) _irAlDashboard();
  }

  Future<void> _vaciar(ComandaState estado) async {
    if (_editando) return _volver(estado); // "Descartar Cambios"
    if (estado.lineas.isEmpty) return;
    final ok = await _confirmar(
      '¿Vaciar la comanda?',
      'Se quitarán todos los platillos agregados.',
      'Vaciar',
    );
    if (ok) _controlador.vaciar();
  }

  Future<void> _enviar() async {
    try {
      await _controlador.enviar(folio: widget.folio);
      if (!mounted) return;
      mostrarToast(
        context,
        _editando
            ? '¡Cambios guardados y enviados a cocina!'
            : (_esCliente ? '¡Pedido enviado con éxito!' : '¡Comanda enviada a cocina con éxito!'),
      );
      _irAlDashboard();
    } catch (e) {
      if (!mounted) return;
      mostrarToast(context, 'Error: ${mensajeDeError(e)}', tipo: TipoToast.error);
    }
  }

  Future<void> _cancelarPedido() async {
    final motivo = await showDialog<String>(
      context: context,
      builder: (_) => DialogoMotivo(folio: _detalleFolio()),
    );
    if (motivo == null || !mounted) return;
    try {
      await _controlador.cancelarPedido(widget.folio!, motivo);
      if (!mounted) return;
      mostrarToast(context, 'Pedido cancelado');
      _irAlDashboard();
    } catch (e) {
      if (mounted) mostrarToast(context, 'Error: ${mensajeDeError(e)}', tipo: TipoToast.error);
    }
  }

  String _detalleFolio() {
    final d = _detalle;
    return d == null ? '' : '#PED-${d.folioDia.toString().padLeft(3, '0')}';
  }

  String _subtitulo(ComandaState e, List<Mesa> mesas) {
    if (_esCliente) return 'Pedido para llevar';
    final tipo = e.tipo == TipoPedido.enMesa ? 'Presencial' : 'Para llevar';
    final String mesa;
    if (e.tipo == TipoPedido.paraLlevar && e.sinMesa) {
      mesa = 'Sin mesa';
    } else if (e.idMesa == null) {
      mesa = 'Mesa no seleccionada';
    } else {
      mesa = mesas.where((m) => m.idMesa == e.idMesa).map((m) => m.etiqueta).firstOrNull ?? 'Mesa';
    }
    return '$mesa · $tipo';
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(comandaControllerProvider(esCliente: _esCliente));

    if (_cargando) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_errorDeCarga != null) {
      return _Bloqueado(
        mensaje: mensajeDeError(_errorDeCarga!, porDefecto: 'No se pudo cargar el pedido'),
        alVolver: _irAlDashboard,
      );
    }
    final d = _detalle;
    if (d != null && (!d.estado.esActivo || (d.estado != EstadoPedido.pendiente && widget.perfil.rol != RolUsuario.gerente))) {
      return _Bloqueado(
        mensaje: 'El pedido ${_detalleFolio()} está "${d.estado.etiqueta}" y ya no puede editarse desde aquí.',
        alVolver: _irAlDashboard,
      );
    }

    final menu = ref.watch(menuProvider);
    final mesasAsync = _esCliente ? const AsyncData<List<Mesa>>([]) : ref.watch(mesasProvider);
    final mesas = mesasAsync.value ?? const <Mesa>[];
    final notificador = _controlador;

    final panel = PanelComanda(
      estado: estado,
      subtitulo: _subtitulo(estado, mesas),
      textoEnviar: _editando
          ? 'Guardar Cambios y Notificar a Cocina'
          : (_esCliente ? 'Enviar Pedido' : 'Enviar Comanda a Cocina'),
      textoSecundario: _editando ? 'Descartar Cambios' : 'Cancelar / Vaciar',
      alIncrementar: notificador.incrementar,
      alDecrementar: notificador.decrementar,
      alCambiarNota: notificador.cambiarNota,
      alEnviar: _enviar,
      alVaciar: () => _vaciar(estado),
      alCancelarPedido: _editando ? _cancelarPedido : null,
    );

    final contenidoMenu = _MenuPlatillos(
      menu: menu,
      categoria: _categoria,
      alElegirCategoria: (c) => setState(() => _categoria = c),
      alAgregar: notificador.agregar,
      alReintentar: () => ref.invalidate(menuProvider),
    );

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: Column(
        children: [
          BarraComanda(
            mostrarOpciones: !_esCliente,
            mesas: mesas,
            idMesa: estado.idMesa,
            tipo: estado.tipo,
            sinMesa: estado.sinMesa,
            alVolver: () => _volver(estado),
            alCambiarMesa: notificador.setMesa,
            alCambiarTipo: notificador.setTipo,
            alCambiarSinMesa: notificador.setSinMesa,
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, c) {
                if (c.maxWidth >= 900) {
                  return Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
                          child: contenidoMenu,
                        ),
                      ),
                      SizedBox(width: 360, child: panel),
                    ],
                  );
                }
                // Ventana angosta: menú arriba y comanda debajo.
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(padding: const EdgeInsets.all(20), child: contenidoMenu),
                      SizedBox(height: 640, child: panel),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuPlatillos extends StatelessWidget {
  const _MenuPlatillos({
    required this.menu,
    required this.categoria,
    required this.alElegirCategoria,
    required this.alAgregar,
    required this.alReintentar,
  });

  final AsyncValue<List<Platillo>> menu;
  final CategoriaPlatillo? categoria;
  final ValueChanged<CategoriaPlatillo?> alElegirCategoria;
  final void Function(Platillo, String) alAgregar;
  final VoidCallback alReintentar;

  @override
  Widget build(BuildContext context) {
    final todos = menu.value ?? const <Platillo>[];
    final visibles = todos.where((p) => categoria == null || p.categoria == categoria).toList();
    final disponibles = visibles.where((p) => p.disponible).length;

    return Column(
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
                    'MENÚ DEL DÍA',
                    style: TextStyle(
                      color: AppColors.amber,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text('Selecciona los platillos', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Text(
              '$disponibles opciones disponibles',
              style: const TextStyle(color: AppColors.textFaint, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _ChipCategoria(texto: 'Todas', activa: categoria == null, alTocar: () => alElegirCategoria(null)),
            for (final c in CategoriaPlatillo.values)
              _ChipCategoria(
                texto: c.valorBd,
                icono: iconoDeCategoria(c),
                activa: categoria == c,
                alTocar: () => alElegirCategoria(c),
              ),
          ],
        ),
        const SizedBox(height: 18),
        if (menu.hasError && !menu.hasValue)
          Padding(
            padding: const EdgeInsets.all(40),
            child: Center(
              child: Column(
                children: [
                  const Text('No se pudo cargar el menú'),
                  const SizedBox(height: 10),
                  FilledButton(onPressed: alReintentar, child: const Text('Reintentar')),
                ],
              ),
            ),
          )
        else if (!menu.hasValue)
          const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))
        else if (visibles.isEmpty)
          const Padding(
            padding: EdgeInsets.all(40),
            child: Center(
              child: Text('No hay platillos en esta categoría', style: TextStyle(color: AppColors.textMuted)),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: visibles.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 330,
              mainAxisExtent: 345,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemBuilder: (_, i) => PlatilloCard(
              key: ValueKey(visibles[i].idPlatillo),
              platillo: visibles[i],
              alAgregar: alAgregar,
            ),
          ),
      ],
    );
  }
}

class _ChipCategoria extends StatelessWidget {
  const _ChipCategoria({required this.texto, required this.activa, required this.alTocar, this.icono});

  final String texto;
  final bool activa;
  final VoidCallback alTocar;
  final IconData? icono;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: alTocar,
      borderRadius: BorderRadius.circular(11),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: activa ? AppColors.amber : Colors.white,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: activa ? AppColors.amber : AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icono != null) ...[
              Icon(icono, size: 15, color: activa ? Colors.white : AppColors.textMuted),
              const SizedBox(width: 6),
            ],
            Text(
              texto,
              style: TextStyle(
                color: activa ? Colors.white : AppColors.text,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bloqueado extends StatelessWidget {
  const _Bloqueado({required this.mensaje, required this.alVolver});
  final String mensaje;
  final VoidCallback alVolver;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 40, color: AppColors.textFaint),
              const SizedBox(height: 14),
              Text(mensaje, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: alVolver,
                style: FilledButton.styleFrom(backgroundColor: AppColors.amber),
                child: const Text('Volver al Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
