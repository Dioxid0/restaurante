/// Dominio interno de los correos de empleados: `usuario@restaurante.local`.
const dominioEmpleados = 'restaurante.local';

/// "Juan Pérez" -> "juan.perez".
/// DEBE coincidir con `public.normalizar_usuario()` en la base de datos.
String normalizarUsuario(String texto) {
  const con = 'áéíóúüñÁÉÍÓÚÜÑ';
  const sin = 'aeiouunaeiouun';
  var t = texto.trim();
  for (var i = 0; i < con.length; i++) {
    t = t.replaceAll(con[i], sin[i]);
  }
  t = t.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '.');
  return t.replaceAll(RegExp(r'^\.+|\.+$'), '');
}

/// Correo con el que se autentica quien escribe [identificador] en el login:
/// si ya es un correo se usa tal cual; si no, es un usuario de personal.
String identificadorACorreo(String identificador) {
  final t = identificador.trim();
  if (t.contains('@')) return t.toLowerCase();
  return '${normalizarUsuario(t)}@$dominioEmpleados';
}

bool esCorreoValido(String texto) =>
    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(texto.trim());
