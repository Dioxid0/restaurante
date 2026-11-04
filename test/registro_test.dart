import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/app.dart';
import 'helpers/fakes.dart';

Future<void> _irARegistro(WidgetTester tester) async {
  await tester.tap(find.text('Crear cuenta'));
  await tester.pumpAndSettle();
}

Future<void> _llenar(
  WidgetTester tester, {
  String nombre = 'Ana Cliente',
  String correo = 'ana@correo.com',
  String password = 'Contra1234',
  String confirmar = 'Contra1234',
}) async {
  final campos = find.byType(TextFormField);
  await tester.enterText(campos.at(0), nombre);
  await tester.enterText(campos.at(1), correo);
  await tester.enterText(campos.at(3), password);
  await tester.enterText(campos.at(4), confirmar);
  await tester.ensureVisible(find.text('Crear cuenta').last);
  await tester.tap(find.text('Crear cuenta').last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('desde el login se llega al registro y se puede volver', (tester) async {
    await abrirApp(tester);
    await _irARegistro(tester);
    expect(find.text('Regístrate para reservar y hacer pedidos en línea'), findsOneWidget);
    await tester.tap(find.text('Inicia sesión'));
    await tester.pumpAndSettle();
    expect(find.text('Iniciar Sesión'), findsOneWidget);
  });

  testWidgets('valida correo, contraseña corta y confirmación', (tester) async {
    final auth = FakeAuthRepository();
    await abrirApp(tester, auth: auth);
    await _irARegistro(tester);
    await _llenar(tester, correo: 'no-es-correo', password: '123', confirmar: '456');
    expect(find.text('Ingresa un correo válido'), findsOneWidget);
    expect(find.text('La contraseña debe tener al menos 8 caracteres'), findsOneWidget);
    expect(find.text('Las contraseñas no coinciden'), findsOneWidget);
    expect(auth.registros, isEmpty);
  });

  testWidgets('rechaza correos del dominio interno de empleados', (tester) async {
    final auth = FakeAuthRepository();
    await abrirApp(tester, auth: auth);
    await _irARegistro(tester);
    await _llenar(tester, correo: 'mesero@restaurante.local');
    expect(find.text('Ese correo no está permitido'), findsOneWidget);
    expect(auth.registros, isEmpty);
  });

  testWidgets('registro correcto crea la cuenta de cliente y entra a su inicio', (tester) async {
    final auth = FakeAuthRepository();
    await abrirApp(tester, auth: auth);
    await _irARegistro(tester);
    await _llenar(tester);
    expect(auth.registros.single.correo, 'ana@correo.com');
    expect(find.textContaining('Hola, Ana Cliente'), findsOneWidget);
  });

  testWidgets('si hay que confirmar el correo lo indica', (tester) async {
    await abrirApp(tester, auth: FakeAuthRepository(requiereConfirmarCorreo: true));
    await _irARegistro(tester);
    await _llenar(tester);
    expect(find.text('Revisa tu correo'), findsOneWidget);
  });
}
