import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ui/toast.dart';
import '../../core/utils/formato.dart';
import '../../domain/entities/reservacion.dart';
import '../pedidos/pedidos_providers.dart';
import 'reservaciones_providers.dart';

/// Avisa al cliente, con la app abierta y en cualquier pantalla, cuando a una
/// reservación suya le faltan 5 horas o menos. (Es el aviso que pidió el equipo;
/// un correo o mensaje al celular necesitaría un servicio externo.)
///
/// Se coloca alrededor del contenido del marco de la app. Si [activo] es false
/// (el personal), no hace nada ni consulta reservaciones.
class AvisosReservaciones extends ConsumerStatefulWidget {
  const AvisosReservaciones({super.key, required this.activo, required this.child});

  final bool activo;
  final Widget child;

  @override
  ConsumerState<AvisosReservaciones> createState() => _AvisosReservacionesState();
}

class _AvisosReservacionesState extends ConsumerState<AvisosReservaciones> {
  /// Reservaciones que ya se avisaron en esta sesión (para no repetir el aviso).
  final _avisadas = <int>{};

  void _revisar(List<Reservacion> lista, DateTime ahora) {
    final mensajes = <String>[];
    for (final r in lista) {
      if (!r.estado.esActiva || !r.dentroDeLasUltimas5h(ahora)) continue;
      if (!_avisadas.add(r.idReservacion)) continue;
      mensajes.add(_mensaje(r));
    }
    if (mensajes.isEmpty) return;
    // Después del cuadro actual: no se puede mostrar un aviso mientras se construye la pantalla.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) mostrarToast(context, mensajes.join('\n\n'));
    });
  }

  String _mensaje(Reservacion r) {
    final hora = formatoHora(r.inicio);
    if (r.estado == EstadoReservacion.pendiente) {
      return 'No confirmaste a tiempo tu reservación de las $hora: se liberó la mesa. '
          'Si aún la necesitas, llama al restaurante.';
    }
    return 'Faltan menos de 5 horas para tu reservación de las $hora. '
        'Ya no se puede cancelar ni modificar. ¡Te esperamos!';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.activo) {
      ref.listen(reservacionesListaProvider, (_, siguiente) {
        final lista = siguiente.value;
        if (lista == null) return;
        _revisar(lista, ref.read(relojProvider).value ?? DateTime.now());
      });
      // El reloj avanza cada 30 s: así el aviso sale justo cuando se cumplen las 5 horas.
      ref.listen(relojProvider, (_, siguiente) {
        final ahora = siguiente.value;
        final lista = ref.read(reservacionesListaProvider).value;
        if (ahora == null || lista == null) return;
        _revisar(lista, ahora);
      });
    }
    return widget.child;
  }
}
