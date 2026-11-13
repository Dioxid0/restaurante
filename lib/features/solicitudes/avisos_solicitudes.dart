import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ui/toast.dart';
import '../../domain/entities/perfil.dart';
import '../../domain/entities/solicitud_cambio.dart';
import 'solicitudes_providers.dart';

/// Avisos flotantes de las solicitudes de cambio (RN-03), en cualquier pestaña:
///  * gerente: llegó una solicitud nueva;
///  * mesero: el gerente respondió una solicitud suya (con los 10 minutos si la aprobó).
/// Solo actúa para esos dos roles; el resto no consulta nada.
class AvisosSolicitudes extends ConsumerStatefulWidget {
  const AvisosSolicitudes({
    super.key,
    required this.rol,
    required this.idEmpleado,
    required this.child,
  });

  final RolUsuario rol;
  final int idEmpleado;
  final Widget child;

  @override
  ConsumerState<AvisosSolicitudes> createState() => _AvisosSolicitudesState();
}

class _AvisosSolicitudesState extends ConsumerState<AvisosSolicitudes> {
  /// Estado de cada solicitud la última vez que se revisó (null = todavía no se carga).
  Map<int, EstadoSolicitud>? _previos;

  bool get _activo => widget.rol == RolUsuario.gerente || widget.rol == RolUsuario.mesero;

  void _revisar(List<SolicitudCambio> lista) {
    final previos = _previos;
    _previos = {for (final s in lista) s.idSolicitud: s.estado};
    if (previos == null) return; // primera carga: no se avisa de lo que ya estaba

    final mensajes = <String>[];
    for (final s in lista) {
      final antes = previos[s.idSolicitud];
      if (widget.rol == RolUsuario.gerente) {
        if (antes == null && s.estaPendiente) {
          final verbo = s.tipo == TipoSolicitud.cancelar ? 'cancelar' : 'modificar';
          mensajes.add('${s.nombreMesero ?? 'Un mesero'} solicita $verbo el pedido ${s.folioEtiqueta}.');
        }
      } else if (s.idEmpleadoSolicita == widget.idEmpleado &&
          antes == EstadoSolicitud.pendiente &&
          !s.estaPendiente) {
        if (s.estado == EstadoSolicitud.aprobada) {
          final verbo = s.tipo == TipoSolicitud.cancelar ? 'cancelarlo' : 'modificarlo';
          mensajes.add('El gerente aprobó tu solicitud del pedido ${s.folioEtiqueta}: tienes 10 minutos para $verbo.');
        } else {
          mensajes.add('El gerente rechazó tu solicitud del pedido ${s.folioEtiqueta}.');
        }
      }
    }
    if (mensajes.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) mostrarToast(context, mensajes.join('\n'));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_activo) {
      ref.listen(solicitudesDeHoyProvider, (_, siguiente) {
        final lista = siguiente.value;
        if (lista != null) _revisar(lista);
      });
    }
    return widget.child;
  }
}
