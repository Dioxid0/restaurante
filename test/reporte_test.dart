import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/domain/entities/perfil.dart';
import 'package:restaurant_app/features/gerencia/reporte_providers.dart';

import 'helpers/app.dart';
import 'helpers/fakes.dart';
import 'helpers/fakes_reporte.dart';

Future<void> _abrir(WidgetTester tester, FakeReporteRepository reporte) async {
  await abrirApp(
    tester,
    auth: FakeAuthRepository(sesion: perfilDe(RolUsuario.gerente, nombre: 'Gerente')),
    reporte: reporte,
  );
  await tester.tap(find.text('Gerencia'));
  await tester.pumpAndSettle();
}

void main() {
  test('los periodos calculan su rango', () {
    final ahora = DateTime(2026, 11, 12, 15, 30);
    expect(PeriodoReporte.hoy.rango(ahora), (desde: DateTime(2026, 11, 12), hasta: DateTime(2026, 11, 12)));
    expect(PeriodoReporte.ayer.rango(ahora), (desde: DateTime(2026, 11, 11), hasta: DateTime(2026, 11, 11)));
    expect(PeriodoReporte.ultimos7.rango(ahora), (desde: DateTime(2026, 11, 6), hasta: DateTime(2026, 11, 12)));
    expect(PeriodoReporte.ultimos30.rango(ahora), (desde: DateTime(2026, 10, 14), hasta: DateTime(2026, 11, 12)));
  });

  testWidgets('el gerente ve el reporte de hoy al entrar a Gerencia', (tester) async {
    final repo = FakeReporteRepository();
    await _abrir(tester, repo);

    expect(find.text('Reporte gerencial'), findsOneWidget);
    expect(repo.pedidos, hasLength(1));
    expect(repo.pedidos.single.$1, repo.pedidos.single.$2); // "Hoy": un solo día
    expect(find.text('\$1,000.00'), findsOneWidget); // ventas
    expect(find.text('\$333.33'), findsOneWidget); // ticket promedio
    expect(find.textContaining('4 en total'), findsOneWidget);
    expect(find.text('Tacos al pastor · 9 vendidos'), findsOneWidget);
    expect(find.text('Descuentos (1)'), findsOneWidget);
    expect(find.text('Cortesías (1)'), findsOneWidget);
    expect(find.textContaining('El cliente se fue'), findsOneWidget);
    expect(find.text('Ventas por día'), findsNothing); // un solo día: sin gráfica por día
  });

  testWidgets('cambiar de periodo pide otro rango y muestra ventas por día', (tester) async {
    final repo = FakeReporteRepository();
    await _abrir(tester, repo);

    await tester.tap(find.text('Últimos 7 días'));
    await tester.pumpAndSettle();

    expect(repo.pedidos, hasLength(2));
    final (desde, hasta) = repo.pedidos.last;
    expect(hasta.difference(desde).inDays, 6);
    expect(find.text('Ventas por día'), findsOneWidget);
  });

  testWidgets('sin pedidos muestra un aviso', (tester) async {
    await _abrir(tester, FakeReporteRepository(vacio: true));
    expect(find.text('No hay pedidos en este periodo'), findsOneWidget);
  });

  testWidgets('si falla, muestra el error y permite reintentar', (tester) async {
    final repo = FakeReporteRepository(error: 'Solo el gerente puede ver el reporte');
    await _abrir(tester, repo);
    expect(find.text('Solo el gerente puede ver el reporte'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets('se puede pasar a Cuentas y volver al Reporte', (tester) async {
    await _abrir(tester, FakeReporteRepository());
    await tester.tap(find.text('Cuentas'));
    await tester.pumpAndSettle();
    expect(find.text('Cuentas de personal'), findsOneWidget);
    await tester.tap(find.text('Reporte'));
    await tester.pumpAndSettle();
    expect(find.text('Reporte gerencial'), findsOneWidget);
  });
}
