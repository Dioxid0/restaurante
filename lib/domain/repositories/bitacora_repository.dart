import '../entities/entrada_bitacora.dart';

/// Bitácora de auditoría: solo la lee el gerente (lo valida la base).
abstract interface class BitacoraRepository {
  /// Las [limite] entradas más recientes, de [tabla] o de todas si es null.
  Future<List<EntradaBitacora>> recientes({String? tabla, int limite = 100});
}
