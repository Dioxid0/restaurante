import 'dart:async';

import 'package:restaurant_app/domain/entities/solicitud_cambio.dart';
import 'package:restaurant_app/domain/repositories/solicitud_repository.dart';

/// Repositorio falso de solicitudes de cambio: en memoria, con tiempo real emulado.
class FakeSolicitudRepository implements SolicitudRepository {
  FakeSolicitudRepository({List<SolicitudCambio>? solicitudes, this.idMesero = 1})
      : lista = solicitudes ?? [];

  List<SolicitudCambio> lista;

  /// Empleado que "hace" las solicitudes nuevas desde la app (el mesero con sesión).
  final int idMesero;

  final solicitadas = <(int, TipoSolicitud, String)>[];
  final resueltas = <(int, bool)>[];
  final _cambios = StreamController<void>.broadcast();

  void emitirCambio() => _cambios.add(null);

  @override
  Future<List<SolicitudCambio>> deHoy() async => List.of(lista);

  @override
  Stream<void> cambios() => _cambios.stream;

  @override
  Future<void> solicitar(int folio, TipoSolicitud tipo, String motivo) async {
    solicitadas.add((folio, tipo, motivo));
    lista = [
      ...lista,
      solicitudDePrueba(
        id: lista.length + 100,
        folio: folio,
        tipo: tipo,
        motivo: motivo,
        idEmpleado: idMesero,
      ),
    ];
  }

  @override
  Future<void> resolver(int idSolicitud, {required bool aprobar}) async {
    resueltas.add((idSolicitud, aprobar));
    lista = [
      for (final s in lista)
        if (s.idSolicitud != idSolicitud)
          s
        else
          SolicitudCambio(
            idSolicitud: s.idSolicitud,
            folio: s.folio,
            folioDia: s.folioDia,
            tipo: s.tipo,
            motivo: s.motivo,
            estado: aprobar ? EstadoSolicitud.aprobada : EstadoSolicitud.rechazada,
            fecha: s.fecha,
            idEmpleadoSolicita: s.idEmpleadoSolicita,
            nombreMesero: s.nombreMesero,
            vigenteHasta: aprobar ? DateTime.now().add(const Duration(minutes: 10)) : null,
          ),
    ];
  }
}

SolicitudCambio solicitudDePrueba({
  int id = 1,
  int folio = 5,
  TipoSolicitud tipo = TipoSolicitud.cancelar,
  String motivo = 'El cliente se fue',
  EstadoSolicitud estado = EstadoSolicitud.pendiente,
  String nombreMesero = 'Luis Mesero',
  int idEmpleado = 1,
  Duration? vigente,
}) =>
    SolicitudCambio(
      idSolicitud: id,
      folio: folio,
      folioDia: folio,
      tipo: tipo,
      motivo: motivo,
      estado: estado,
      fecha: DateTime.now().subtract(const Duration(minutes: 2)),
      idEmpleadoSolicita: idEmpleado,
      nombreMesero: nombreMesero,
      vigenteHasta: vigente == null ? null : DateTime.now().add(vigente),
    );
