import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repository_providers.dart';
import '../../domain/entities/solicitud_cambio.dart';

part 'solicitudes_providers.g.dart';

/// Solicitudes de cambio de los pedidos de hoy (RN-03). Solo las ven el mesero y el
/// gerente (la base no entrega nada a los demás). Se actualiza sola por Realtime.
@riverpod
class SolicitudesDeHoy extends _$SolicitudesDeHoy {
  @override
  Future<List<SolicitudCambio>> build() async {
    final repo = ref.watch(solicitudRepositoryProvider);
    final sub = repo.cambios().listen((_) => ref.invalidateSelf());
    ref.onDispose(sub.cancel);
    return repo.deHoy();
  }

  /// Mesero: pide modificar o cancelar un pedido que ya no está pendiente.
  Future<void> solicitar(int folio, TipoSolicitud tipo, String motivo) async {
    await ref.read(solicitudRepositoryProvider).solicitar(folio, tipo, motivo);
    ref.invalidateSelf();
  }

  /// Gerente: aprueba (abre 10 minutos de autorización) o rechaza.
  Future<void> resolver(int idSolicitud, {required bool aprobar}) async {
    await ref.read(solicitudRepositoryProvider).resolver(idSolicitud, aprobar: aprobar);
    ref.invalidateSelf();
  }
}

/// La solicitud más reciente de cada pedido (la lista llega de la más antigua a la más nueva).
Map<int, SolicitudCambio> ultimaSolicitudPorFolio(List<SolicitudCambio> lista) =>
    {for (final s in lista) s.folio: s};
