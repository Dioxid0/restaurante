import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/data/repository_providers.dart';
import 'package:restaurant_app/domain/entities/perfil.dart';
import 'package:restaurant_app/domain/entities/reservacion.dart';
import 'package:restaurant_app/domain/errors.dart';
import 'package:restaurant_app/features/reservaciones/reservaciones_providers.dart';

import 'helpers/app.dart';
import 'helpers/fakes.dart';
import 'helpers/fakes_reservaciones.dart';

/// Deja pasar el aviso flotante (dura 4 s) para que su temporizador termine.
Future<void> _dejarPasarAvisos(WidgetTester tester) => tester.pump(const Duration(seconds: 6));

/// Abre la app con la sesión de [rol] y entra a la pestaña Reservaciones.
Future<FakeReservacionRepository> _abrir(
  WidgetTester tester, {
  required RolUsuario rol,
  required List<Reservacion> lista,
}) async {
  final repo = FakeReservacionRepository(lista);
  await abrirApp(
    tester,
    auth: FakeAuthRepository(sesion: perfilDe(rol)),
    reservaciones: repo,
  );
  await tester.tap(find.text('Reservaciones'));
  await tester.pumpAndSettle();
  return repo;
}

void main() {
  group('Reservacion (reglas de la entidad)', () {
    final ahora = DateTime(2026, 11, 10, 12, 0);

    Reservacion r(DateTime inicio, {EstadoReservacion estado = EstadoReservacion.pendiente}) =>
        Reservacion(
          idReservacion: 1,
          inicio: inicio,
          comensales: 2,
          estado: estado,
          idCliente: 1,
        );

    test('dura 2 horas', () {
      final res = r(DateTime(2026, 11, 10, 19, 30));
      expect(res.fin, DateTime(2026, 11, 10, 21, 30));
    });

    test('etiqueta de la mesa: M-03, o null si no se puede ver', () {
      expect(r(ahora).copyWith(numeroMesa: 3).mesaEtiqueta, 'M-03');
      expect(r(ahora).mesaEtiqueta, isNull);
    });

    test('RN-07: el cliente solo cambia con más de 5 horas de anticipación', () {
      expect(r(DateTime(2026, 11, 10, 18, 0)).clientePuedeCambiar(ahora), isTrue); // faltan 6 h
      expect(r(DateTime(2026, 11, 10, 16, 0)).clientePuedeCambiar(ahora), isFalse); // faltan 4 h
    });

    test('una reservación cancelada o completada ya no se puede cambiar', () {
      final lejos = DateTime(2026, 11, 12, 18, 0);
      expect(r(lejos, estado: EstadoReservacion.cancelada).clientePuedeCambiar(ahora), isFalse);
      expect(r(lejos, estado: EstadoReservacion.completada).clientePuedeCambiar(ahora), isFalse);
      expect(r(lejos, estado: EstadoReservacion.confirmada).clientePuedeCambiar(ahora), isTrue);
    });

    test('"¿Confirmas?" solo si está pendiente y faltan 5 horas o menos', () {
      expect(r(DateTime(2026, 11, 10, 15, 0)).requiereConfirmacion(ahora), isTrue); // faltan 3 h
      expect(r(DateTime(2026, 11, 10, 18, 0)).requiereConfirmacion(ahora), isFalse); // faltan 6 h
      expect(
        r(DateTime(2026, 11, 10, 15, 0), estado: EstadoReservacion.confirmada).requiereConfirmacion(ahora),
        isFalse,
      );
      expect(r(DateTime(2026, 11, 10, 11, 0)).requiereConfirmacion(ahora), isFalse); // ya pasó
    });

    test('estados: los de la base de datos y cuáles están activos', () {
      expect(EstadoReservacion.desdeBd('confirmada'), EstadoReservacion.confirmada);
      expect(EstadoReservacion.pendiente.esActiva, isTrue);
      expect(EstadoReservacion.confirmada.esActiva, isTrue);
      expect(EstadoReservacion.cancelada.esActiva, isFalse);
      expect(EstadoReservacion.completada.esActiva, isFalse);
    });
  });

  group('Providers (crear, modificar, cancelar, confirmar)', () {
    Future<(ProviderContainer, FakeReservacionRepository)> preparar() async {
      final repo = FakeReservacionRepository([reservacionDePrueba()]);
      final contenedor = ProviderContainer(
        overrides: [reservacionRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(contenedor.dispose);
      // Se mantiene escuchando para que el provider no se descarte entre llamadas.
      contenedor.listen(reservacionesListaProvider, (_, _) {});
      await contenedor.read(reservacionesListaProvider.future);
      return (contenedor, repo);
    }

    test('carga la lista', () async {
      final (c, _) = await preparar();
      expect(c.read(reservacionesListaProvider).value, hasLength(1));
    });

    test('crear (CU-10) manda fecha, comensales y cliente al repositorio', () async {
      final (c, repo) = await preparar();
      final inicio = DateTime.now().add(const Duration(days: 2));
      final id = await c
          .read(reservacionesListaProvider.notifier)
          .crear(inicio: inicio, comensales: 4, idCliente: 7);
      expect(id, 501);
      expect(repo.creadas.single.comensales, 4);
      expect(repo.creadas.single.idCliente, 7);
      expect(repo.creadas.single.inicio, inicio);
    });

    test('modificar (CU-13)', () async {
      final (c, repo) = await preparar();
      final inicio = DateTime.now().add(const Duration(days: 3));
      await c
          .read(reservacionesListaProvider.notifier)
          .modificar(idReservacion: 1, inicio: inicio, comensales: 6);
      expect(repo.modificadas.single.id, 1);
      expect(repo.modificadas.single.comensales, 6);
    });

    test('cancelar (CU-14) y confirmar', () async {
      final (c, repo) = await preparar();
      final lista = c.read(reservacionesListaProvider.notifier);
      await lista.confirmar(1);
      expect(repo.confirmadas, [1]);
      await lista.cancelar(1);
      expect(repo.canceladas, [1]);
    });

    test('si la base rechaza la acción, el motivo llega como ErrorDeNegocio', () async {
      final (c, repo) = await preparar();
      repo.errorAlGuardar = 'No hay mesas disponibles para esa fecha, hora y número de comensales';
      expect(
        () => c.read(reservacionesListaProvider.notifier).crear(
              inicio: DateTime.now().add(const Duration(days: 2)),
              comensales: 20,
            ),
        throwsA(isA<ErrorDeNegocio>()),
      );
    });
  });

  group('Pantalla de reservaciones', () {
    testWidgets('cliente: ve su reservación, sin mesa ni nombre', (tester) async {
      await _abrir(
        tester,
        rol: RolUsuario.cliente,
        lista: [reservacionDePrueba(mesa: 3, cliente: 'Ana López')],
      );
      expect(find.text('Mis reservaciones'), findsOneWidget);
      expect(find.text('Pendiente'), findsOneWidget);
      expect(find.text('2 personas'), findsOneWidget);
      expect(find.textContaining('M-03'), findsNothing);
      expect(find.textContaining('Ana López'), findsNothing);
    });

    testWidgets('mesero: ve la mesa asignada y el nombre del cliente', (tester) async {
      await _abrir(
        tester,
        rol: RolUsuario.mesero,
        lista: [reservacionDePrueba(mesa: 3, cliente: 'Ana López')],
      );
      expect(find.textContaining('Mesa M-03'), findsOneWidget);
      expect(find.textContaining('Ana López'), findsOneWidget);
    });

    testWidgets('sin reservaciones próximas muestra el aviso; Historial muestra las canceladas',
        (tester) async {
      await _abrir(
        tester,
        rol: RolUsuario.cliente,
        lista: [reservacionDePrueba(estado: EstadoReservacion.cancelada)],
      );
      expect(find.text('No hay reservaciones próximas'), findsOneWidget);
      await tester.tap(find.text('Historial'));
      await tester.pumpAndSettle();
      expect(find.text('Cancelada'), findsOneWidget);
    });

    testWidgets('cliente con 3 h de anticipación: pregunta "¿Confirmas?" y no puede cambiarla',
        (tester) async {
      await _abrir(
        tester,
        rol: RolUsuario.cliente,
        lista: [reservacionDePrueba(enCuanto: const Duration(hours: 3))],
      );
      expect(find.text('¿Confirmas tu reservación? Te esperamos pronto.'), findsOneWidget);
      expect(find.byTooltip('Confirmar'), findsOneWidget);
      expect(find.byTooltip('Cancelar'), findsNothing);
      expect(find.byTooltip('Modificar'), findsNothing);
      expect(find.textContaining('contacta al restaurante'), findsOneWidget);
    });

    testWidgets('mesero: puede cancelar y modificar aunque falten menos de 5 horas', (tester) async {
      await _abrir(
        tester,
        rol: RolUsuario.mesero,
        lista: [reservacionDePrueba(enCuanto: const Duration(hours: 3), cliente: 'Ana López')],
      );
      expect(find.byTooltip('Cancelar'), findsOneWidget);
      expect(find.byTooltip('Modificar'), findsOneWidget);
    });

    testWidgets('confirmar pide confirmación y avisa', (tester) async {
      final repo = await _abrir(
        tester,
        rol: RolUsuario.cliente,
        lista: [reservacionDePrueba(enCuanto: const Duration(hours: 3))],
      );
      await tester.tap(find.byTooltip('Confirmar'));
      await tester.pumpAndSettle();
      expect(find.text('¿Confirmar la reservación?'), findsOneWidget);
      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();
      expect(repo.confirmadas, [1]);
      expect(find.text('Reservación confirmada'), findsOneWidget);
      await _dejarPasarAvisos(tester);
    });

    testWidgets('cancelar pide confirmación; la reservación sale de Próximas', (tester) async {
      final repo = await _abrir(
        tester,
        rol: RolUsuario.cliente,
        lista: [reservacionDePrueba(enCuanto: const Duration(days: 2))],
      );
      await tester.tap(find.byTooltip('Cancelar'));
      await tester.pumpAndSettle();
      expect(find.text('¿Cancelar la reservación?'), findsOneWidget);
      await tester.tap(find.text('Sí, cancelar'));
      await tester.pumpAndSettle();
      expect(repo.canceladas, [1]);
      expect(find.text('Reservación cancelada'), findsOneWidget);
      expect(find.text('No hay reservaciones próximas'), findsOneWidget);
      await _dejarPasarAvisos(tester);
    });

    testWidgets('si la base rechaza la cancelación, se muestra su mensaje', (tester) async {
      final repo = await _abrir(
        tester,
        rol: RolUsuario.cliente,
        lista: [reservacionDePrueba(enCuanto: const Duration(days: 2))],
      );
      repo.errorAlCambiarEstado = 'Solo puedes cancelar con 5 horas de anticipación; contacta al restaurante';
      await tester.tap(find.byTooltip('Cancelar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sí, cancelar'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Solo puedes cancelar con 5 horas'), findsOneWidget);
      expect(repo.canceladas, isEmpty);
      await _dejarPasarAvisos(tester);
    });

    testWidgets('formulario nuevo: exige fecha y hora antes de reservar', (tester) async {
      final repo = await _abrir(tester, rol: RolUsuario.cliente, lista: []);
      await tester.tap(find.text('Nueva reservación'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reservar'));
      await tester.pumpAndSettle();
      expect(find.text('Elige la fecha y la hora'), findsOneWidget);
      expect(repo.creadas, isEmpty);
    });

    testWidgets('modificar: el formulario trae los datos y guarda los cambios', (tester) async {
      final repo = await _abrir(
        tester,
        rol: RolUsuario.cliente,
        lista: [reservacionDePrueba(enCuanto: const Duration(days: 2), comensales: 2)],
      );
      await tester.tap(find.byTooltip('Modificar'));
      await tester.pumpAndSettle();
      expect(find.text('Modificar reservación'), findsOneWidget);
      expect(find.textContaining('volverá a quedar pendiente'), findsOneWidget);

      // Un comensal más y guardar.
      await tester.tap(find.byTooltip('Más'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Guardar cambios'));
      await tester.pumpAndSettle();

      expect(repo.modificadas.single.id, 1);
      expect(repo.modificadas.single.comensales, 3);
      expect(find.text('Reservación modificada'), findsOneWidget);
      await _dejarPasarAvisos(tester);
    });
  });
}