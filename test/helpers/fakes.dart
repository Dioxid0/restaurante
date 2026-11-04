import 'dart:async';

import 'package:restaurant_app/domain/entities/empleado.dart';
import 'package:restaurant_app/domain/entities/pedido.dart';
import 'package:restaurant_app/domain/repositories/auth_repository.dart';
import 'package:restaurant_app/domain/repositories/pedido_repository.dart';

const empleadoMesero = Empleado(
  idEmpleado: 1,
  nombre: 'Juan Pérez',
  rol: RolEmpleado.mesero,
  usuario: 'mesero',
);

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.conSesion = false, this.passwordCorrecta = 'secreta'});

  bool conSesion;
  final String passwordCorrecta;
  final _cambios = StreamController<bool>.broadcast();
  String? ultimoUsuario;

  @override
  bool get haySesion => conSesion;

  @override
  Stream<bool> get cambiosDeSesion => _cambios.stream;

  @override
  Future<Empleado> iniciarSesion({required String usuario, required String password}) async {
    ultimoUsuario = usuario;
    if (password != passwordCorrecta) {
      throw const AuthFailure('Usuario o contraseña incorrectos');
    }
    conSesion = true;
    _cambios.add(true);
    return empleadoMesero;
  }

  @override
  Future<Empleado?> empleadoActual() async => conSesion ? empleadoMesero : null;

  @override
  Future<void> cerrarSesion() async {
    conSesion = false;
    _cambios.add(false);
  }
}

class FakePedidoRepository implements PedidoRepository {
  FakePedidoRepository(this.pedidos);

  List<PedidoResumen> pedidos;
  final cambiosEstado = <(int, EstadoPedido)>[];

  @override
  Future<List<PedidoResumen>> pedidosDelDia() async => pedidos;

  @override
  Stream<void> cambios() => const Stream.empty();

  @override
  Future<void> actualizarEstado(int folio, EstadoPedido nuevoEstado) async {
    cambiosEstado.add((folio, nuevoEstado));
  }
}

PedidoResumen pedidoDePrueba({
  required int folioDia,
  EstadoPedido estado = EstadoPedido.pendiente,
  TipoPedido tipo = TipoPedido.enMesa,
  int? mesa = 1,
  String mesero = 'Juan Pérez',
  double total = 100,
}) =>
    PedidoResumen(
      folio: folioDia,
      folioDia: folioDia,
      horaIngreso: DateTime.now().subtract(const Duration(minutes: 12)),
      tipo: tipo,
      estado: estado,
      total: total,
      esEnLinea: false,
      numeroMesa: tipo == TipoPedido.enMesa ? mesa : null,
      nombreMesero: mesero,
    );
