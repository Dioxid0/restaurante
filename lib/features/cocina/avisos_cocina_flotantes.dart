import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ui/toast.dart';
import '../../domain/entities/cocina.dart';
import 'cocina_providers.dart';

/// Muestra el aviso flotante cuando llega un aviso de cocina nuevo (nuevo, modificado o
/// cancelado), **en cualquier pestaña** y no solo en "Cocina" (CU-06).
///
/// Se coloca alrededor del contenido del marco de la app. Si [activo] es false (todos menos el
/// chef), no hace nada ni consulta avisos.
class AvisosCocinaFlotantes extends ConsumerStatefulWidget {
  const AvisosCocinaFlotantes({super.key, required this.activo, required this.child});

  final bool activo;
  final Widget child;

  @override
  ConsumerState<AvisosCocinaFlotantes> createState() => _AvisosCocinaFlotantesState();
}

class _AvisosCocinaFlotantesState extends ConsumerState<AvisosCocinaFlotantes> {
  /// Avisos ya vistos en esta sesión: solo los nuevos disparan el aviso flotante.
  Set<int>? _vistos;

  void _avisarNuevos(List<AvisoCocina> lista) {
    final ids = lista.map((a) => a.idNotificacion).toSet();
    final anteriores = _vistos;
    _vistos = ids;
    if (anteriores == null) return; // primera carga: no se avisa de lo que ya estaba
    final nuevos = lista.where((a) => !anteriores.contains(a.idNotificacion)).toList();
    if (nuevos.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) mostrarToast(context, nuevos.map((a) => a.mensaje).join('\n'));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.activo) {
      ref.listen(avisosCocinaProvider, (_, siguiente) {
        final lista = siguiente.value;
        if (lista != null) _avisarNuevos(lista);
      });
    }
    return widget.child;
  }
}
