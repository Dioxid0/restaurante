import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/data/repository_providers.dart';
import 'package:restaurant_app/features/pedidos/pedidos_providers.dart';
import 'package:restaurant_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes.dart';

/// Abre la app completa con repositorios falsos y una ventana de escritorio.
Future<void> abrirApp(
  WidgetTester tester, {
  FakeAuthRepository? auth,
  FakePedidoRepository? pedidos,
  FakeEmpleadoRepository? empleados,
  FakeMenuRepository? menu,
  FakeMesaRepository? mesas,
  Size ventana = const Size(1400, 900),
}) async {
  SharedPreferences.setMockInitialValues({});
  tester.view.physicalSize = ventana;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(auth ?? FakeAuthRepository()),
      pedidoRepositoryProvider.overrideWithValue(pedidos ?? FakePedidoRepository([])),
      empleadoRepositoryProvider.overrideWithValue(empleados ?? FakeEmpleadoRepository()),
      menuRepositoryProvider.overrideWithValue(menu ?? FakeMenuRepository()),
      mesaRepositoryProvider.overrideWithValue(mesas ?? FakeMesaRepository()),
      relojProvider.overrideWith((ref) => Stream.value(DateTime.now())),
    ],
    child: const RestaurantApp(),
  ));
  await tester.pumpAndSettle();
}
