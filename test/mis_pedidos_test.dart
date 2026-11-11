import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/domain/entities/pedido.dart';
import 'package:restaurant_app/domain/entities/perfil.dart';

import 'helpers/app.dart';
import 'helpers/fakes.dart';

/// Abre la app con la sesión de un cliente (su inicio es "Mis pedidos").
Future<void> _abrirCliente(
  WidgetTester tester,
  List<PedidoResumen> datos, {
  Size ventana = const Size(1400, 900),
}) async {
  await abrirApp(
    tester,
    auth: FakeAuthRepository(sesion: perfilDe(RolUsuario.cliente)),
    pedidos: FakePedidoRepository(datos),
    ventana: ventana,
  );
}

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

  testWidgets('cliente: la tabla solo trae FOLIO, HORA, ESTADO y TOTAL', (tester) async {
    await _abrirCliente(tester, [pedidoDePrueba(folioDia: 1)]);
    for (final columna in ['FOLIO', 'HORA', 'ESTADO', 'TOTAL']) {
      expect(find.text(columna), findsOneWidget);
    }
    expect(find.text('MESA / TIPO'), findsNothing);
    expect(find.text('ACCIONES'), findsNothing);
  });

  testWidgets('cliente: sin filtros ni buscador, sin mesa, sin mesero y sin acciones', (tester) async {
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
    expect(find.text('Editar'), findsNothing);
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
      [pedidoDePrueba(folioDia: 4, estado: EstadoPedido.listo, total: 331, mesa: 2)],
      ventana: const Size(500, 900),
    );
    expect(find.text('#PED-004'), findsOneWidget);
    expect(find.text('Listo'), findsOneWidget);
    expect(find.text(r'$331.00'), findsOneWidget);
    expect(find.textContaining('M-02'), findsNothing);
    expect(find.text('Editar'), findsNothing);
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
