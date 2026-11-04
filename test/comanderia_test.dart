import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/domain/entities/pedido.dart';
import 'package:restaurant_app/domain/entities/pedido_detalle.dart';
import 'package:restaurant_app/domain/entities/perfil.dart';

import 'helpers/app.dart';
import 'helpers/fakes.dart';

Future<FakePedidoRepository> _abrir(WidgetTester tester, List<PedidoResumen> datos) async {
  final pedidos = FakePedidoRepository(datos);
  await abrirApp(
    tester,
    auth: FakeAuthRepository(sesion: perfilDe(RolUsuario.mesero)),
    pedidos: pedidos,
    ventana: const Size(1500, 1000),
  );
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
    // Cada check abre una burbuja pequeña; el cambio solo ocurre al confirmar.
    await tester.tap(find.byTooltip('Marcar como entregado'));
    await tester.pumpAndSettle();
    expect(find.text('¿Marcar como Entregado?'), findsOneWidget);
    expect(repo.cambiosEstado, isEmpty);
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Marcar como completado'));
    await tester.pumpAndSettle();
    expect(find.text('¿Marcar como Completado?'), findsOneWidget);
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(repo.cambiosEstado, [
      (1, EstadoPedido.entregado),
      (2, EstadoPedido.completado),
    ]);
  });

  testWidgets('"Cancelar" en la burbuja no cambia el estado', (tester) async {
    final repo = await _abrir(tester, [pedidoDePrueba(folioDia: 1, estado: EstadoPedido.listo)]);
    await tester.tap(find.byTooltip('Marcar como entregado'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.text('¿Marcar como Entregado?'), findsNothing);
    expect(repo.cambiosEstado, isEmpty);
  });

  testWidgets('"Ver detalle" abre el modal con renglones, notas y desglose de IVA', (tester) async {
    final repo = FakePedidoRepository([pedidoDePrueba(folioDia: 108)])
      ..detalleParaEditar = const PedidoDetalle(
        folio: 1,
        folioDia: 108,
        tipo: TipoPedido.enMesa,
        estado: EstadoPedido.pendiente,
        idMesa: 11,
        numeroMesa: 1,
        nombreMesero: 'Juan Pérez',
        total: 313,
        lineas: [
          LineaPedido(idPlatillo: 2, nombre: 'Enchiladas Verdes', precioUnitario: 165, cantidad: 1, nota: 'Sin cebolla'),
          LineaPedido(idPlatillo: 5, nombre: 'Tacos de Arrachera', precioUnitario: 148, cantidad: 1, nota: 'Extra salsa'),
        ],
      );
    await abrirApp(
      tester,
      auth: FakeAuthRepository(sesion: perfilDe(RolUsuario.mesero)),
      pedidos: repo,
      ventana: const Size(1500, 1000),
    );

    await tester.tap(find.byTooltip('Ver detalle'));
    await tester.pumpAndSettle();

    expect(find.text('Detalle de Comanda - #PED-108'), findsOneWidget);
    expect(find.text('M-01'), findsWidgets);
    expect(find.text('Presencial'), findsOneWidget);
    expect(find.text('Enchiladas Verdes'), findsOneWidget);
    expect(find.text('Nota: Sin cebolla'), findsOneWidget);
    expect(find.text('Nota: Extra salsa'), findsOneWidget);
    expect(find.text(r'$269.83'), findsOneWidget); // subtotal sin IVA
    expect(find.text(r'$43.17'), findsOneWidget); // IVA 16 %
    expect(tester.widget<Text>(find.byKey(const Key('total_detalle'))).data, r'$313.00');

    await tester.tap(find.text('Cerrar'));
    await tester.pumpAndSettle();
    expect(find.text('Detalle de Comanda - #PED-108'), findsNothing);
  });

  testWidgets('el detalle de un pedido para llevar muestra mesa "—" y tipo "Para Llevar"', (tester) async {
    final repo = FakePedidoRepository([pedidoDePrueba(folioDia: 106, tipo: TipoPedido.paraLlevar)])
      ..detalleParaEditar = const PedidoDetalle(
        folio: 1,
        folioDia: 106,
        tipo: TipoPedido.paraLlevar,
        estado: EstadoPedido.enPreparacion,
        nombreMesero: 'Juan Pérez',
        total: 296,
        lineas: [LineaPedido(idPlatillo: 5, nombre: 'Tacos de Arrachera', precioUnitario: 148, cantidad: 2, nota: 'Uno sin cebolla')],
      );
    await abrirApp(
      tester,
      auth: FakeAuthRepository(sesion: perfilDe(RolUsuario.mesero)),
      pedidos: repo,
      ventana: const Size(1500, 1000),
    );
    await tester.tap(find.byTooltip('Ver detalle'));
    await tester.pumpAndSettle();
    expect(find.text('Para Llevar'), findsOneWidget);
    expect(find.text(r'$255.17'), findsOneWidget);
    expect(find.text(r'$40.83'), findsOneWidget);
    expect(find.text('2'), findsWidgets); // cantidad
  });

  testWidgets('"Editar" solo aparece en pedidos pendientes (RN-03)', (tester) async {
    await _abrir(tester, [
      pedidoDePrueba(folioDia: 1, estado: EstadoPedido.pendiente),
      pedidoDePrueba(folioDia: 2, estado: EstadoPedido.enPreparacion),
    ]);
    expect(find.text('Editar'), findsOneWidget);
  });
}
