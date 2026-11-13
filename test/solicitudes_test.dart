import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:restaurant_app/domain/entities/pedido.dart';
import 'package:restaurant_app/domain/entities/pedido_detalle.dart';
import 'package:restaurant_app/domain/entities/perfil.dart';
import 'package:restaurant_app/domain/entities/solicitud_cambio.dart';

import 'helpers/app.dart';
import 'helpers/fakes.dart';
import 'helpers/fakes_solicitudes.dart';

/// Abre la app con [rol] y un pedido en preparación (folio 5) más lo que se indique.
Future<({FakeSolicitudRepository solicitudes, FakePedidoRepository pedidos})> _abrir(
  WidgetTester tester, {
  RolUsuario rol = RolUsuario.mesero,
  List<SolicitudCambio>? solicitudes,
  List<PedidoResumen>? datos,
  PedidoDetalle? detalle,
}) async {
  final repoSol = FakeSolicitudRepository(solicitudes: solicitudes);
  final pedidos = FakePedidoRepository(
    datos ?? [pedidoDePrueba(folioDia: 5, estado: EstadoPedido.enPreparacion)],
  )..detalleParaEditar = detalle;
  await abrirApp(
    tester,
    auth: FakeAuthRepository(sesion: perfilDe(rol)),
    pedidos: pedidos,
    solicitudes: repoSol,
    ventana: const Size(1500, 1000),
  );
  return (solicitudes: repoSol, pedidos: pedidos);
}

/// Deja pasar el aviso flotante (dura 4 s) para que su temporizador termine.
Future<void> _dejarPasarAvisos(WidgetTester tester) => tester.pump(const Duration(seconds: 6));

PedidoDetalle _detalle({EstadoPedido estado = EstadoPedido.enPreparacion}) => PedidoDetalle(
      folio: 5,
      folioDia: 5,
      tipo: TipoPedido.enMesa,
      estado: estado,
      idMesa: 11,
      lineas: const [
        LineaPedido(idPlatillo: 2, nombre: 'Enchiladas Verdes', precioUnitario: 165, cantidad: 2),
      ],
    );

void main() {
  group('mesero', () {
    testWidgets('en preparación o listo ofrece "Solicitar cambio"; pendiente no hace falta', (tester) async {
      await _abrir(tester, datos: [
        pedidoDePrueba(folioDia: 1),
        pedidoDePrueba(folioDia: 2, estado: EstadoPedido.enPreparacion),
        pedidoDePrueba(folioDia: 3, estado: EstadoPedido.listo),
        pedidoDePrueba(folioDia: 4, estado: EstadoPedido.entregado),
      ]);
      expect(find.text('Solicitar cambio'), findsNWidgets(2));
      expect(find.text('Editar'), findsOneWidget); // solo el pendiente
    });

    testWidgets('solicitar: pide el motivo, envía y queda "Solicitud enviada"', (tester) async {
      final r = await _abrir(tester);
      await tester.tap(find.text('Solicitar cambio'));
      await tester.pumpAndSettle();

      final enviar = find.widgetWithText(FilledButton, 'Enviar solicitud');
      expect(tester.widget<FilledButton>(enviar).onPressed, isNull); // sin motivo no se envía

      await tester.tap(find.text('Cancelar'));
      await tester.enterText(find.byType(TextField).last, 'El cliente se fue');
      await tester.pumpAndSettle();
      await tester.tap(enviar);
      await tester.pumpAndSettle();

      expect(r.solicitudes.solicitadas.single, (5, TipoSolicitud.cancelar, 'El cliente se fue'));
      expect(find.text('Solicitud enviada'), findsOneWidget); // la marca en la fila
      expect(find.text('Solicitar cambio'), findsNothing);
      await _dejarPasarAvisos(tester);
    });

    testWidgets('con la solicitud aprobada y vigente aparece "Editar"', (tester) async {
      await _abrir(tester, solicitudes: [
        solicitudDePrueba(folio: 5, estado: EstadoSolicitud.aprobada, vigente: const Duration(minutes: 8)),
      ]);
      expect(find.text('Editar'), findsOneWidget);
      expect(find.text('Solicitar cambio'), findsNothing);
    });

    testWidgets('si la ventana de 10 minutos venció vuelve a pedir autorización', (tester) async {
      await _abrir(tester, solicitudes: [
        solicitudDePrueba(folio: 5, estado: EstadoSolicitud.aprobada, vigente: const Duration(minutes: -1)),
      ]);
      expect(find.text('Editar'), findsNothing);
      expect(find.text('Solicitar cambio'), findsOneWidget);
    });

    testWidgets('si el gerente la rechazó puede volver a solicitar', (tester) async {
      await _abrir(tester, solicitudes: [
        solicitudDePrueba(folio: 5, estado: EstadoSolicitud.rechazada),
      ]);
      expect(find.text('Solicitar cambio'), findsOneWidget);
    });

    testWidgets('sin autorización la pantalla de edición de un pedido en preparación está bloqueada',
        (tester) async {
      await _abrir(tester, detalle: _detalle());
      GoRouter.of(tester.element(find.text('Comandería y Mesas'))).go('/pedido/5/editar');
      await tester.pumpAndSettle();
      expect(find.textContaining('ya no puede editarse'), findsOneWidget);
      expect(find.textContaining('Solicita el cambio al gerente'), findsOneWidget);
    });

    testWidgets('con autorización vigente puede abrir la edición y cancelar', (tester) async {
      final r = await _abrir(
        tester,
        detalle: _detalle(),
        solicitudes: [
          solicitudDePrueba(folio: 5, estado: EstadoSolicitud.aprobada, vigente: const Duration(minutes: 8)),
        ],
      );
      GoRouter.of(tester.element(find.text('Comandería y Mesas'))).go('/pedido/5/editar');
      await tester.pumpAndSettle();
      expect(find.text('Guardar Cambios y Notificar a Cocina'), findsOneWidget);

      await tester.tap(find.text('Cancelar Pedido'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'El cliente se fue');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Cancelar pedido'));
      await tester.pumpAndSettle();
      expect(r.pedidos.cancelados.single, (5, 'El cliente se fue'));
      await _dejarPasarAvisos(tester);
    });

    testWidgets('recibe un aviso cuando el gerente aprueba su solicitud', (tester) async {
      final r = await _abrir(tester, solicitudes: [solicitudDePrueba(folio: 5)]);
      expect(find.text('Solicitud enviada'), findsOneWidget);

      await r.solicitudes.resolver(1, aprobar: true);
      r.solicitudes.emitirCambio();
      await tester.pumpAndSettle();

      expect(find.textContaining('El gerente aprobó tu solicitud del pedido #PED-005'), findsOneWidget);
      expect(find.text('Editar'), findsOneWidget);
      await _dejarPasarAvisos(tester);
    });

    testWidgets('recibe un aviso cuando el gerente rechaza su solicitud', (tester) async {
      final r = await _abrir(tester, solicitudes: [solicitudDePrueba(folio: 5)]);
      await r.solicitudes.resolver(1, aprobar: false);
      r.solicitudes.emitirCambio();
      await tester.pumpAndSettle();
      expect(find.textContaining('El gerente rechazó tu solicitud del pedido #PED-005'), findsOneWidget);
      await _dejarPasarAvisos(tester);
    });

    testWidgets('no ve el panel de solicitudes del gerente', (tester) async {
      await _abrir(tester, solicitudes: [solicitudDePrueba(folio: 5)]);
      expect(find.textContaining('Solicitudes de cambio pendientes'), findsNothing);
    });
  });

  group('gerente', () {
    testWidgets('ve las solicitudes pendientes con el mesero y el motivo', (tester) async {
      await _abrir(tester, rol: RolUsuario.gerente, solicitudes: [
        solicitudDePrueba(id: 1, folio: 5, motivo: 'El cliente se fue'),
        solicitudDePrueba(id: 2, folio: 6, estado: EstadoSolicitud.rechazada),
      ]);
      expect(find.text('Solicitudes de cambio pendientes (1)'), findsOneWidget);
      expect(find.textContaining('Luis Mesero quiere cancelar'), findsOneWidget);
      expect(find.text('«El cliente se fue»'), findsOneWidget);
    });

    testWidgets('sin solicitudes pendientes no aparece el panel', (tester) async {
      await _abrir(tester, rol: RolUsuario.gerente);
      expect(find.textContaining('Solicitudes de cambio pendientes'), findsNothing);
    });

    testWidgets('"Aprobar" aprueba y quita la solicitud del panel', (tester) async {
      final r = await _abrir(tester, rol: RolUsuario.gerente, solicitudes: [solicitudDePrueba(id: 7, folio: 5)]);
      await tester.tap(find.text('Aprobar'));
      await tester.pumpAndSettle();
      expect(r.solicitudes.resueltas.single, (7, true));
      expect(find.textContaining('Solicitudes de cambio pendientes'), findsNothing);
      expect(find.textContaining('tiene 10 minutos'), findsOneWidget);
      await _dejarPasarAvisos(tester);
    });

    testWidgets('"Rechazar" rechaza la solicitud', (tester) async {
      final r = await _abrir(tester, rol: RolUsuario.gerente, solicitudes: [solicitudDePrueba(id: 7, folio: 5)]);
      await tester.tap(find.text('Rechazar'));
      await tester.pumpAndSettle();
      expect(r.solicitudes.resueltas.single, (7, false));
      expect(find.text('Solicitud rechazada'), findsOneWidget);
      await _dejarPasarAvisos(tester);
    });

    testWidgets('recibe un aviso flotante cuando llega una solicitud nueva', (tester) async {
      final r = await _abrir(tester, rol: RolUsuario.gerente);
      r.solicitudes.lista = [solicitudDePrueba(id: 9, folio: 5, idEmpleado: 9)];
      r.solicitudes.emitirCambio();
      await tester.pumpAndSettle();
      expect(find.text('Luis Mesero solicita cancelar el pedido #PED-005.'), findsOneWidget);
      expect(find.text('Solicitudes de cambio pendientes (1)'), findsOneWidget);
      await _dejarPasarAvisos(tester);
    });

    testWidgets('no pide solicitud: edita directo en preparación', (tester) async {
      await _abrir(tester, rol: RolUsuario.gerente);
      expect(find.text('Solicitar cambio'), findsNothing);
      expect(find.text('Editar'), findsOneWidget);
    });
  });

  testWidgets('el chef no ve solicitudes ni botones de cambio', (tester) async {
    await _abrir(tester, rol: RolUsuario.chef, solicitudes: [solicitudDePrueba(folio: 5)]);
    expect(find.text('Solicitar cambio'), findsNothing);
    expect(find.textContaining('Solicitudes de cambio pendientes'), findsNothing);
  });
}
