import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/pedido.dart';

part 'comanda_state.freezed.dart';

/// Cantidad máxima de un mismo renglón.
const maxCantidadPorLinea = 20;

/// Renglón de la comanda (un platillo con su nota).
@freezed
abstract class LineaComanda with _$LineaComanda {
  const LineaComanda._();

  const factory LineaComanda({
    /// Identificador local (solo para la UI).
    required int id,
    required int idPlatillo,
    required String nombre,
    required double precio,
    required int cantidad,
    @Default('') String nota,
  }) = _LineaComanda;

  double get subtotal => precio * cantidad;
}

/// Todo lo que el mesero (o el cliente) va armando antes de enviar.
@freezed
abstract class ComandaState with _$ComandaState {
  const ComandaState._();

  const factory ComandaState({
    @Default(TipoPedido.enMesa) TipoPedido tipo,
    int? idMesa,

    /// Solo aplica a "Para llevar": el pedido no se asocia a ninguna mesa.
    @Default(false) bool sinMesa,
    @Default([]) List<LineaComanda> lineas,
    @Default(1) int siguienteId,
    @Default(false) bool enviando,

    /// Firma del pedido tal como se cargó (modo edición). null en modo crear.
    String? firmaBase,
  }) = _ComandaState;

  double get total => lineas.fold(0, (suma, l) => suma + l.subtotal);

  /// El badge del panel cuenta renglones, no piezas.
  int get numeroLineas => lineas.length;

  /// Presencial siempre exige mesa; para llevar, solo si "Sin mesa" no está marcado.
  bool get mesaRequerida => tipo == TipoPedido.enMesa || !sinMesa;

  /// Mesa que realmente se enviará (null si "Sin mesa").
  int? get mesaEfectiva => (tipo == TipoPedido.paraLlevar && sinMesa) ? null : idMesa;

  String get firma =>
      '${tipo.valorBd}|$mesaEfectiva|'
      '${lineas.map((l) => '${l.idPlatillo}x${l.cantidad}:${l.nota.trim()}').join(';')}';

  /// Hay cambios sin enviar (para pedir confirmación al salir).
  bool get modificado => firmaBase == null ? lineas.isNotEmpty : firma != firmaBase;

  /// Mensaje de error si la comanda no se puede enviar (null si está bien).
  /// [requiereMesa] es false para el cliente (siempre es para llevar, sin mesa).
  String? errorDeValidacion({required bool requiereMesa}) {
    final faltaMesa = requiereMesa && mesaRequerida && idMesa == null;
    final faltaPlatillo = lineas.isEmpty;
    if (faltaMesa && faltaPlatillo) return 'Debe seleccionar una mesa y al menos un platillo';
    if (faltaMesa) return 'Debe seleccionar una mesa';
    if (faltaPlatillo) return 'Debe agregar al menos un platillo';
    return null;
  }
}
