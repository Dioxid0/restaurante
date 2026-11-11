const diasCortos = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];
const mesesCortos = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];

/// "jue 12 nov 2026"
String fechaCorta(DateTime f) =>
    '${diasCortos[f.weekday - 1]} ${f.day} ${mesesCortos[f.month - 1]} ${f.year}';

/// "hoy a las 14:00" o "el jue 12 nov a las 14:00" (para decir hasta cuándo confirmar).
String cuando(DateTime d, DateTime ahora) {
  final hora = '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  final esHoy = d.year == ahora.year && d.month == ahora.month && d.day == ahora.day;
  return esHoy
      ? 'hoy a las $hora'
      : 'el ${diasCortos[d.weekday - 1]} ${d.day} ${mesesCortos[d.month - 1]} a las $hora';
}
