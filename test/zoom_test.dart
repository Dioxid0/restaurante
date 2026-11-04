import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/core/ui/zoom.dart';
import 'package:restaurant_app/domain/entities/perfil.dart';
import 'package:restaurant_app/core/utils/usuario.dart';

import 'helpers/app.dart';
import 'helpers/fakes.dart';

void main() {
  test('escala automática: 1.0 hasta 1500 px y crece en pantallas grandes (máx. 2.0)', () {
    expect(escalaAutomatica(1280), 1.0);
    expect(escalaAutomatica(1500), 1.0);
    expect(escalaAutomatica(2560), closeTo(1.71, 0.01));
    expect(escalaAutomatica(6000), 2.0);
  });

  test('normalizarUsuario e identificadorACorreo', () {
    expect(normalizarUsuario('Juan Pérez'), 'juan.perez');
    expect(normalizarUsuario('  MARÍA  José '), 'maria.jose');
    expect(normalizarUsuario('Ñandú_01'), 'nandu.01');
    expect(identificadorACorreo('Juan Perez'), 'juan.perez@restaurante.local');
    expect(identificadorACorreo(' Ana@Correo.COM '), 'ana@correo.com');
  });

  testWidgets('Ctrl + y Ctrl − cambian el zoom; Ctrl 0 lo restablece', (tester) async {
    await abrirApp(tester, auth: FakeAuthRepository(sesion: perfilDe(RolUsuario.mesero)));
    expect(find.text('100%'), findsOneWidget);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.equal);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    expect(find.text('110%'), findsOneWidget);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit0);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    expect(find.text('100%'), findsOneWidget);
  });

  testWidgets('los botones − y + del encabezado cambian el zoom', (tester) async {
    await abrirApp(tester, auth: FakeAuthRepository(sesion: perfilDe(RolUsuario.mesero)));
    await tester.tap(find.byTooltip('Acercar (Ctrl +)'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Acercar (Ctrl +)'));
    await tester.pumpAndSettle();
    expect(find.text('120%'), findsOneWidget);
    await tester.tap(find.byTooltip('Alejar (Ctrl −)'));
    await tester.pumpAndSettle();
    expect(find.text('110%'), findsOneWidget);
  });
}
