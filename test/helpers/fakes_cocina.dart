import 'dart:async';

import 'package:restaurant_app/domain/entities/cocina.dart';
import 'package:restaurant_app/domain/entities/pedido.dart';
import 'package:restaurant_app/domain/repositories/cocina_repository.dart';

/// Repositorio falso de cocina: guarda en memoria y deja emular el tiempo real con [emitirCambio].
class FakeCocinaRepository implements CocinaRepository {
  FakeCocinaRepository({List<PedidoCocina>? pedidos, List<AvisoCocina>? avisos})
      : pedidos_ = pedidos ?? [],
        avisos_ = avisos ?? [];

  List<PedidoCocina> pedidos_;
  List<AvisoCocina> avisos_;

  final atendidos = <int>[];
  var atendidosTodos = false;
  final _cambios = StreamController<void>.broadcast();

  /// Simula que la base avisó de un cambio (Realtime).
  void emitirCambio() => _cambios.add(null);

  @override
  Future<List<PedidoCocina>> pedidos() async => List.of(pedidos_);

  @override
  Future<List<AvisoCocina>> avisosPendientes() async => List.of(avisos_);

  @override
  Stream<void> cambios() => _cambios.stream;

  @override
  Future<void> marcarAtendido(int idNotificacion) async {
    atendidos.add(idNotificacion);
    avisos_ = [for (final a in avisos_) if (a.idNotificacion != idNotificacion) a];
  }

  @override
  Future<void> marcarTodosAtendidos() async {
    atendidosTodos = true;
    avisos_ = [];
  }
}

PedidoCocina pedidoCocinaDePrueba({
  required int folioDia,
  EstadoPedido estado = EstadoPedido.pendiente,
  TipoPedido tipo = TipoPedido.enMesa,
  int? mesa = 1,
  int minutos = 8,
  List<RenglonCocina>? renglones,
}) =>
    PedidoCocina(
      folio: folioDia,
      folioDia: folioDia,
      horaIngreso: DateTime.now().subtract(Duration(minutes: minutos)),
      tipo: tipo,
      estado: estado,
      esEnLinea: false,
      numeroMesa: tipo == TipoPedido.enMesa ? mesa : null,
      renglones: renglones ??
          const [
            RenglonCocina(nombre: 'Enchiladas Verdes', cantidad: 2, nota: 'Sin cebolla'),
            RenglonCocina(nombre: 'Agua de Jamaica', cantidad: 1),
          ],
    );

AvisoCocina avisoDePrueba({
  int id = 1,
  int folioDia = 1,
  TipoAviso tipo = TipoAviso.nuevo,
  String? mensaje,
}) =>
    AvisoCocina(
      idNotificacion: id,
      hora: DateTime.now(),
      mensaje: mensaje ?? 'Pedido #$folioDia ${tipo.valorBd}',
      tipo: tipo,
      folio: folioDia,
    );
