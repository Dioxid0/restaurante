import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/domain/entities/cuenta_personal.dart';
import 'package:restaurant_app/domain/entities/perfil.dart';

import 'helpers/app.dart';
import 'helpers/fakes.dart';

Future<FakeEmpleadoRepository> _abrirGerencia(WidgetTester tester) async {
  final empleados = FakeEmpleadoRepository([
    const CuentaPersonal(
      idEmpleado: 1,
      nombre: 'Juan Pérez',
      usuario: 'mesero',
      rol: RolUsuario.mesero,
      activo: true,
      turno: 'matutino',
    ),
  ]);
  await abrirApp(
    tester,
    auth: FakeAuthRepository(sesion: perfilDe(RolUsuario.gerente, nombre: 'Gerente')),
    empleados: empleados,
  );
  await tester.tap(find.text('Gerencia'));
  await tester.pumpAndSettle();
  return empleados;
}

void main() {
  testWidgets('lista las cuentas de personal', (tester) async {
    await _abrirGerencia(tester);
    expect(find.text('Juan Pérez'), findsWidgets);
    expect(find.text('mesero'), findsOneWidget);
    expect(find.text('Activa'), findsOneWidget);
  });

  testWidgets('crear cuenta: valida y llama al repositorio con rol y usuario', (tester) async {
    final repo = await _abrirGerencia(tester);
    await tester.tap(find.text('Nueva cuenta'));
    await tester.pumpAndSettle();

    // Sin llenar: valida
    await tester.tap(find.text('Crear cuenta'));
    await tester.pumpAndSettle();
    expect(find.text('Indica el nombre'), findsOneWidget);
    expect(repo.creadas, isEmpty);

    final campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), 'Sofía Ruiz');
    await tester.enterText(campos.at(1), 'Sofia Ruiz');
    await tester.enterText(campos.at(2), 'Contra1234');
    await tester.tap(find.text('Crear cuenta'));
    await tester.pumpAndSettle();

    expect(repo.creadas.single.usuario, 'Sofia Ruiz');
    expect(repo.creadas.single.rol, RolUsuario.mesero);
    expect(find.text('Cuenta creada'), findsOneWidget);
    expect(find.text('Sofía Ruiz'), findsOneWidget); // ya aparece en la lista
  });

  testWidgets('muestra el error que devuelve la base (usuario duplicado)', (tester) async {
    final repo = await _abrirGerencia(tester);
    repo.errorAlCrear = 'Ese usuario ya existe';
    await tester.tap(find.text('Nueva cuenta'));
    await tester.pumpAndSettle();

    final campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), 'Otro');
    await tester.enterText(campos.at(1), 'mesero');
    await tester.enterText(campos.at(2), 'Contra1234');
    await tester.tap(find.text('Crear cuenta'));
    await tester.pumpAndSettle();

    expect(find.text('Ese usuario ya existe'), findsOneWidget);
    expect(find.text('Nueva cuenta de personal'), findsOneWidget); // el diálogo sigue abierto
  });

  testWidgets('el rol Gerente permite capturar un PIN; Cliente no es opción', (tester) async {
    await _abrirGerencia(tester);
    await tester.tap(find.text('Nueva cuenta'));
    await tester.pumpAndSettle();
    expect(find.textContaining('PIN de autorización'), findsNothing);

    await tester.tap(find.text('Mesero').last);
    await tester.pumpAndSettle();
    expect(find.text('Cliente'), findsNothing);
    await tester.tap(find.text('Gerente').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('PIN de autorización'), findsOneWidget);
  });
}
