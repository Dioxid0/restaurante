import 'dart:async';

import 'package:restaurant_app/domain/entities/cuenta_personal.dart';
import 'package:restaurant_app/domain/entities/pedido.dart';
import 'package:restaurant_app/domain/entities/perfil.dart';
import 'package:restaurant_app/domain/errors.dart';
import 'package:restaurant_app/domain/repositories/auth_repository.dart';
import 'package:restaurant_app/domain/repositories/empleado_repository.dart';
import 'package:restaurant_app/domain/repositories/pedido_repository.dart';

Perfil perfilDe(RolUsuario rol, {String nombre = 'Juan Pérez'}) =>
    Perfil(id: 1, nombre: nombre, rol: rol, usuario: rol.name);

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    Perfil? sesion,
    this.passwordCorrecta = 'secreta',
    this.requiereConfirmarCorreo = false,
  }) : _perfil = sesion;

  Perfil? _perfil;
  final String passwordCorrecta;
  final bool requiereConfirmarCorreo;
  final _cambios = StreamController<bool>.broadcast();

  /// Perfil que se abre al iniciar sesión con la contraseña correcta.
  Perfil perfilAlIngresar = perfilDe(RolUsuario.mesero);

  String? ultimoIdentificador;
  final registros = <({String nombre, String correo, String? telefono, String password})>[];

  @override
  bool get haySesion => _perfil != null;

  @override
  Stream<bool> get cambiosDeSesion => _cambios.stream;

  @override
  Future<Perfil> iniciarSesion({required String identificador, required String password}) async {
    ultimoIdentificador = identificador;
    if (password != passwordCorrecta) {
      throw const AuthFailure('Usuario o contraseña incorrectos');
    }
    _perfil = perfilAlIngresar;
    _cambios.add(true);
    return perfilAlIngresar;
  }

  @override
  Future<bool> registrarCliente({
    required String nombre,
    required String correo,
    required String password,
    String? telefono,
  }) async {
    registros.add((nombre: nombre, correo: correo, telefono: telefono, password: password));
    if (requiereConfirmarCorreo) return false;
    _perfil = Perfil(id: 9, nombre: nombre, rol: RolUsuario.cliente, correo: correo);
    _cambios.add(true);
    return true;
  }

  @override
  Future<Perfil?> perfilActual() async => _perfil;

  @override
  Future<void> cerrarSesion() async {
    _perfil = null;
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

class FakeEmpleadoRepository implements EmpleadoRepository {
  FakeEmpleadoRepository([List<CuentaPersonal>? cuentas]) : cuentas = cuentas ?? [];

  final List<CuentaPersonal> cuentas;
  final creadas = <({String nombre, String usuario, RolUsuario rol, String? pin})>[];

  /// Si no es null, `crear` falla con este mensaje.
  String? errorAlCrear;

  @override
  Future<List<CuentaPersonal>> listar() async => List.of(cuentas);

  @override
  Future<void> crear({
    required String nombre,
    required String usuario,
    required String password,
    required RolUsuario rol,
    String? turno,
    String? pin,
  }) async {
    if (errorAlCrear != null) throw ErrorDeNegocio(errorAlCrear!);
    creadas.add((nombre: nombre, usuario: usuario, rol: rol, pin: pin));
    cuentas.add(CuentaPersonal(
      idEmpleado: 100 + cuentas.length,
      nombre: nombre,
      usuario: usuario,
      rol: rol,
      activo: true,
      turno: turno,
    ));
  }

  @override
  Future<void> cambiarActivo(int idEmpleado, {required bool activo}) async {}
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
