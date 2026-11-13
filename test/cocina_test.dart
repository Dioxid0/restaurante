import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/domain/entities/cocina.dart';
import 'package:restaurant_app/domain/entities/pedido.dart';
import 'package:restaurant_app/domain/entities/perfil.dart';

import 'helpers/app.dart';
import 'helpers/fakes.dart';
import 'helpers/fakes_cocina.dart';

/// Abre la app como [rol] y entra a la pestaña Cocina.
Future<({FakeCocinaRepository cocina, FakePedidoRepository pedidos})> _abrirCocina(
  WidgetTester tester, {
  List<PedidoCocina>? pedidos,
  List<AvisoCocina>? avisos,
  RolUsuario rol = RolUsuario.chef,
  Size ventana = const Size(1400, 1000),
}) async {
  final cocina = FakeCocinaRepository(pedidos: pedidos, avisos: avisos);
  final repoPedidos = FakePedidoRepository([]);
  await abrirApp(
    tester,
    auth: FakeAuthRepository(sesion: perfilDe(rol)),
    pedidos: repoPedidos,
    cocina: cocina,
    ventana: ventana,
  );
  await tester.tap(find.text('Cocina'));
  await tester.pumpAndSettle();
  return (cocina: cocina, pedidos: repoPedidos);
}

void main() {
  testWidgets('tablero: cada pedido va en su columna, con platillos y notas', (tester) async {
    await _abrirCocina(tester, pedidos: [
      pedidoCocinaDePrueba(folioDia: 1),
      pedidoCocinaDePrueba(folioDia: 2, estado: EstadoPedido.enPreparacion, mesa: 4),
      pedidoCocinaDePrueba(folioDia: 3, estado: EstadoPedido.listo, tipo: TipoPedido.paraLlevar),
      pedidoCocinaDePrueba(folioDia: 4),
    ]);

    expect(find.text('OPERACIÓN / COCINA'), findsOneWidget);
    expect(tester.widget<Text>(find.byKey(const Key('conteo_pendiente'))).data, '2');
    expect(tester.widget<Text>(find.byKey(const Key('conteo_en_preparacion'))).data, '1');
    expect(tester.widget<Text>(find.byKey(const Key('conteo_listo'))).data, '1');

    expect(find.text('#PED-001'), findsOneWidget);
    expect(find.text('M-04'), findsOneWidget);
    expect(find.text('Llevar'), findsOneWidget);
    expect(find.text('Enchiladas Verdes'), findsWidgets);
    expect(find.text('2×'), findsWidgets);
    expect(find.text('Nota: Sin cebolla'), findsWidgets);
    expect(find.text('Esperando al mesero'), findsOneWidget); // el listo solo se muestra
  });

  testWidgets('sin pedidos: cada columna dice que no hay nada', (tester) async {
    await _abrirCocina(tester);
    expect(find.text('No hay pedidos por preparar'), findsOneWidget);
    expect(find.text('No hay pedidos en preparación'), findsOneWidget);
    expect(find.text('No hay pedidos listos'), findsOneWidget);
  });

  testWidgets('pendiente → en preparación: pide confirmar y luego cambia el estado', (tester) async {
    final r = await _abrirCocina(tester, pedidos: [pedidoCocinaDePrueba(folioDia: 7)]);

    await tester.tap(find.text('Iniciar preparación'));
    await tester.pumpAndSettle();
    expect(find.text('¿Iniciar la preparación?'), findsOneWidget);
    expect(r.pedidos.cambiosEstado, isEmpty);

    await tester.tap(find.text('Iniciar'));
    await tester.pumpAndSettle();
    expect(r.pedidos.cambiosEstado, [(7, EstadoPedido.enPreparacion)]);
  });

  testWidgets('en preparación → listo', (tester) async {
    final r = await _abrirCocina(
      tester,
      pedidos: [pedidoCocinaDePrueba(folioDia: 9, estado: EstadoPedido.enPreparacion)],
    );
    await tester.tap(find.text('Marcar listo'));
    await tester.pumpAndSettle();
    expect(find.text('¿Marcar como Listo?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Listo'));
    await tester.pumpAndSettle();
    expect(r.pedidos.cambiosEstado, [(9, EstadoPedido.listo)]);
  });

  testWidgets('"Cancelar" en la burbuja no cambia nada', (tester) async {
    final r = await _abrirCocina(tester, pedidos: [pedidoCocinaDePrueba(folioDia: 1)]);
    await tester.tap(find.text('Iniciar preparación'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.text('¿Iniciar la preparación?'), findsNothing);
    expect(r.pedidos.cambiosEstado, isEmpty);
  });

  testWidgets('avisos de cocina: se listan y "Entendido" los marca como atendidos', (tester) async {
    final r = await _abrirCocina(tester, avisos: [
      avisoDePrueba(id: 1, folioDia: 5, tipo: TipoAviso.nuevo, mensaje: 'Pedido #5 nuevo'),
      avisoDePrueba(id: 2, folioDia: 6, tipo: TipoAviso.cancelado, mensaje: 'Pedido #6 cancelado'),
    ]);
    expect(find.text('Avisos de cocina (2)'), findsOneWidget);
    expect(find.text('Pedido #5 nuevo'), findsOneWidget);
    expect(find.text('Pedido #6 cancelado'), findsOneWidget);

    await tester.tap(find.text('Entendido').first);
    await tester.pumpAndSettle();
    expect(r.cocina.atendidos, [1]);
    expect(find.text('Pedido #5 nuevo'), findsNothing);
    expect(find.text('Avisos de cocina (1)'), findsOneWidget);
  });

  testWidgets('"Entendido todos" atiende todos los avisos y oculta el panel', (tester) async {
    final r = await _abrirCocina(tester, avisos: [
      avisoDePrueba(id: 1),
      avisoDePrueba(id: 2, folioDia: 2, tipo: TipoAviso.modificado),
    ]);
    await tester.tap(find.text('Entendido todos'));
    await tester.pumpAndSettle();
    expect(r.cocina.atendidosTodos, isTrue);
    expect(find.textContaining('Avisos de cocina'), findsNothing);
  });

  testWidgets('un aviso que llega en tiempo real muestra un aviso flotante', (tester) async {
    final r = await _abrirCocina(tester, avisos: [avisoDePrueba(id: 1, mensaje: 'Pedido #1 nuevo')]);
    // Lo que ya estaba al abrir no se anuncia con aviso flotante (solo está en el panel).
    expect(find.text('Pedido #1 nuevo'), findsOneWidget);

    r.cocina.avisos_ = [
      avisoDePrueba(id: 2, folioDia: 2, mensaje: 'Pedido #2 nuevo'),
      ...r.cocina.avisos_,
    ];
    r.cocina.emitirCambio();
    await tester.pumpAndSettle();
    // Una vez en el panel y otra en el aviso flotante.
    expect(find.text('Pedido #2 nuevo'), findsNWidgets(2));
    await tester.pump(const Duration(seconds: 6)); // deja terminar el temporizador del aviso
  });

  testWidgets('el gerente también ve y opera el tablero', (tester) async {
    final r = await _abrirCocina(
      tester,
      rol: RolUsuario.gerente,
      pedidos: [pedidoCocinaDePrueba(folioDia: 3)],
    );
    await tester.tap(find.text('Iniciar preparación'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Iniciar'));
    await tester.pumpAndSettle();
    expect(r.pedidos.cambiosEstado, [(3, EstadoPedido.enPreparacion)]);
  });

  testWidgets('pantalla angosta: las columnas se apilan sin desbordar', (tester) async {
    await _abrirCocina(
      tester,
      ventana: const Size(500, 1200),
      pedidos: [
        pedidoCocinaDePrueba(folioDia: 1),
        pedidoCocinaDePrueba(folioDia: 2, estado: EstadoPedido.enPreparacion),
      ],
    );
    expect(find.text('#PED-001'), findsOneWidget);
    expect(find.text('#PED-002'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el chef recibe el aviso flotante aunque esté en Inicio (no solo en Cocina)',
      (tester) async {
    final cocina = FakeCocinaRepository(avisos: [avisoDePrueba(id: 1, mensaje: 'Pedido #1 nuevo')]);
    await abrirApp(
      tester,
      auth: FakeAuthRepository(sesion: perfilDe(RolUsuario.chef)),
      pedidos: FakePedidoRepository([]),
      cocina: cocina,
      ventana: const Size(1400, 1000),
    );
    expect(find.text('Comandería y Mesas'), findsOneWidget); // sigue en Inicio
    expect(find.text('Pedido #2 nuevo'), findsNothing);

    cocina.avisos_ = [avisoDePrueba(id: 2, folioDia: 2, mensaje: 'Pedido #2 nuevo'), ...cocina.avisos_];
    cocina.emitirCambio();
    await tester.pumpAndSettle();
    expect(find.text('Pedido #2 nuevo'), findsOneWidget); // solo el aviso flotante
    await tester.pump(const Duration(seconds: 6));
  });

  testWidgets('el mesero y el gerente no reciben avisos flotantes de cocina', (tester) async {
    final cocina = FakeCocinaRepository(avisos: []);
    await abrirApp(
      tester,
      auth: FakeAuthRepository(sesion: perfilDe(RolUsuario.gerente)),
      pedidos: FakePedidoRepository([]),
      cocina: cocina,
      ventana: const Size(1400, 1000),
    );
    cocina.avisos_ = [avisoDePrueba(id: 2, folioDia: 2, mensaje: 'Pedido #2 nuevo')];
    cocina.emitirCambio();
    await tester.pumpAndSettle();
    expect(find.text('Pedido #2 nuevo'), findsNothing);
  });
}
