/// Error de una regla de negocio con un mensaje listo para mostrar al usuario
/// (por ejemplo, el que devuelve la base de datos: "Se requiere el PIN del gerente").
class ErrorDeNegocio implements Exception {
  const ErrorDeNegocio(this.mensaje);
  final String mensaje;

  @override
  String toString() => mensaje;
}

/// Mensaje amigable para cualquier error capturado en la UI.
String mensajeDeError(Object error, {String porDefecto = 'No se pudo completar la acción'}) =>
    error is ErrorDeNegocio ? error.mensaje : porDefecto;
