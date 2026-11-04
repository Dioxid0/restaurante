/// Dinero con separador de miles: 1234.5 -> $1,234.50
String formatoMoneda(double valor) {
  final partes = valor.toStringAsFixed(2).split('.');
  final enteros = partes[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return '\$$enteros.${partes[1]}';
}

/// 14:05
String formatoHora(DateTime fecha) =>
    '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';

/// "Juan Pérez" -> "JP"
String iniciales(String nombre) {
  final palabras = nombre.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  return palabras.take(2).map((p) => p[0].toUpperCase()).join();
}
