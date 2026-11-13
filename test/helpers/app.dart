import 'package:flutter/material.dart';
import 'fakes_cocina.dart';
import 'fakes_solicitudes.dart';
import 'fakes_reporte.dart';
import 'fakes_bitacora.dart';
import 'fakes_reservaciones.dart';
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
  FakeReservacionRepository? reservaciones,
  FakeCocinaRepository? cocina,
  FakeSolicitudRepository? solicitudes,
  FakeReporteRepository? reporte,
  FakeBitacoraRepository? bitacora,
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
      reservacionRepositoryProvider.overrideWithValue(reservaciones ?? FakeReservacionRepository()),
      cocinaRepositoryProvider.overrideWithValue(cocina ?? FakeCocinaRepository()),
      solicitudRepositoryProvider.overrideWithValue(solicitudes ?? FakeSolicitudRepository()),
      reporteRepositoryProvider.overrideWithValue(reporte ?? FakeReporteRepository()),
      bitacoraRepositoryProvider.overrideWithValue(bitacora ?? FakeBitacoraRepository()),
      relojProvider.overrideWith((ref) => Stream.value(DateTime.now())),
    ],
    child: const RestaurantApp(),
  ));
  await tester.pumpAndSettle();
}
