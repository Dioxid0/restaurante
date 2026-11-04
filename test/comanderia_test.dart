import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/data/repository_providers.dart';
import 'package:restaurant_app/domain/entities/pedido.dart';
import 'package:restaurant_app/features/pedidos/pedidos_providers.dart';
import 'package:restaurant_app/main.dart';

import 'helpers/fakes.dart';

Future<FakePedidoRepository> _abrir(WidgetTester tester, List<PedidoResumen> datos) async {
  tester.view.physicalSize = const Size(1500, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);

  final pedidos = FakePedidoRepository(datos);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(FakeAuthRepository(conSesion: true)),
      pedidoRepositoryProvider.overrideWithValue(pedidos),
      relojProvider.overrideWith((ref) => Stream.value(DateTime.now())),
    ],
    child: const RestaurantApp(),
  ));
  await tester.pumpAndSettle();
  return pedidos;
}

void main() {
  testWidgets('"Activos" oculta completados y cancelados; "Todos" los muestra', (tester) async {
    await _abrir(tester, [
      pedidoDePrueba(folioDia: 1),
      pedidoDePrueba(folioDia: 2, estado: EstadoPedido.completado),
      pedidoDePrueba(folioDia: 3, estado: EstadoPedido.cancelado),
    ]);
    expect(find.text('#PED-001'), findsOneWidget);
    expect(find.text('#PED-002'), findsNothing);
    expect(find.text('#PED-003'), findsNothing);

    await tester.tap(find.text('Activos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Todos').last);
    await tester.pumpAndSettle();
    expect(find.text('#PED-002'), findsOneWidget);
    expect(find.text('#PED-003'), findsOneWidget);
  });

  testWidgets('la búsqueda filtra por folio, mesa o empleado', (tester) async {
    await _abrir(tester, [
      pedidoDePrueba(folioDia: 1, mesero: 'Juan Pérez', mesa: 1),
      pedidoDePrueba(folioDia: 2, mesero: 'Ana López', mesa: 3),
    ]);
    await tester.enterText(find.byType(TextField), 'ana');
    await tester.pumpAndSettle();
    expect(find.text('#PED-001'), findsNothing);
    expect(find.text('#PED-002'), findsOneWidget);
    expect(find.text('1 pedidos encontrados'), findsOneWidget);
  });

  testWidgets('pagina de 5 en 5', (tester) async {
    await _abrir(tester, [for (var i = 1; i <= 7; i++) pedidoDePrueba(folioDia: i)]);
    expect(find.text('Mostrando 5 de 7 pedidos'), findsOneWidget);
    await tester.tap(find.text('2'));
    await tester.pumpAndSettle();
    expect(find.text('Mostrando 2 de 7 pedidos'), findsOneWidget);
  });

  testWidgets('listo → entregado y entregado → completado llaman al repositorio', (tester) async {
    final repo = await _abrir(tester, [
      pedidoDePrueba(folioDia: 1, estado: EstadoPedido.listo),
      pedidoDePrueba(folioDia: 2, estado: EstadoPedido.entregado),
    ]);
    await tester.tap(find.byTooltip('Marcar como entregado'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Marcar como completado'));
    await tester.pumpAndSettle();
    expect(repo.cambiosEstado, [
      (1, EstadoPedido.entregado),
      (2, EstadoPedido.completado),
    ]);
  });

  testWidgets('"Editar" solo aparece en pedidos pendientes (RN-03)', (tester) async {
    await _abrir(tester, [
      pedidoDePrueba(folioDia: 1, estado: EstadoPedido.pendiente),
      pedidoDePrueba(folioDia: 2, estado: EstadoPedido.enPreparacion),
    ]);
    expect(find.text('Editar'), findsOneWidget);
  });
}
