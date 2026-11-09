const diasCortos = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];
const mesesCortos = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];

/// "jue 12 nov 2026"
String fechaCorta(DateTime f) =>
    '${diasCortos[f.weekday - 1]} ${f.day} ${mesesCortos[f.month - 1]} ${f.year}';