import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repository_providers.dart';
import '../../domain/entities/reporte_gerencial.dart';

part 'reporte_providers.g.dart';

/// Periodos rápidos del reporte gerencial (fechas operativas, según el reloj del equipo).
enum PeriodoReporte {
  hoy('Hoy'),
  ayer('Ayer'),
  ultimos7('Últimos 7 días'),
  ultimos30('Últimos 30 días');

  const PeriodoReporte(this.etiqueta);
  final String etiqueta;

  ({DateTime desde, DateTime hasta}) rango(DateTime ahora) {
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    return switch (this) {
      PeriodoReporte.hoy => (desde: hoy, hasta: hoy),
      PeriodoReporte.ayer => (
          desde: hoy.subtract(const Duration(days: 1)),
          hasta: hoy.subtract(const Duration(days: 1)),
        ),
      PeriodoReporte.ultimos7 => (desde: hoy.subtract(const Duration(days: 6)), hasta: hoy),
      PeriodoReporte.ultimos30 => (desde: hoy.subtract(const Duration(days: 29)), hasta: hoy),
    };
  }
}

@riverpod
class PeriodoSeleccionado extends _$PeriodoSeleccionado {
  @override
  PeriodoReporte build() => PeriodoReporte.hoy;

  void elegir(PeriodoReporte periodo) => state = periodo;
}

/// Reporte del periodo elegido. `ref.invalidate(reporteGerencialProvider)` lo recalcula.
@riverpod
Future<ReporteGerencial> reporteGerencial(Ref ref) {
  final periodo = ref.watch(periodoSeleccionadoProvider);
  final rango = periodo.rango(DateTime.now());
  return ref.watch(reporteRepositoryProvider).generar(rango.desde, rango.hasta);
}
