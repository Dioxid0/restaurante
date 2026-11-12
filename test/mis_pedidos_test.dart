import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:restaurant_app/domain/entities/pedido.dart';
import 'package:restaurant_app/domain/entities/pedido_detalle.dart';
import 'package:restaurant_app/domain/entities/perfil.dart';

import 'helpers/app.dart';
import 'helpers/fakes.dart';

/// Abre la app con la sesión de un cliente (su inicio es "Mis pedidos").
Future<FakePedidoRepository> _abrirCliente(
  WidgetTester tester,
  List<PedidoResumen> datos, {
  Size ventana = const Size(1400, 900),
  PedidoDetalle? detalle,
}) async {
  final repo = FakePedidoRepository(datos)..detalleParaEditar = detalle;
  await abrirApp(
    tester,
    auth: FakeAuthRepository(sesion: perfilDe(RolUsuario.cliente)),
    pedidos: repo,
    ventana: ventana,
  );
  return repo;
}

/// Deja pasar el aviso flotante (dura 4 s) para que su temporizador termine.
Future<void> _dejarPasarAvisos(WidgetTester tester) => tester.pump(const Duration(seconds: 6));

void main() {
  testWidgets('cliente: ve "Mis pedidos" con folio, hora, estado y total', (tester) async {
    await _abrirCliente(tester, [
      pedidoDePrueba(folioDia: 7, estado: EstadoPedido.enPreparacion, total: 405),
    ]);
    expect(find.text('Mis pedidos'), findsOneWidget);
    expect(find.textContaining('Hola,'), findsOneWidget);
    expect(find.text('#PED-007'), findsOneWidget);
    expect(find.text('En Preparación'), findsOneWidget);
    expect(find.text(r'$405.00'), findsOneWidget);
    expect(find.text('1 pedido'), findsOneWidget);
  });

  testWidgets('cliente: la tabla trae FOLIO, HORA, ESTADO, TOTAL y ACCIONES (sin MESA / TIPO)',
      (tester) async {
    await _abrirCliente(tester, [pedidoDePrueba(folioDia: 1)]);
    for (final columna in ['FOLIO', 'HORA', 'ESTADO', 'TOTAL', 'ACCIONES']) {
      expect(find.text(columna), findsOneWidget);
    }
    expect(find.text('MESA / TIPO'), findsNothing);
  });

  testWidgets('cliente: sin filtros ni buscador, sin mesa, sin mesero y sin ojo ni entregar',
      (tester) async {
    await _abrirCliente(tester, [
      pedidoDePrueba(folioDia: 1, mesa: 3, mesero: 'Luis Mesero'),
      pedidoDePrueba(folioDia: 2, estado: EstadoPedido.listo),
      pedidoDePrueba(folioDia: 3, estado: EstadoPedido.entregado),
    ]);
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Estado'), findsNothing);
    expect(find.text('Activos'), findsNothing);
    expect(find.textContaining('M-03'), findsNothing);
    expect(find.text('Luis Mesero'), findsNothing);
    expect(find.byTooltip('Ver detalle'), findsNothing);
    expect(find.byTooltip('Marcar como entregado'), findsNothing);
    expect(find.byTooltip('Marcar como completado'), findsNothing);
  });

  testWidgets('cliente: ve todos sus pedidos del día, también los completados y cancelados',
      (tester) async {
    await _abrirCliente(tester, [
      pedidoDePrueba(folioDia: 1),
      pedidoDePrueba(folioDia: 2, estado: EstadoPedido.completado),
      pedidoDePrueba(folioDia: 3, estado: EstadoPedido.cancelado),
    ]);
    expect(find.text('#PED-001'), findsOneWidget);
    expect(find.text('#PED-002'), findsOneWidget);
    expect(find.text('#PED-003'), findsOneWidget);
    expect(find.text('3 pedidos'), findsOneWidget);
  });

  testWidgets('cliente: "Editar" solo aparece en los pedidos pendientes (RN-03)', (tester) async {
    await _abrirCliente(tester, [
      pedidoDePrueba(folioDia: 1),
      pedidoDePrueba(folioDia: 2, estado: EstadoPedido.enPreparacion),
      pedidoDePrueba(folioDia: 3, estado: EstadoPedido.listo),
      pedidoDePrueba(folioDia: 4, estado: EstadoPedido.entregado),
      pedidoDePrueba(folioDia: 5, estado: EstadoPedido.cancelado),
    ]);
    expect(find.text('Editar'), findsOneWidget);
  });

  testWidgets('cliente: "Editar" abre la comanda con su pedido y guarda los cambios', (tester) async {
    final repo = await _abrirCliente(
      tester,
      [pedidoDePrueba(folioDia: 108, total: 378)],
      ventana: const Size(1500, 1000),
      detalle: const PedidoDetalle(
        folio: 108,
        folioDia: 108,
        tipo: TipoPedido.paraLlevar,
        estado: EstadoPedido.pendiente,
        esEnLinea: true,
        lineas: [
          LineaPedido(idPlatillo: 2, nombre: 'Enchiladas Verdes', precioUnitario: 165, cantidad: 2),
          LineaPedido(idPlatillo: 1, nombre: 'Agua de Jamaica', precioUnitario: 48, cantidad: 1),
        ],
      ),
    );
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();

    expect(find.text('Guardar Cambios y Notificar a Cocina'), findsOneWidget);
    expect(find.text('Pedido para llevar'), findsOneWidget);
    expect(find.text('Cancelar Pedido'), findsOneWidget);

    await tester.tap(find.byTooltip('Agregar uno').first); // una enchilada más
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar Cambios y Notificar a Cocina'));
    await tester.pumpAndSettle();

    final a = repo.actualizados.single;
    expect(a.folio, 108);
    expect(a.tipo, TipoPedido.paraLlevar);
    expect(a.idMesa, isNull);
    expect(a.items.map((i) => (i.idPlatillo, i.cantidad)), [(2, 3), (1, 1)]);
    expect(find.text('Mis pedidos'), findsOneWidget); // regresa a su inicio
    await _dejarPasarAvisos(tester);
  });

  testWidgets('cliente: si el pedido ya no está pendiente, la comanda no deja editarlo', (tester) async {
    await _abrirCliente(
      tester,
      [pedidoDePrueba(folioDia: 108, estado: EstadoPedido.enPreparacion)],
      ventana: const Size(1500, 1000),
      detalle: const PedidoDetalle(
        folio: 108,
        folioDia: 108,
        tipo: TipoPedido.paraLlevar,
        estado: EstadoPedido.enPreparacion,
        esEnLinea: true,
        lineas: [LineaPedido(idPlatillo: 1, nombre: 'Agua de Jamaica', precioUnitario: 48, cantidad: 1)],
      ),
    );
    GoRouter.of(tester.element(find.text('Mis pedidos'))).go('/pedido/108/editar');
    await tester.pumpAndSettle();
    expect(find.textContaining('ya no puede editarse'), findsOneWidget);
    expect(find.text('Guardar Cambios y Notificar a Cocina'), findsNothing);
  });

  testWidgets('cliente: pagina de 5 en 5', (tester) async {
    await _abrirCliente(tester, [for (var i = 1; i <= 7; i++) pedidoDePrueba(folioDia: i)]);
    expect(find.text('#PED-005'), findsOneWidget);
    expect(find.text('#PED-006'), findsNothing);
    expect(find.text('Mostrando 5 de 7 pedidos'), findsOneWidget);
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    expect(find.text('#PED-006'), findsOneWidget);
    expect(find.text('#PED-001'), findsNothing);
  });

  testWidgets('cliente sin pedidos: muestra un mensaje', (tester) async {
    await _abrirCliente(tester, []);
    expect(find.text('Todavía no has hecho pedidos hoy'), findsOneWidget);
    expect(find.text('0 pedidos'), findsOneWidget);
  });

  testWidgets('cliente: el botón "Hacer un pedido" abre la comanda en línea', (tester) async {
    await _abrirCliente(tester, [], ventana: const Size(1500, 1000));
    await tester.tap(find.text('Hacer un pedido'));
    await tester.pumpAndSettle();
    expect(find.text('Mis pedidos'), findsNothing);
    expect(find.text('Agregar al Pedido'), findsWidgets);
  });

  testWidgets('cliente en ventana angosta: tarjetas con folio, estado, hora y total', (tester) async {
    await _abrirCliente(
      tester,
      [
        pedidoDePrueba(folioDia: 4, estado: EstadoPedido.listo, total: 331, mesa: 2),
        pedidoDePrueba(folioDia: 5),
      ],
      ventana: const Size(500, 900),
    );
    expect(find.text('#PED-004'), findsOneWidget);
    expect(find.text('Listo'), findsOneWidget);
    expect(find.text(r'$331.00'), findsOneWidget);
    expect(find.textContaining('M-02'), findsNothing);
    expect(find.text('Editar'), findsOneWidget); // solo el pendiente
  });

  testWidgets('el mesero sigue viendo la Comandería completa (no cambia)', (tester) async {
    await abrirApp(
      tester,
      auth: FakeAuthRepository(sesion: perfilDe(RolUsuario.mesero)),
      pedidos: FakePedidoRepository([pedidoDePrueba(folioDia: 1)]),
      ventana: const Size(1500, 1000),
    );
    expect(find.text('Comandería y Mesas'), findsOneWidget);
    expect(find.text('MESA / TIPO'), findsOneWidget);
    expect(find.text('ACCIONES'), findsOneWidget);
    expect(find.text('Mis pedidos'), findsNothing);
  });
}
