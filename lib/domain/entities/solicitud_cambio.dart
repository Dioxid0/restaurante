/// Qué pide el mesero sobre un pedido que ya no está pendiente.
enum TipoSolicitud {
  modificar('modificar', 'Modificar'),
  cancelar('cancelar', 'Cancelar');

  const TipoSolicitud(this.valorBd, this.etiqueta);
  final String valorBd;
  final String etiqueta;

  static TipoSolicitud desdeBd(String valor) =>
      TipoSolicitud.values.firstWhere((t) => t.valorBd == valor);
}

enum EstadoSolicitud {
  pendiente('pendiente'),
  aprobada('aprobada'),
  rechazada('rechazada');

  const EstadoSolicitud(this.valorBd);
  final String valorBd;

  static EstadoSolicitud desdeBd(String valor) =>
      EstadoSolicitud.values.firstWhere((e) => e.valorBd == valor);
}

/// Solicitud de cambio (RN-03): el mesero pide modificar o cancelar un pedido que ya está
/// en preparación o listo, y el gerente la aprueba o la rechaza. Al aprobarla se abre una
/// ventana de 10 minutos sobre ese pedido. La base de datos es la que lo exige de verdad.
class SolicitudCambio {
  const SolicitudCambio({
    required this.idSolicitud,
    required this.folio,
    required this.folioDia,
    required this.tipo,
    required this.motivo,
    required this.estado,
    required this.fecha,
    required this.idEmpleadoSolicita,
    this.nombreMesero,
    this.vigenteHasta,
  });

  final int idSolicitud;
  final int folio;
  final int folioDia;
  final TipoSolicitud tipo;
  final String motivo;
  final EstadoSolicitud estado;
  final DateTime fecha;
  final int idEmpleadoSolicita;
  final String? nombreMesero;

  /// Fin de la ventana de autorización (solo si fue aprobada).
  final DateTime? vigenteHasta;

  String get folioEtiqueta => '#PED-${folioDia.toString().padLeft(3, '0')}';

  bool get estaPendiente => estado == EstadoSolicitud.pendiente;

  /// Aprobada y con la ventana de 10 minutos todavía abierta.
  bool estaVigente(DateTime ahora) =>
      estado == EstadoSolicitud.aprobada && vigenteHasta != null && ahora.isBefore(vigenteHasta!);
}
