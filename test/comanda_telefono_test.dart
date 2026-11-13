import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/domain/entities/perfil.dart';

import 'helpers/app.dart';
import 'helpers/fakes.dart';

/// Comanda en pantalla de teléfono (POCO X7 Pro ≈ 437 × 972 px lógicos).
void main() {
  testWidgets('teléfono: barra compacta y barra inferior con platillos y total', (tester) async {
    await abrirApp(
      tester,
      auth: FakeAuthRepository(sesion: perfilDe(RolUsuario.mesero)),
      ventana: const Size(437, 972),
    );
    await tester.tap(find.text('Registrar Nuevo Pedido'));
    await tester.pumpAndSettle();

    // Barra compacta: "Volver" es solo un ícono y no hay rótulo "Mesa".
    expect(find.text('Volver al Dashboard'), findsNothing);
    expect(find.text('Seleccionar mesa *'), findsOneWidget);
    expect(find.text('Presencial'), findsOneWidget);
    expect(find.text('Para Llevar'), findsOneWidget);

    // Barra inferior fija.
    expect(find.text('Comanda vacía'), findsOneWidget);
    await tester.tap(find.text('Agregar al Pedido').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('1 platillo ·'), findsOneWidget);
    expect(find.text('Ver comanda'), findsOneWidget);

    // Tocar la barra lleva hasta el resumen de la comanda.
    await tester.tap(find.text('Ver comanda'));
    await tester.pumpAndSettle();
    expect(find.text('Resumen de Comanda'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('escritorio: sin barra inferior (el panel va a un lado)', (tester) async {
    await abrirApp(
      tester,
      auth: FakeAuthRepository(sesion: perfilDe(RolUsuario.mesero)),
      ventana: const Size(1500, 1000),
    );
    await tester.tap(find.text('Registrar Nuevo Pedido'));
    await tester.pumpAndSettle();
    expect(find.text('Ver comanda'), findsNothing);
    expect(find.text('Volver al Dashboard'), findsOneWidget);
  });
}
