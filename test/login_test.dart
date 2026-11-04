import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/domain/entities/perfil.dart';

import 'helpers/app.dart';
import 'helpers/fakes.dart';

Future<void> _llenar(WidgetTester tester, String usuario, String password) async {
  await tester.enterText(find.byType(TextFormField).at(0), usuario);
  await tester.enterText(find.byType(TextFormField).at(1), password);
  await tester.tap(find.text('Ingresar al Sistema'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('sin sesión muestra el login con el campo "Usuario o correo electrónico"', (tester) async {
    await abrirApp(tester);
    expect(find.text('Iniciar Sesión'), findsOneWidget);
    expect(find.text('Usuario o correo electrónico'), findsOneWidget);
    expect(find.text('Juan Perez'), findsOneWidget); // hint
    expect(find.text('Crear cuenta'), findsOneWidget);
  });

  testWidgets('campos vacíos muestran validación', (tester) async {
    await abrirApp(tester);
    await tester.tap(find.text('Ingresar al Sistema'));
    await tester.pumpAndSettle();
    expect(find.text('Ingresa tu usuario o correo'), findsOneWidget);
    expect(find.text('Ingresa tu contraseña'), findsOneWidget);
  });

  testWidgets('credenciales incorrectas muestran el error y no entra', (tester) async {
    await abrirApp(tester);
    await _llenar(tester, 'mesero', 'mala');
    expect(find.text('Usuario o contraseña incorrectos'), findsOneWidget);
    expect(find.text('Iniciar Sesión'), findsOneWidget);
  });

  testWidgets('credenciales correctas llevan a la Comandería', (tester) async {
    final auth = FakeAuthRepository();
    await abrirApp(tester, auth: auth, pedidos: FakePedidoRepository([pedidoDePrueba(folioDia: 108)]));
    await _llenar(tester, 'mesero', 'secreta');
    expect(auth.ultimoIdentificador, 'mesero');
    expect(find.text('Comandería y Mesas'), findsOneWidget);
    expect(find.text('#PED-108'), findsOneWidget);
  });

  testWidgets('el mismo login sirve para un cliente (correo) y lo lleva a su inicio', (tester) async {
    final auth = FakeAuthRepository()
      ..perfilAlIngresar = const Perfil(id: 5, nombre: 'Ana Cliente', rol: RolUsuario.cliente);
    await abrirApp(tester, auth: auth);
    await _llenar(tester, 'ana@correo.com', 'secreta');
    expect(auth.ultimoIdentificador, 'ana@correo.com');
    expect(find.text('Comandería y Mesas'), findsNothing);
    expect(find.textContaining('Hola, Ana Cliente'), findsOneWidget);
  });

  testWidgets('con sesión previa entra directo y "Salir" regresa al login', (tester) async {
    await abrirApp(tester, auth: FakeAuthRepository(sesion: perfilDe(RolUsuario.mesero)));
    expect(find.text('Comandería y Mesas'), findsOneWidget);

    await tester.tap(find.text('Salir'));
    await tester.pumpAndSettle();
    expect(find.text('Iniciar Sesión'), findsOneWidget);
  });
}
