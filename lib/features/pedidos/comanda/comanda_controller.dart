import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repository_providers.dart';
import '../../../domain/entities/pedido.dart';
import '../../../domain/entities/pedido_detalle.dart';
import '../../../domain/entities/platillo.dart';
import '../../../domain/errors.dart';
import '../pedidos_providers.dart';
import 'comanda_state.dart';

part 'comanda_controller.g.dart';

/// Normaliza una nota: sin espacios sobrantes y "N/A" cuenta como vacía.
String normalizarNota(String nota) {
  final t = nota.trim();
  return t.toUpperCase() == 'N/A' ? '' : t;
}

/// Estado de la pantalla de comanda (crear / editar / pedido del cliente).
/// [esCliente]: el cliente siempre pide "para llevar" y sin mesa.
@riverpod
class ComandaController extends _$ComandaController {
  @override
  ComandaState build({required bool esCliente}) => esCliente
      ? const ComandaState(tipo: TipoPedido.paraLlevar, sinMesa: true)
      : const ComandaState();

  /// Agrega un platillo. Si ya hay un renglón del mismo platillo con la misma
  /// nota, suma una pieza; con otra nota crea un renglón aparte.
  void agregar(Platillo platillo, String nota) {
    final n = normalizarNota(nota);
    final i = state.lineas.indexWhere((l) => l.idPlatillo == platillo.idPlatillo && l.nota == n);
    if (i >= 0) {
      incrementar(state.lineas[i].id);
      return;
    }
    state = state.copyWith(
      lineas: [
        ...state.lineas,
        LineaComanda(
          id: state.siguienteId,
          idPlatillo: platillo.idPlatillo,
          nombre: platillo.nombre,
          precio: platillo.precio,
          cantidad: 1,
          nota: n,
        ),
      ],
      siguienteId: state.siguienteId + 1,
    );
  }

  void incrementar(int idLinea) {
    state = state.copyWith(
      lineas: [
        for (final l in state.lineas)
          if (l.id == idLinea && l.cantidad < maxCantidadPorLinea)
            l.copyWith(cantidad: l.cantidad + 1)
          else
            l,
      ],
    );
  }

  /// Resta una pieza; al llegar a 0 el renglón se elimina.
  void decrementar(int idLinea) {
    state = state.copyWith(
      lineas: [
        for (final l in state.lineas)
          if (l.id != idLinea)
            l
          else if (l.cantidad > 1)
            l.copyWith(cantidad: l.cantidad - 1),
      ],
    );
  }

  void cambiarNota(int idLinea, String nota) {
    state = state.copyWith(
      lineas: [
        for (final l in state.lineas) l.id == idLinea ? l.copyWith(nota: normalizarNota(nota)) : l,
      ],
    );
  }

  void vaciar() => state = state.copyWith(lineas: []);

  void setTipo(TipoPedido tipo) {
    if (esCliente) return;
    // Al pasar a "Para llevar" se propone "Sin mesa" (lo más común).
    state = state.copyWith(tipo: tipo, sinMesa: tipo == TipoPedido.paraLlevar);
  }

  void setMesa(int? idMesa) => state = state.copyWith(idMesa: idMesa);

  void setSinMesa(bool valor) => state = state.copyWith(sinMesa: valor);

  /// Carga un pedido existente para editarlo.
  void cargar(PedidoDetalle detalle) {
    var id = 1;
    final cargado = ComandaState(
      tipo: detalle.tipo,
      idMesa: detalle.idMesa,
      sinMesa: detalle.tipo == TipoPedido.paraLlevar && detalle.idMesa == null,
      lineas: [
        for (final l in detalle.lineas)
          LineaComanda(
            id: id++,
            idPlatillo: l.idPlatillo,
            nombre: l.nombre,
            precio: l.precioUnitario,
            cantidad: l.cantidad,
            nota: normalizarNota(l.nota ?? ''),
          ),
      ],
      siguienteId: detalle.lineas.length + 1,
    );
    state = cargado.copyWith(firmaBase: cargado.firma);
  }

  /// Envía la comanda: crea el pedido (folio == null) o guarda los cambios.
  /// Lanza [ErrorDeNegocio] si falta algo o la base lo rechaza.
  Future<void> enviar({int? folio}) async {
    final error = state.errorDeValidacion(requiereMesa: !esCliente);
    if (error != null) throw ErrorDeNegocio(error);
    if (state.enviando) return;

    final repo = ref.read(pedidoRepositoryProvider);
    final items = [
      for (final l in state.lineas)
        ItemPedido(idPlatillo: l.idPlatillo, cantidad: l.cantidad, nota: l.nota.isEmpty ? null : l.nota),
    ];
    state = state.copyWith(enviando: true);
    try {
      if (folio == null) {
        await repo.crearPedido(tipo: state.tipo, idMesa: state.mesaEfectiva, items: items);
      } else {
        await repo.actualizarPedido(
          folio: folio,
          tipo: state.tipo,
          idMesa: state.mesaEfectiva,
          items: items,
        );
      }
      ref.invalidate(pedidosDelDiaProvider);
    } finally {
      state = state.copyWith(enviando: false);
    }
  }

  Future<void> cancelarPedido(int folio, String motivo) async {
    await ref.read(pedidoRepositoryProvider).cancelarPedido(folio, motivo);
    ref.invalidate(pedidosDelDiaProvider);
  }
}
