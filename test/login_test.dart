import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/data/repository_providers.dart';
import 'package:restaurant_app/features/pedidos/pedidos_providers.dart';
import 'package:restaurant_app/main.dart';

import 'helpers/fakes.dart';

Widget _app(FakeAuthRepository auth, FakePedidoRepository pedidos) => ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        pedidoRepositoryProvider.overrideWithValue(pedidos),
        relojProvider.overrideWith((ref) => Stream.value(DateTime.now())),
      ],
      child: const RestaurantApp(),
    );

void main() {
  // Tamaño de ventana de escritorio para todas las pruebas.
  setUp(() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first
      ..physicalSize = const Size(1400, 900)
      ..devicePixelRatio = 1;
  });
  tearDown(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher.views.first
      ..resetPhysicalSize()
      ..resetDevicePixelRatio();
  });

  testWidgets('sin sesión muestra el login', (tester) async {
    await tester.pumpWidget(_app(FakeAuthRepository(), FakePedidoRepository([])));
    await tester.pumpAndSettle();
    expect(find.text('Iniciar Sesión'), findsOneWidget);
    expect(find.text('Ingresar al Sistema'), findsOneWidget);
  });

  testWidgets('campos vacíos muestran validación', (tester) async {
    await tester.pumpWidget(_app(FakeAuthRepository(), FakePedidoRepository([])));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ingresar al Sistema'));
    await tester.pumpAndSettle();
    expect(find.text('Ingresa tu usuario'), findsOneWidget);
    expect(find.text('Ingresa tu contraseña'), findsOneWidget);
  });

  testWidgets('credenciales incorrectas muestran el error y no entra', (tester) async {
    final auth = FakeAuthRepository();
    await tester.pumpWidget(_app(auth, FakePedidoRepository([])));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'mesero');
    await tester.enterText(find.byType(TextFormField).at(1), 'mala');
    await tester.tap(find.text('Ingresar al Sistema'));
    await tester.pumpAndSettle();

    expect(find.text('Usuario o contraseña incorrectos'), findsOneWidget);
    expect(find.text('Iniciar Sesión'), findsOneWidget);
  });

  testWidgets('credenciales correctas llevan a la Comandería', (tester) async {
    final auth = FakeAuthRepository();
    final pedidos = FakePedidoRepository([pedidoDePrueba(folioDia: 108)]);
    await tester.pumpWidget(_app(auth, pedidos));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'mesero');
    await tester.enterText(find.byType(TextFormField).at(1), 'secreta');
    await tester.tap(find.text('Ingresar al Sistema'));
    await tester.pumpAndSettle();

    expect(find.text('Comandería y Mesas'), findsOneWidget);
    expect(find.text('Juan Pérez'), findsWidgets);
    expect(find.text('#PED-108'), findsOneWidget);
  });

  testWidgets('con sesión previa entra directo y "Salir" regresa al login', (tester) async {
    final auth = FakeAuthRepository(conSesion: true);
    await tester.pumpWidget(_app(auth, FakePedidoRepository([])));
    await tester.pumpAndSettle();
    expect(find.text('Comandería y Mesas'), findsOneWidget);

    await tester.tap(find.text('Salir'));
    await tester.pumpAndSettle();
    expect(find.text('Iniciar Sesión'), findsOneWidget);
  });
}
