import 'dart:async';

import 'package:restaurant_app/domain/entities/cuenta_personal.dart';
import 'package:restaurant_app/domain/entities/mesa.dart';
import 'package:restaurant_app/domain/entities/pedido.dart';
import 'package:restaurant_app/domain/entities/pedido_detalle.dart';
import 'package:restaurant_app/domain/entities/perfil.dart';
import 'package:restaurant_app/domain/entities/platillo.dart';
import 'package:restaurant_app/domain/errors.dart';
import 'package:restaurant_app/domain/repositories/auth_repository.dart';
import 'package:restaurant_app/domain/repositories/empleado_repository.dart';
import 'package:restaurant_app/domain/repositories/menu_repository.dart';
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

class FakeMenuRepository implements MenuRepository {
  FakeMenuRepository([List<Platillo>? platillos]) : platillos_ = platillos ?? menuDePrueba();
  final List<Platillo> platillos_;

  @override
  Future<List<Platillo>> platillos() async => platillos_;
}

class FakeMesaRepository implements MesaRepository {
  FakeMesaRepository([List<Mesa>? mesas]) : mesas_ = mesas ?? mesasDePrueba();
  final List<Mesa> mesas_;

  @override
  Future<List<Mesa>> mesas() async => mesas_;
}

List<Platillo> menuDePrueba() => const [
      Platillo(idPlatillo: 1, nombre: 'Agua de Jamaica', precio: 48, categoria: CategoriaPlatillo.bebidas, disponible: true),
      Platillo(idPlatillo: 2, nombre: 'Enchiladas Verdes', precio: 165, categoria: CategoriaPlatillo.platosFuertes, disponible: true),
      Platillo(idPlatillo: 3, nombre: 'Flan de la Abuela', precio: 89, categoria: CategoriaPlatillo.postres, disponible: true),
      Platillo(idPlatillo: 4, nombre: 'Pastel de Chocolate', precio: 70, categoria: CategoriaPlatillo.postres, disponible: false),
    ];

List<Mesa> mesasDePrueba() => const [
      Mesa(idMesa: 11, numeroMesa: 1, capacidad: 2, estado: EstadoMesa.libre),
      Mesa(idMesa: 12, numeroMesa: 2, capacidad: 4, estado: EstadoMesa.ocupada),
      Mesa(idMesa: 13, numeroMesa: 3, capacidad: 4, estado: EstadoMesa.libre),
    ];

class FakePedidoRepository implements PedidoRepository {
  FakePedidoRepository(this.pedidos);

  List<PedidoResumen> pedidos;
  final cambiosEstado = <(int, EstadoPedido)>[];

  // --- crear / editar / cancelar ---
  final creados = <({TipoPedido tipo, int? idMesa, List<ItemPedido> items})>[];
  final actualizados = <({int folio, TipoPedido tipo, int? idMesa, List<ItemPedido> items})>[];
  final cancelados = <(int, String)>[];
  PedidoDetalle? detalleParaEditar;

  /// Si no es null, crear/actualizar fallan con este mensaje.
  String? errorAlGuardar;

  @override
  Future<int> crearPedido({
    required TipoPedido tipo,
    required List<ItemPedido> items,
    int? idMesa,
  }) async {
    if (errorAlGuardar != null) throw ErrorDeNegocio(errorAlGuardar!);
    creados.add((tipo: tipo, idMesa: idMesa, items: items));
    return 100 + creados.length;
  }

  @override
  Future<PedidoDetalle> obtenerPedido(int folio) async =>
      detalleParaEditar ?? (throw const ErrorDeNegocio('Pedido no encontrado'));

  @override
  Future<void> actualizarPedido({
    required int folio,
    required TipoPedido tipo,
    required List<ItemPedido> items,
    int? idMesa,
  }) async {
    if (errorAlGuardar != null) throw ErrorDeNegocio(errorAlGuardar!);
    actualizados.add((folio: folio, tipo: tipo, idMesa: idMesa, items: items));
  }

  @override
  Future<void> cancelarPedido(int folio, String motivo) async => cancelados.add((folio, motivo));

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
