import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:restaurant_app/core/router/destinos.dart';
import 'package:restaurant_app/domain/entities/perfil.dart';

import 'helpers/app.dart';
import 'helpers/fakes.dart';

void main() {
  test('destinos por rol', () {
    expect(destinosPara(RolUsuario.mesero), [Destino.inicio]);
    expect(destinosPara(RolUsuario.chef), [Destino.inicio, Destino.cocina]);
    expect(destinosPara(RolUsuario.gerente), Destino.values);
    expect(destinosPara(RolUsuario.cliente), [Destino.inicio]);
  });

  testWidgets('mesero: sin pestañas', (tester) async {
    await abrirApp(tester, auth: FakeAuthRepository(sesion: perfilDe(RolUsuario.mesero)));
    expect(find.text('Cocina'), findsNothing);
    expect(find.text('Gerencia'), findsNothing);
  });

  testWidgets('chef: Inicio y Cocina, sin Gerencia; en Inicio no opera pedidos', (tester) async {
    await abrirApp(
      tester,
      auth: FakeAuthRepository(sesion: perfilDe(RolUsuario.chef)),
      pedidos: FakePedidoRepository([pedidoDePrueba(folioDia: 1)]),
    );
    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Cocina'), findsOneWidget);
    expect(find.text('Gerencia'), findsNothing);
    // El chef consulta la comandería pero no registra ni edita pedidos.
    expect(find.text('Registrar Nuevo Pedido'), findsNothing);
    expect(find.text('Editar'), findsNothing);

    await tester.tap(find.text('Cocina'));
    await tester.pumpAndSettle();
    expect(find.textContaining('vista de cocina'), findsOneWidget);
  });

  testWidgets('gerente: ve todas las pestañas y opera pedidos', (tester) async {
    await abrirApp(
      tester,
      auth: FakeAuthRepository(sesion: perfilDe(RolUsuario.gerente)),
      pedidos: FakePedidoRepository([pedidoDePrueba(folioDia: 1)]),
    );
    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Cocina'), findsOneWidget);
    expect(find.text('Gerencia'), findsOneWidget);
    expect(find.text('Registrar Nuevo Pedido'), findsOneWidget);

    await tester.tap(find.text('Gerencia'));
    await tester.pumpAndSettle();
    expect(find.text('Cuentas de personal'), findsOneWidget);
  });

  testWidgets('un mesero que entra a /gerencia a la fuerza no ve la sección', (tester) async {
    await abrirApp(tester, auth: FakeAuthRepository(sesion: perfilDe(RolUsuario.mesero)));
    final contexto = tester.element(find.text('Comandería y Mesas'));
    GoRouter.of(contexto).go('/gerencia');
    await tester.pumpAndSettle();
    expect(find.text('No tienes acceso a esta sección'), findsOneWidget);
    expect(find.text('Cuentas de personal'), findsNothing);
  });
}
