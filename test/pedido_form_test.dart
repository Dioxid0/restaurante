import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:restaurant_app/domain/entities/pedido.dart';
import 'package:restaurant_app/domain/entities/pedido_detalle.dart';
import 'package:restaurant_app/domain/entities/perfil.dart';

import 'helpers/app.dart';
import 'helpers/fakes.dart';

/// Abre el dashboard y entra a "Registrar Nuevo Pedido".
Future<FakePedidoRepository> _abrirNuevo(
  WidgetTester tester, {
  RolUsuario rol = RolUsuario.mesero,
}) async {
  final pedidos = FakePedidoRepository([]);
  await abrirApp(
    tester,
    auth: FakeAuthRepository(sesion: perfilDe(rol)),
    pedidos: pedidos,
    ventana: const Size(1500, 1000),
  );
  if (rol == RolUsuario.cliente) {
    await tester.tap(find.text('Hacer un pedido'));
  } else {
    await tester.tap(find.text('Registrar Nuevo Pedido'));
  }
  await tester.pumpAndSettle();
  return pedidos;
}

/// Agrega el platillo [nombre] (con nota opcional) desde su tarjeta.
Future<void> _agregar(WidgetTester tester, String nombre, {String? nota}) async {
  final tarjeta = find.ancestor(of: find.text(nombre), matching: find.byType(Container)).first;
  final boton = find.descendant(of: find.ancestor(of: find.text(nombre), matching: find.byType(Column)).first, matching: find.text('Agregar al Pedido'));
  expect(tarjeta, findsWidgets);
  if (nota != null) {
    final campo = find.descendant(
      of: find.ancestor(of: find.text(nombre), matching: find.byType(Column)).first,
      matching: find.byType(TextField),
    );
    await tester.enterText(campo.first, nota);
  }
  await tester.ensureVisible(boton.first);
  await tester.tap(boton.first);
  await tester.pumpAndSettle();
}

Future<void> _elegirMesa(WidgetTester tester, String etiqueta) async {
  await tester.tap(find.byType(DropdownButton<int>));
  await tester.pumpAndSettle();
  await tester.tap(find.text(etiqueta).last);
  await tester.pumpAndSettle();
}

/// Deja pasar el tiempo para que los avisos (toast) se cierren solos.
Future<void> _dejarPasarAvisos(WidgetTester tester) => tester.pump(const Duration(seconds: 6));

void main() {
  group('crear pedido (mesero)', () {
    testWidgets('muestra menú, categorías, agotados y el estado vacío', (tester) async {
      await _abrirNuevo(tester);
      expect(find.text('Selecciona los platillos'), findsOneWidget);
      expect(find.text('Agua de Jamaica'), findsOneWidget);
      expect(find.text('Agrega platillos para iniciar la comanda.'), findsOneWidget);
      expect(find.text('3 opciones disponibles'), findsOneWidget);
      // El agotado se muestra, sin botón de agregar.
      expect(find.text('Agotado'), findsOneWidget);
      expect(find.text('Agregar al Pedido'), findsNWidgets(3));
      expect(find.text('No disponible por el momento'), findsOneWidget);
    });

    testWidgets('las pestañas filtran por categoría', (tester) async {
      await _abrirNuevo(tester);
      await tester.tap(find.text('Postres'));
      await tester.pumpAndSettle();
      expect(find.text('Flan de la Abuela'), findsOneWidget);
      expect(find.text('Agua de Jamaica'), findsNothing);
      expect(find.text('1 opciones disponibles'), findsOneWidget);
      await tester.tap(find.text('Todas'));
      await tester.pumpAndSettle();
      expect(find.text('Agua de Jamaica'), findsOneWidget);
    });

    testWidgets('valida mesa y platillo con los mensajes del diseño', (tester) async {
      await _abrirNuevo(tester);
      await tester.tap(find.text('Enviar Comanda a Cocina'));
      await tester.pumpAndSettle();
      expect(find.text('Error: Debe seleccionar una mesa y al menos un platillo'), findsOneWidget);
      await _dejarPasarAvisos(tester);

      await _elegirMesa(tester, 'Mesa 3');
      await tester.tap(find.text('Enviar Comanda a Cocina'));
      await tester.pumpAndSettle();
      expect(find.text('Error: Debe agregar al menos un platillo'), findsOneWidget);
      await _dejarPasarAvisos(tester);
    });

    testWidgets('sin mesa pero con platillo pide la mesa', (tester) async {
      await _abrirNuevo(tester);
      await _agregar(tester, 'Agua de Jamaica');
      await tester.tap(find.text('Enviar Comanda a Cocina'));
      await tester.pumpAndSettle();
      expect(find.text('Error: Debe seleccionar una mesa'), findsOneWidget);
      await _dejarPasarAvisos(tester);
    });

    testWidgets('mismo platillo: misma nota suma; otra nota crea otro renglón; − hasta 0 lo borra', (tester) async {
      await _abrirNuevo(tester);
      await _agregar(tester, 'Enchiladas Verdes', nota: 'Sin tortilla');
      await _agregar(tester, 'Enchiladas Verdes', nota: 'Sin tortilla'); // misma nota => cantidad 2
      await _agregar(tester, 'Enchiladas Verdes'); // sin nota => renglón aparte
      await _agregar(tester, 'Agua de Jamaica');

      expect(tester.widget<Text>(find.byKey(const Key('badge_lineas'))).data, '3'); // 3 renglones
      expect(tester.widget<Text>(find.byKey(const Key('total_comanda'))).data, r'$543.00'); // 2*165 + 165 + 48
      expect(find.text('2x Enchiladas Verdes · Nota:'), findsOneWidget);
      expect(find.text('1x Enchiladas Verdes · Nota:'), findsOneWidget);

      // Quitar el renglón de Agua (1 pieza): − una vez y desaparece.
      final restar = find.byTooltip('Quitar uno');
      await tester.tap(restar.last);
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(find.byKey(const Key('badge_lineas'))).data, '2');
      expect(tester.widget<Text>(find.byKey(const Key('total_comanda'))).data, r'$495.00');
    });

    testWidgets('Para Llevar: aparece "Sin mesa", desactiva el selector y se puede desmarcar', (tester) async {
      await _abrirNuevo(tester);
      expect(find.text('Sin mesa'), findsNothing);

      await tester.tap(find.text('Para Llevar'));
      await tester.pumpAndSettle();
      expect(find.text('Sin mesa'), findsOneWidget);
      expect(find.text('Sin mesa · Para llevar'), findsOneWidget);

      await tester.tap(find.text('Sin mesa'));
      await tester.pumpAndSettle();
      expect(find.text('Mesa no seleccionada · Para llevar'), findsOneWidget);

      // Con mesa elegida, para llevar en una mesa ocupada (pedido "extra").
      await _elegirMesa(tester, 'Mesa 2');
      expect(find.text('Mesa 2 · Para llevar'), findsOneWidget);
    });

    testWidgets('el selector lista las mesas ocupadas y las marca', (tester) async {
      await _abrirNuevo(tester);
      await tester.tap(find.byType(DropdownButton<int>));
      await tester.pumpAndSettle();
      expect(find.text('Mesa 1'), findsOneWidget);
      expect(find.text('Mesa 2'), findsOneWidget);
      expect(find.text('Ocupada'), findsOneWidget);
      await tester.tap(find.text('Mesa 3').last);
      await tester.pumpAndSettle();
    });

    testWidgets('enviar crea el pedido, avisa y regresa al dashboard', (tester) async {
      final repo = await _abrirNuevo(tester);
      await _elegirMesa(tester, 'Mesa 2'); // ocupada => pedido extra
      await _agregar(tester, 'Enchiladas Verdes', nota: 'Sin tortilla');
      await _agregar(tester, 'Agua de Jamaica');

      await tester.tap(find.text('Enviar Comanda a Cocina'));
      await tester.pumpAndSettle();

      expect(repo.creados, hasLength(1));
      final c = repo.creados.single;
      expect(c.tipo, TipoPedido.enMesa);
      expect(c.idMesa, 12);
      expect(c.items.map((i) => (i.idPlatillo, i.cantidad, i.nota)), [(2, 1, 'Sin tortilla'), (1, 1, null)]);
      expect(find.text('¡Comanda enviada a cocina con éxito!'), findsOneWidget);
      expect(find.text('Comandería y Mesas'), findsOneWidget);
      await _dejarPasarAvisos(tester);
    });

    testWidgets('si la base rechaza el pedido muestra el error y se queda en la pantalla', (tester) async {
      final repo = await _abrirNuevo(tester);
      repo.errorAlGuardar = 'El platillo no está disponible';
      await _elegirMesa(tester, 'Mesa 1');
      await _agregar(tester, 'Agua de Jamaica');
      await tester.tap(find.text('Enviar Comanda a Cocina'));
      await tester.pumpAndSettle();
      expect(find.text('Error: El platillo no está disponible'), findsOneWidget);
      expect(find.text('Selecciona los platillos'), findsOneWidget);
      await _dejarPasarAvisos(tester);
    });

    testWidgets('Cancelar / Vaciar pide confirmación y limpia la comanda', (tester) async {
      await _abrirNuevo(tester);
      await _agregar(tester, 'Agua de Jamaica');
      await tester.tap(find.text('Cancelar / Vaciar'));
      await tester.pumpAndSettle();
      expect(find.text('¿Vaciar la comanda?'), findsOneWidget);
      await tester.tap(find.text('Vaciar'));
      await tester.pumpAndSettle();
      expect(find.text('Agrega platillos para iniciar la comanda.'), findsOneWidget);
    });

    testWidgets('Volver con platillos pide confirmación; sin ellos regresa directo', (tester) async {
      await _abrirNuevo(tester);
      await _agregar(tester, 'Agua de Jamaica');
      await tester.tap(find.text('Volver al Dashboard'));
      await tester.pumpAndSettle();
      expect(find.text('¿Descartar los cambios?'), findsOneWidget);
      await tester.tap(find.text('Seguir editando'));
      await tester.pumpAndSettle();
      expect(find.text('Selecciona los platillos'), findsOneWidget);

      await tester.tap(find.text('Cancelar / Vaciar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Vaciar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Volver al Dashboard'));
      await tester.pumpAndSettle();
      expect(find.text('Comandería y Mesas'), findsOneWidget);
    });
  });

  group('editar pedido', () {
    PedidoDetalle detalle({EstadoPedido estado = EstadoPedido.pendiente}) => PedidoDetalle(
          folio: 7,
          folioDia: 108,
          tipo: TipoPedido.enMesa,
          estado: estado,
          idMesa: 11,
          lineas: const [
            LineaPedido(idPlatillo: 2, nombre: 'Enchiladas Verdes', precioUnitario: 165, cantidad: 2, nota: 'Sin tortilla'),
            LineaPedido(idPlatillo: 1, nombre: 'Agua de Jamaica', precioUnitario: 48, cantidad: 1),
          ],
        );

    Future<FakePedidoRepository> abrirEdicion(WidgetTester tester, PedidoDetalle d) async {
      final repo = FakePedidoRepository([pedidoDePrueba(folioDia: 108, estado: d.estado)])
        ..detalleParaEditar = d;
      await abrirApp(
        tester,
        auth: FakeAuthRepository(sesion: perfilDe(RolUsuario.mesero)),
        pedidos: repo,
        ventana: const Size(1500, 1000),
      );
      GoRouter.of(tester.element(find.text('Comandería y Mesas'))).go('/pedido/7/editar');
      await tester.pumpAndSettle();
      return repo;
    }

    testWidgets('carga los renglones y permite guardar cambios', (tester) async {
      final repo = await abrirEdicion(tester, detalle());
      expect(find.text('Guardar Cambios y Notificar a Cocina'), findsOneWidget);
      expect(find.text('Descartar Cambios'), findsOneWidget);
      expect(find.text('Cancelar Pedido'), findsOneWidget);
      expect(find.text('Mesa 1 · Presencial'), findsOneWidget);
      expect(tester.widget<Text>(find.byKey(const Key('total_comanda'))).data, r'$378.00');

      await tester.tap(find.byTooltip('Agregar uno').first); // 3 enchiladas
      await tester.pumpAndSettle();
      await tester.tap(find.text('Guardar Cambios y Notificar a Cocina'));
      await tester.pumpAndSettle();

      final a = repo.actualizados.single;
      expect(a.folio, 7);
      expect(a.idMesa, 11);
      expect(a.items.map((i) => (i.idPlatillo, i.cantidad, i.nota)), [(2, 3, 'Sin tortilla'), (1, 1, null)]);
      expect(find.text('Comandería y Mesas'), findsOneWidget);
      await _dejarPasarAvisos(tester);
    });

    testWidgets('"Cancelar Pedido" exige motivo', (tester) async {
      final repo = await abrirEdicion(tester, detalle());
      await tester.tap(find.text('Cancelar Pedido'));
      await tester.pumpAndSettle();

      // Sin motivo, el botón de confirmar está deshabilitado.
      final confirmar = find.widgetWithText(FilledButton, 'Cancelar pedido');
      expect(tester.widget<FilledButton>(confirmar).onPressed, isNull);

      await tester.enterText(find.byType(TextField).last, 'El cliente se retiró');
      await tester.pumpAndSettle();
      await tester.tap(confirmar);
      await tester.pumpAndSettle();

      expect(repo.cancelados.single, (7, 'El cliente se retiró'));
      expect(find.text('Pedido cancelado'), findsOneWidget);
      await _dejarPasarAvisos(tester);
    });

    testWidgets('un pedido en preparación no se edita desde aquí (RN-03)', (tester) async {
      await abrirEdicion(tester, detalle(estado: EstadoPedido.enPreparacion));
      expect(find.textContaining('ya no puede editarse'), findsOneWidget);
      expect(find.text('Guardar Cambios y Notificar a Cocina'), findsNothing);
    });
  });

  group('pedido en línea (cliente)', () {
    testWidgets('no ve mesa ni tipo; envía un pedido para llevar sin mesa', (tester) async {
      final repo = await _abrirNuevo(tester, rol: RolUsuario.cliente);
      expect(find.text('Seleccionar mesa *'), findsNothing);
      expect(find.text('Presencial'), findsNothing);
      expect(find.text('Pedido para llevar'), findsOneWidget);
      expect(find.text('Enviar Pedido'), findsOneWidget);

      await _agregar(tester, 'Agua de Jamaica');
      await tester.tap(find.text('Enviar Pedido'));
      await tester.pumpAndSettle();

      final c = repo.creados.single;
      expect(c.tipo, TipoPedido.paraLlevar);
      expect(c.idMesa, isNull);
      expect(find.text('¡Pedido enviado con éxito!'), findsOneWidget);
      await _dejarPasarAvisos(tester);
    });
  });

  testWidgets('el chef no puede abrir la pantalla de pedido', (tester) async {
    await abrirApp(tester, auth: FakeAuthRepository(sesion: perfilDe(RolUsuario.chef)));
    GoRouter.of(tester.element(find.text('Comandería y Mesas'))).go('/pedido/nuevo');
    await tester.pumpAndSettle();
    expect(find.text('No tienes acceso a esta sección'), findsOneWidget);
    expect(find.text('Selecciona los platillos'), findsNothing);
  });
}
