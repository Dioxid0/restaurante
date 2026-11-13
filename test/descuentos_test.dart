import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/domain/entities/pedido.dart';
import 'package:restaurant_app/domain/entities/pedido_detalle.dart';
import 'package:restaurant_app/domain/entities/perfil.dart';

import 'helpers/app.dart';
import 'helpers/fakes.dart';

PedidoDetalle _detalle({
  EstadoPedido estado = EstadoPedido.listo,
  double total = 313,
  double descuento = 0,
  bool esCortesia = false,
  String? motivo,
}) =>
    PedidoDetalle(
      folio: 108,
      folioDia: 108,
      tipo: TipoPedido.enMesa,
      estado: estado,
      idMesa: 11,
      numeroMesa: 1,
      nombreMesero: 'Juan Pérez',
      total: total,
      descuento: descuento,
      esCortesia: esCortesia,
      motivoDescuento: motivo,
      lineas: const [
        LineaPedido(idPlatillo: 2, nombre: 'Enchiladas Verdes', precioUnitario: 165, cantidad: 1),
        LineaPedido(idPlatillo: 5, nombre: 'Tacos de Arrachera', precioUnitario: 148, cantidad: 1),
      ],
    );

/// Abre la app como [rol] y entra al "Ver detalle" del pedido #PED-108.
Future<FakePedidoRepository> _abrirDetalle(
  WidgetTester tester, {
  RolUsuario rol = RolUsuario.gerente,
  PedidoDetalle? detalle,
}) async {
  final d = detalle ?? _detalle();
  final repo = FakePedidoRepository([pedidoDePrueba(folioDia: 108, estado: d.estado, total: d.total)])
    ..detalleParaEditar = d;
  await abrirApp(
    tester,
    auth: FakeAuthRepository(sesion: perfilDe(rol)),
    pedidos: repo,
    ventana: const Size(1500, 1000),
  );
  await tester.tap(find.byTooltip('Ver detalle'));
  await tester.pumpAndSettle();
  return repo;
}

Future<void> _dejarPasarAvisos(WidgetTester tester) => tester.pump(const Duration(seconds: 6));

String _total(WidgetTester tester) => tester.widget<Text>(find.byKey(const Key('total_detalle'))).data!;

void main() {
  group('quién ve el botón', () {
    testWidgets('el gerente sí', (tester) async {
      await _abrirDetalle(tester);
      expect(find.text('Aplicar descuento o cortesía'), findsOneWidget);
    });

    testWidgets('el mesero no', (tester) async {
      await _abrirDetalle(tester, rol: RolUsuario.mesero);
      expect(find.text('Detalle de Comanda - #PED-108'), findsOneWidget);
      expect(find.text('Aplicar descuento o cortesía'), findsNothing);
    });

    testWidgets('un pedido cancelado no admite descuento', (tester) async {
      // En "Activos" no aparece; se muestra con el filtro de cancelados desde el detalle directo.
      final repo = FakePedidoRepository([pedidoDePrueba(folioDia: 108)])
        ..detalleParaEditar = _detalle(estado: EstadoPedido.cancelado);
      await abrirApp(
        tester,
        auth: FakeAuthRepository(sesion: perfilDe(RolUsuario.gerente)),
        pedidos: repo,
        ventana: const Size(1500, 1000),
      );
      await tester.tap(find.byTooltip('Ver detalle'));
      await tester.pumpAndSettle();
      expect(find.text('Aplicar descuento o cortesía'), findsNothing);
    });
  });

  group('gerente', () {
    testWidgets('aplica un descuento con motivo y el detalle se actualiza', (tester) async {
      final repo = await _abrirDetalle(tester);
      expect(_total(tester), r'$313.00');

      await tester.tap(find.text('Aplicar descuento o cortesía'));
      await tester.pumpAndSettle();
      final aplicar = find.widgetWithText(FilledButton, 'Aplicar descuento');
      expect(tester.widget<FilledButton>(aplicar).onPressed, isNull); // sin valor ni motivo

      await tester.tap(find.text('Monto'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'Monto del descuento'), '50');
      await tester.enterText(find.widgetWithText(TextField, 'Motivo'), 'Queja por la demora');
      await tester.pumpAndSettle();
      await tester.tap(aplicar);
      await tester.pumpAndSettle();

      expect(repo.descuentos.single, (folio: 108, monto: 50.0, esCortesia: false, motivo: 'Queja por la demora'));
      expect(_total(tester), r'$263.00');
      expect(find.text('Descuento'), findsOneWidget);
      expect(find.text(r'-$50.00'), findsOneWidget);
      expect(find.text('Motivo: Queja por la demora'), findsOneWidget);
      // Subtotal e IVA siguen siendo los del pedido completo.
      expect(find.text(r'$269.83'), findsOneWidget);
      expect(find.text('Cambiar descuento o cortesía'), findsOneWidget);
      await _dejarPasarAvisos(tester);
    });

    testWidgets('por defecto es porcentaje: 10 % calcula el importe y el total final', (tester) async {
      final repo = await _abrirDetalle(tester);
      await tester.tap(find.text('Aplicar descuento o cortesía'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextField, 'Porcentaje de descuento'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextField, 'Porcentaje de descuento'), '10');
      await tester.enterText(find.widgetWithText(TextField, 'Motivo'), 'Cliente frecuente');
      await tester.pumpAndSettle();
      // Vista previa: 10 % de $313.00 = $31.30 y queda en $281.70.
      expect(find.textContaining(r'Se descuentan $31.30'), findsOneWidget);
      expect(find.textContaining(r'Total final: $281.70'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Aplicar descuento'));
      await tester.pumpAndSettle();
      expect(repo.descuentos.single, (folio: 108, monto: 31.3, esCortesia: false, motivo: 'Cliente frecuente'));
      expect(_total(tester), r'$281.70');
      await _dejarPasarAvisos(tester);
    });

    testWidgets('los atajos (10, 15, 20, 25, 50 %) llenan el porcentaje', (tester) async {
      final repo = await _abrirDetalle(tester);
      await tester.tap(find.text('Aplicar descuento o cortesía'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('20 %'));
      await tester.pumpAndSettle();
      expect(find.textContaining(r'Se descuentan $62.60'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextField, 'Motivo'), 'Promoción');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Aplicar descuento'));
      await tester.pumpAndSettle();
      expect(repo.descuentos.single.monto, 62.6);
      expect(_total(tester), r'$250.40');
      await _dejarPasarAvisos(tester);
    });

    testWidgets('el porcentaje no puede pasar de 100', (tester) async {
      await _abrirDetalle(tester);
      await tester.tap(find.text('Aplicar descuento o cortesía'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'Porcentaje de descuento'), '150');
      await tester.enterText(find.widgetWithText(TextField, 'Motivo'), 'x');
      await tester.pumpAndSettle();
      expect(find.text('No puede pasar de 100 %'), findsOneWidget);
      final aplicar = find.widgetWithText(FilledButton, 'Aplicar descuento');
      expect(tester.widget<FilledButton>(aplicar).onPressed, isNull);
    });

    testWidgets('el monto no puede pasar del total del pedido', (tester) async {
      await _abrirDetalle(tester);
      await tester.tap(find.text('Aplicar descuento o cortesía'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Monto'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'Monto del descuento'), '400');
      await tester.enterText(find.widgetWithText(TextField, 'Motivo'), 'x');
      await tester.pumpAndSettle();
      expect(find.text(r'No puede pasar de $313.00'), findsOneWidget);
      final aplicar = find.widgetWithText(FilledButton, 'Aplicar descuento');
      expect(tester.widget<FilledButton>(aplicar).onPressed, isNull);
    });

    testWidgets('el motivo es obligatorio', (tester) async {
      await _abrirDetalle(tester);
      await tester.tap(find.text('Aplicar descuento o cortesía'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'Porcentaje de descuento'), '20');
      await tester.pumpAndSettle();
      final aplicar = find.widgetWithText(FilledButton, 'Aplicar descuento');
      expect(tester.widget<FilledButton>(aplicar).onPressed, isNull);
    });

    testWidgets('cortesía: sin monto, el pedido queda en cero', (tester) async {
      final repo = await _abrirDetalle(tester);
      await tester.tap(find.text('Aplicar descuento o cortesía'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cortesía'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextField, 'Monto del descuento'), findsNothing);
      expect(find.widgetWithText(TextField, 'Porcentaje de descuento'), findsNothing);
      expect(find.textContaining('queda sin costo'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextField, 'Motivo'), 'Invita la casa');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Aplicar cortesía'));
      await tester.pumpAndSettle();

      expect(repo.descuentos.single, (folio: 108, monto: 0.0, esCortesia: true, motivo: 'Invita la casa'));
      expect(_total(tester), r'$0.00');
      expect(find.text('Cortesía'), findsOneWidget); // la fila del desglose
      expect(find.text(r'-$313.00'), findsOneWidget);
      await _dejarPasarAvisos(tester);
    });

    testWidgets('puede quitar un descuento ya aplicado', (tester) async {
      final repo = await _abrirDetalle(
        tester,
        detalle: _detalle(total: 263, descuento: 50, motivo: 'Queja por la demora'),
      );
      expect(_total(tester), r'$263.00');
      await tester.tap(find.text('Cambiar descuento o cortesía'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Quitar descuento'));
      await tester.pumpAndSettle();

      expect(repo.descuentos.single.monto, 0.0);
      expect(repo.descuentos.single.esCortesia, isFalse);
      expect(_total(tester), r'$313.00');
      expect(find.text(r'-$50.00'), findsNothing);
      await _dejarPasarAvisos(tester);
    });

    testWidgets('sin descuento previo no ofrece "Quitar descuento"', (tester) async {
      await _abrirDetalle(tester);
      await tester.tap(find.text('Aplicar descuento o cortesía'));
      await tester.pumpAndSettle();
      expect(find.text('Quitar descuento'), findsNothing);
    });

    testWidgets('si la base rechaza, muestra el error y no cambia el total', (tester) async {
      final repo = await _abrirDetalle(tester);
      repo.errorAlGuardar = 'Solo el gerente puede autorizar descuentos o cortesías';
      await tester.tap(find.text('Aplicar descuento o cortesía'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'Porcentaje de descuento'), '10');
      await tester.enterText(find.widgetWithText(TextField, 'Motivo'), 'Prueba');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Aplicar descuento'));
      await tester.pumpAndSettle();
      expect(find.text('Solo el gerente puede autorizar descuentos o cortesías'), findsOneWidget);
      expect(_total(tester), r'$313.00');
      await _dejarPasarAvisos(tester);
    });
  });
}
