import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/domain/entities/cuenta_personal.dart';
import 'package:restaurant_app/domain/entities/perfil.dart';

import 'helpers/app.dart';
import 'helpers/fakes.dart';

/// Gerencia en pantalla de teléfono (POCO X7 Pro ≈ 437 × 972 px lógicos):
/// las tablas se desplazan de lado y no se desbordan ni parten el texto.
void main() {
  testWidgets('teléfono: Menú, Mesas y Cuentas se abren sin desbordar', (tester) async {
    await abrirApp(
      tester,
      auth: FakeAuthRepository(sesion: perfilDe(RolUsuario.gerente)),
      empleados: FakeEmpleadoRepository([
        const CuentaPersonal(
          idEmpleado: 1,
          nombre: 'Sofía Ruiz',
          usuario: 'sruiz',
          rol: RolUsuario.mesero,
          activo: true,
          turno: 'matutino',
        ),
      ]),
      ventana: const Size(437, 972),
    );

    // La barra de pestañas se desplaza de lado: se lleva "Gerencia" a la vista.
    await tester.ensureVisible(find.text('Gerencia'));
    await tester.tap(find.text('Gerencia'));
    await tester.pumpAndSettle();

    for (final seccion in ['Menú', 'Mesas', 'Cuentas']) {
      await tester.ensureVisible(find.text(seccion).first);
      await tester.tap(find.text(seccion).first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'overflow en $seccion');
    }

    // Cuentas: el botón queda debajo del título a todo el ancho y la tabla sigue completa.
    expect(find.text('Cuentas de personal'), findsOneWidget);
    expect(find.text('Nueva cuenta'), findsOneWidget);
    expect(find.text('Sofía Ruiz'), findsOneWidget);
  });
}
