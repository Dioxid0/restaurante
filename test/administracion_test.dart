import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/domain/entities/cuenta_personal.dart';
import 'package:restaurant_app/domain/entities/entrada_bitacora.dart';
import 'package:restaurant_app/domain/entities/perfil.dart';

import 'helpers/app.dart';
import 'helpers/fakes.dart';
import 'helpers/fakes_bitacora.dart';

/// Abre Gerencia como gerente y entra a la sección [seccion] (Menú, Mesas, Cuentas, Bitácora).
Future<void> _abrir(
  WidgetTester tester,
  String seccion, {
  FakeMenuRepository? menu,
  FakeMesaRepository? mesas,
  FakeEmpleadoRepository? empleados,
  FakeBitacoraRepository? bitacora,
}) async {
  await abrirApp(
    tester,
    auth: FakeAuthRepository(sesion: perfilDe(RolUsuario.gerente, nombre: 'Gerente')),
    menu: menu,
    mesas: mesas,
    empleados: empleados,
    bitacora: bitacora,
  );
  await tester.tap(find.text('Gerencia'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(seccion));
  await tester.pumpAndSettle();
}

Finder _enDialogo(String texto) =>
    find.descendant(of: find.byType(AlertDialog), matching: find.text(texto));

void main() {
  group('Menú', () {
    testWidgets('lista los platillos con su precio y disponibilidad', (tester) async {
      await _abrir(tester, 'Menú');
      expect(find.text('Enchiladas Verdes'), findsOneWidget);
      expect(find.text('\$165.00'), findsOneWidget);
      expect(find.byType(Switch), findsNWidgets(4));
    });

    testWidgets('crear platillo: valida y guarda', (tester) async {
      final menu = FakeMenuRepository();
      await _abrir(tester, 'Menú', menu: menu);
      await tester.tap(find.text('Nuevo platillo'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect(find.text('Indica el nombre'), findsOneWidget);
      expect(find.text('Indica un precio válido'), findsOneWidget);
      expect(menu.platillos_, hasLength(4));

      final campos = find.byType(TextFormField);
      await tester.enterText(campos.at(0), 'Pozole');
      await tester.enterText(campos.at(1), '120');
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(menu.platillos_.last.nombre, 'Pozole');
      expect(menu.platillos_.last.precio, 120);
      expect(menu.platillos_.last.disponible, isTrue);
      expect(find.text('Platillo creado'), findsOneWidget);
      expect(find.text('Pozole'), findsOneWidget); // ya aparece en la lista
    });

    testWidgets('si la base rechaza el platillo, el mensaje sale en el formulario', (tester) async {
      final menu = FakeMenuRepository()..error = 'Ya existe un platillo con ese nombre';
      await _abrir(tester, 'Menú', menu: menu);
      await tester.tap(find.text('Nuevo platillo'));
      await tester.pumpAndSettle();
      final campos = find.byType(TextFormField);
      await tester.enterText(campos.at(0), 'Flan de la Abuela');
      await tester.enterText(campos.at(1), '90');
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(find.text('Ya existe un platillo con ese nombre'), findsOneWidget);
      expect(find.text('Nuevo platillo'), findsWidgets); // el diálogo sigue abierto
    });

    testWidgets('editar el precio de un platillo', (tester) async {
      final menu = FakeMenuRepository();
      await _abrir(tester, 'Menú', menu: menu);
      await tester.tap(find.text('Editar').first);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(1), '55');
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(menu.platillos_.first.nombre, 'Agua de Jamaica');
      expect(menu.platillos_.first.precio, 55);
      expect(find.text('Platillo actualizado'), findsOneWidget);
    });

    testWidgets('el interruptor marca un platillo como agotado', (tester) async {
      final menu = FakeMenuRepository();
      await _abrir(tester, 'Menú', menu: menu);
      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();
      expect(menu.platillos_.first.disponible, isFalse);
    });

    testWidgets('eliminar pide confirmación y borra el platillo', (tester) async {
      final menu = FakeMenuRepository();
      await _abrir(tester, 'Menú', menu: menu);
      await tester.tap(find.text('Eliminar').first);
      await tester.pumpAndSettle();
      expect(find.textContaining('Agua de Jamaica'), findsWidgets);

      await tester.tap(_enDialogo('Cancelar'));
      await tester.pumpAndSettle();
      expect(menu.platillos_, hasLength(4)); // cancelar no borra

      await tester.tap(find.text('Eliminar').first);
      await tester.pumpAndSettle();
      await tester.tap(_enDialogo('Eliminar'));
      await tester.pumpAndSettle();
      expect(menu.platillos_, hasLength(3));
      expect(menu.platillos_.any((p) => p.nombre == 'Agua de Jamaica'), isFalse);
    });

    testWidgets('si el platillo ya se pidió, la base lo rechaza y se avisa', (tester) async {
      final menu = FakeMenuRepository()
        ..error = 'Este platillo ya aparece en pedidos y no se puede borrar: márcalo como no disponible';
      await _abrir(tester, 'Menú', menu: menu);
      await tester.tap(find.text('Eliminar').first);
      await tester.pumpAndSettle();
      await tester.tap(_enDialogo('Eliminar'));
      await tester.pumpAndSettle();
      expect(find.textContaining('no se puede borrar'), findsOneWidget);
      expect(menu.platillos_, hasLength(4));
    });
  });

  group('Mesas', () {
    testWidgets('lista las mesas con su capacidad y estado', (tester) async {
      await _abrir(tester, 'Mesas');
      expect(find.text('Mesa 1'), findsOneWidget);
      expect(find.text('2 personas'), findsOneWidget);
      expect(find.text('Ocupada'), findsOneWidget);
    });

    testWidgets('crear mesa: valida y guarda', (tester) async {
      final mesas = FakeMesaRepository();
      await _abrir(tester, 'Mesas', mesas: mesas);
      await tester.tap(find.text('Nueva mesa'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect(find.text('Indica el número (mínimo 1)'), findsOneWidget);
      expect(mesas.mesas_, hasLength(3));

      final campos = find.byType(TextFormField);
      await tester.enterText(campos.at(0), '9');
      await tester.enterText(campos.at(1), '6');
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(mesas.mesas_.last.numeroMesa, 9);
      expect(mesas.mesas_.last.capacidad, 6);
      expect(find.text('Mesa creada'), findsOneWidget);
      expect(find.text('Mesa 9'), findsOneWidget);
    });

    testWidgets('número repetido: el mensaje de la base sale en el formulario', (tester) async {
      final mesas = FakeMesaRepository()..error = 'Ya existe una mesa con ese número';
      await _abrir(tester, 'Mesas', mesas: mesas);
      await tester.tap(find.text('Nueva mesa'));
      await tester.pumpAndSettle();
      final campos = find.byType(TextFormField);
      await tester.enterText(campos.at(0), '1');
      await tester.enterText(campos.at(1), '4');
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect(find.text('Ya existe una mesa con ese número'), findsOneWidget);
    });

    testWidgets('editar la capacidad y eliminar una mesa', (tester) async {
      final mesas = FakeMesaRepository();
      await _abrir(tester, 'Mesas', mesas: mesas);

      await tester.tap(find.text('Editar').first);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(1), '8');
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect(mesas.mesas_.first.capacidad, 8);

      await tester.tap(find.text('Eliminar').first);
      await tester.pumpAndSettle();
      await tester.tap(_enDialogo('Eliminar'));
      await tester.pumpAndSettle();
      expect(mesas.mesas_, hasLength(2));
    });
  });

  group('Cuentas: editar', () {
    FakeEmpleadoRepository empleados() => FakeEmpleadoRepository([
          const CuentaPersonal(
            idEmpleado: 50,
            nombre: 'Luis Mesero',
            usuario: 'luis',
            rol: RolUsuario.mesero,
            activo: true,
            turno: 'matutino',
          ),
        ]);

    testWidgets('cambia nombre y rol', (tester) async {
      final repo = empleados();
      await _abrir(tester, 'Cuentas', empleados: repo);
      await tester.tap(find.text('Editar'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'Luis Ramírez');
      await tester.tap(find.byType(DropdownButtonFormField<RolUsuario>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Chef').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(repo.editadas.single.id, 50);
      expect(repo.editadas.single.nombre, 'Luis Ramírez');
      expect(repo.editadas.single.rol, RolUsuario.chef);
      expect(repo.editadas.single.turno, 'matutino');
      expect(find.text('Cuenta actualizada'), findsOneWidget);
      expect(find.text('Luis Ramírez'), findsOneWidget);
    });

    testWidgets('si la base lo rechaza, el mensaje sale en el formulario', (tester) async {
      final repo = empleados()..errorAlEditar = 'Debe quedar al menos un gerente activo';
      await _abrir(tester, 'Cuentas', empleados: repo);
      await tester.tap(find.text('Editar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect(find.text('Debe quedar al menos un gerente activo'), findsOneWidget);
    });

    testWidgets('en tu propia cuenta el rol no se puede cambiar', (tester) async {
      // perfilDe() tiene id 1: es la cuenta con sesión.
      final repo = FakeEmpleadoRepository([
        const CuentaPersonal(
          idEmpleado: 1,
          nombre: 'Gerente',
          usuario: 'gerente',
          rol: RolUsuario.gerente,
          activo: true,
        ),
      ]);
      await _abrir(tester, 'Cuentas', empleados: repo);
      await tester.tap(find.text('Editar'));
      await tester.pumpAndSettle();
      expect(find.text('No puedes cambiar tu rol'), findsOneWidget);
    });
  });

  group('Bitácora', () {
    testWidgets('lista las entradas y muestra el detalle del cambio', (tester) async {
      final bitacora = FakeBitacoraRepository([
        entradaDePrueba(id: 7, tabla: 'pedido'),
        entradaDePrueba(id: 8, tabla: 'platillo', accion: 'INSERT', empleado: null, rol: 'cliente'),
      ]);
      await _abrir(tester, 'Bitácora', bitacora: bitacora);

      expect(find.text('Bitácora de auditoría'), findsOneWidget);
      expect(find.text('Juan Pérez'), findsOneWidget);
      expect(find.text('Cliente'), findsOneWidget); // sin empleado, rol cliente
      expect(find.text('Cambio'), findsOneWidget);
      expect(find.text('Alta'), findsOneWidget);

      await tester.tap(find.text('Ver').first);
      await tester.pumpAndSettle();
      expect(find.text('estado: pendiente → en_preparacion'), findsOneWidget);
    });

    testWidgets('el filtro pide solo esa sección', (tester) async {
      final bitacora = FakeBitacoraRepository([
        entradaDePrueba(id: 7, tabla: 'pedido'),
        entradaDePrueba(id: 8, tabla: 'platillo', accion: 'INSERT'),
      ]);
      await _abrir(tester, 'Bitácora', bitacora: bitacora);
      expect(bitacora.filtros.last, isNull);

      await tester.tap(find.byType(DropdownButtonFormField<String?>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Menú').last);
      await tester.pumpAndSettle();

      expect(bitacora.filtros.last, 'platillo');
      expect(find.text('Alta'), findsOneWidget);
      expect(find.text('Cambio'), findsNothing);
    });

    testWidgets('sin registros muestra un aviso', (tester) async {
      await _abrir(tester, 'Bitácora');
      expect(find.text('No hay registros'), findsOneWidget);
    });

    test('etiquetas de sección y acción', () {
      expect(EntradaBitacora.etiquetaTabla('mesa'), 'Mesas');
      expect(EntradaBitacora.etiquetaTabla('otra'), 'otra');
      expect(entradaDePrueba(accion: 'DELETE').accionEtiqueta, 'Baja');
      expect(entradaDePrueba(empleado: null, rol: null).quien, 'Sistema');
    });
  });
}
