/// Un renglón de la bitácora de auditoría (RNF-04).
class EntradaBitacora {
  const EntradaBitacora({
    required this.id,
    required this.fechaHora,
    required this.tabla,
    required this.accion,
    this.idRegistro,
    this.rol,
    this.empleado,
    this.cambios,
  });

  final int id;
  final DateTime fechaHora;
  final String tabla;
  final String accion; // INSERT | UPDATE | DELETE
  final String? idRegistro;
  final String? rol;
  final String? empleado;

  /// UPDATE: {campo: {antes, despues}}. INSERT/DELETE: la fila completa.
  final Map<String, dynamic>? cambios;

  bool get esCambio => accion == 'UPDATE';

  String get tablaEtiqueta => etiquetaTabla(tabla);

  String get accionEtiqueta => switch (accion) {
        'INSERT' => 'Alta',
        'UPDATE' => 'Cambio',
        'DELETE' => 'Baja',
        _ => accion,
      };

  /// Quién lo hizo: el empleado, un cliente o el sistema (triggers y tareas internas).
  String get quien => empleado ?? (rol == 'cliente' ? 'Cliente' : 'Sistema');

  static const tablas = {
    'pedido': 'Pedidos',
    'detalle_pedido': 'Renglones de pedido',
    'reservacion': 'Reservaciones',
    'solicitud_cambio': 'Solicitudes de cambio',
    'platillo': 'Menú',
    'mesa': 'Mesas',
    'empleado': 'Cuentas de personal',
  };

  static String etiquetaTabla(String tabla) => tablas[tabla] ?? tabla;
}
