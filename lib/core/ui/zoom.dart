import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'zoom.g.dart';

/// Ancho lógico (px) a partir del cual la interfaz se escala sola.
const _anchoBase = 1500.0;

/// Escala automática: en monitores grandes la interfaz crece para no dejar
/// espacio vacío; en ventanas normales se queda en 1.0.
double escalaAutomatica(double anchoVentana) =>
    anchoVentana <= _anchoBase ? 1.0 : (anchoVentana / _anchoBase).clamp(1.0, 2.0);

/// Zoom elegido por el usuario (Ctrl +, Ctrl -, Ctrl 0 o los botones del encabezado).
/// Se recuerda entre sesiones.
@Riverpod(keepAlive: true)
class ZoomUsuario extends _$ZoomUsuario {
  static const minimo = 0.7;
  static const maximo = 2.0;
  static const paso = 0.1;
  static const _clave = 'zoom_interfaz';

  @override
  double build() {
    _cargar();
    return 1.0;
  }

  Future<void> _cargar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final guardado = prefs.getDouble(_clave);
      if (guardado != null) state = guardado.clamp(minimo, maximo);
    } catch (_) {
      // Sin almacenamiento disponible: se usa 1.0.
    }
  }

  void acercar() => _poner(state + paso);
  void alejar() => _poner(state - paso);
  void restablecer() => _poner(1.0);

  void _poner(double valor) {
    state = double.parse(valor.clamp(minimo, maximo).toStringAsFixed(2));
    _guardar();
  }

  Future<void> _guardar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_clave, state);
    } catch (_) {}
  }
}

/// Envuelve la app: aplica escala automática × zoom del usuario y atiende los atajos.
class EscalaInterfaz extends ConsumerWidget {
  const EscalaInterfaz({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zoom = ref.watch(zoomUsuarioProvider);
    final mq = MediaQuery.of(context);
    final factor = escalaAutomatica(mq.size.width) * zoom;
    final zoomNotifier = ref.read(zoomUsuarioProvider.notifier);

    return CallbackShortcuts(
      bindings: {
        for (final tecla in [LogicalKeyboardKey.equal, LogicalKeyboardKey.add, LogicalKeyboardKey.numpadAdd])
          SingleActivator(tecla, control: true): zoomNotifier.acercar,
        for (final tecla in [LogicalKeyboardKey.minus, LogicalKeyboardKey.numpadSubtract])
          SingleActivator(tecla, control: true): zoomNotifier.alejar,
        for (final tecla in [LogicalKeyboardKey.digit0, LogicalKeyboardKey.numpad0])
          SingleActivator(tecla, control: true): zoomNotifier.restablecer,
      },
      child: Focus(
        autofocus: true,
        canRequestFocus: false,
        child: ClipRect(
          child: OverflowBox(
            alignment: Alignment.topLeft,
            minWidth: 0,
            minHeight: 0,
            maxWidth: double.infinity,
            maxHeight: double.infinity,
            child: Transform.scale(
              scale: factor,
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: mq.size.width / factor,
                height: mq.size.height / factor,
                child: MediaQuery(
                  data: mq.copyWith(size: Size(mq.size.width / factor, mq.size.height / factor)),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
