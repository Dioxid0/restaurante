import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/errors.dart';

/// Convierte un error de la base en un [ErrorDeNegocio] con un mensaje claro.
/// 23505 = valor repetido, 23503 = el registro se usa en otra tabla, 23514 = dato no válido.
ErrorDeNegocio errorDeBd(PostgrestException e, {String? repetido, String? enUso}) {
  if (e.code == '23505' && repetido != null) return ErrorDeNegocio(repetido);
  if (e.code == '23503' && enUso != null) return ErrorDeNegocio(enUso);
  if (e.code == '23514') return const ErrorDeNegocio('Hay un dato no válido: revisa el formulario');
  if (e.code == '42501') return const ErrorDeNegocio('No tienes permiso para hacer esto');
  return ErrorDeNegocio(e.message);
}
