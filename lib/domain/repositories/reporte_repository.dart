import '../entities/reporte_gerencial.dart';

/// Reporte gerencial (CU-07). Solo el gerente puede pedirlo: lo valida la base.
abstract interface class ReporteRepository {
  /// Reporte de las fechas operativas de [desde] a [hasta] (ambas incluidas).
  Future<ReporteGerencial> generar(DateTime desde, DateTime hasta);
}
