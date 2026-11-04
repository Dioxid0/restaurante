/// Dinero con separador de miles: 1234.5 -> $1,234.50
String formatoMoneda(double valor) {
  final partes = valor.toStringAsFixed(2).split('.');
  final enteros = partes[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return '\$$enteros.${partes[1]}';
}

/// Los precios ya incluyen IVA (16 %): separa el total en subtotal e IVA.
/// 313.00 -> (269.83, 43.17)
({double subtotal, double iva}) desgloseIva(double totalConIva, {double tasa = 0.16}) {
  final subtotal = double.parse((totalConIva / (1 + tasa)).toStringAsFixed(2));
  final iva = double.parse((totalConIva - subtotal).toStringAsFixed(2));
  return (subtotal: subtotal, iva: iva);
}

/// 14:05
String formatoHora(DateTime fecha) =>
    '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';

/// "Juan Pérez" -> "JP"
String iniciales(String nombre) {
  final palabras = nombre.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  return palabras.take(2).map((p) => p[0].toUpperCase()).join();
}
