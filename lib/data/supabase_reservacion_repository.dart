import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/entities/reservacion.dart';
import '../domain/errors.dart';
import '../domain/repositories/reservacion_repository.dart';

class SupabaseReservacionRepository implements ReservacionRepository {
  SupabaseReservacionRepository(this._client);
  final SupabaseClient _client;

  // La mesa viene anidada; si el usuario no puede ver mesas (cliente), llega null.
  static const _columnas =
      'id_reservacion, fecha, hora, num_comensales, estado, id_cliente, '
      'cliente:id_cliente(nombre), mesa:id_mesa(numero_mesa)';

  @override
  Future<List<Reservacion>> listar() async {
    try {
      final filas = await _client
          .from('reservacion')
          .select(_columnas)
          .order('fecha', ascending: true)
          .order('hora', ascending: true);
      return filas.map(_aReservacion).toList();
    } on PostgrestException catch (e) {
      throw ErrorDeNegocio(e.message);
    }
  }

  @override
  Stream<void> cambios() {
    late final StreamController<void> controlador;
    RealtimeChannel? canal;
    controlador = StreamController<void>(
      onListen: () {
        canal = _client
            .channel('reservaciones-cambios-${DateTime.now().microsecondsSinceEpoch}')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'reservacion',
              callback: (_) => controlador.add(null),
            )
            .subscribe();
      },
      onCancel: () async {
        final c = canal;
        if (c != null) await _client.removeChannel(c);
      },
    );
    return controlador.stream;
  }

  @override
  Future<int> crear({
    required DateTime inicio,
    required int comensales,
    int? idCliente,
  }) async {
    try {
      final fila = await _client
          .from('reservacion')
          .insert({
            'fecha': _fecha(inicio),
            'hora': _hora(inicio),
            'num_comensales': comensales,
            // Un cliente no envía su id: el trigger de la base lo pone.
               'id_cliente': ?idCliente,
          })
          .select('id_reservacion')
          .single();
      return fila['id_reservacion'] as int;
    } on PostgrestException catch (e) {
      throw ErrorDeNegocio(e.message);
    }
  }

  @override
  Future<void> modificar({
    required int idReservacion,
    required DateTime inicio,
    required int comensales,
  }) async {
    try {
      await _client.from('reservacion').update({
        'fecha': _fecha(inicio),
        'hora': _hora(inicio),
        'num_comensales': comensales,
      }).eq('id_reservacion', idReservacion);
    } on PostgrestException catch (e) {
      throw ErrorDeNegocio(e.message);
    }
  }

  @override
  Future<void> cancelar(int idReservacion) => _cambiarEstado(idReservacion, EstadoReservacion.cancelada);

  @override
  Future<void> confirmar(int idReservacion) => _cambiarEstado(idReservacion, EstadoReservacion.confirmada);

  Future<void> _cambiarEstado(int idReservacion, EstadoReservacion nuevo) async {
    try {
      await _client
          .from('reservacion')
          .update({'estado': nuevo.valorBd}).eq('id_reservacion', idReservacion);
    } on PostgrestException catch (e) {
      throw ErrorDeNegocio(e.message);
    }
  }

  @override
  Future<List<ClienteReserva>> clientes() async {
    try {
      final filas =
          await _client.from('cliente').select('id_cliente, nombre, telefono').order('nombre');
      return filas.map(_aCliente).toList();
    } on PostgrestException catch (e) {
      throw ErrorDeNegocio(e.message);
    }
  }

  @override
  Future<ClienteReserva> crearCliente({required String nombre, String? telefono}) async {
    try {
      final tel = telefono?.trim();
      final fila = await _client
          .from('cliente')
          .insert({
            'nombre': nombre.trim(),
            'telefono': (tel == null || tel.isEmpty) ? null : tel,
          })
          .select('id_cliente, nombre, telefono')
          .single();
      return _aCliente(fila);
    } on PostgrestException catch (e) {
      throw ErrorDeNegocio(e.message);
    }
  }

  // --- ayudas -------------------------------------------------------------

  /// '2026-11-12'
  String _fecha(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// '19:30:00'
  String _hora(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}:00';

  Reservacion _aReservacion(Map<String, dynamic> f) {
    final cliente = f['cliente'] as Map<String, dynamic>?;
    final mesa = f['mesa'] as Map<String, dynamic>?;
    return Reservacion(
      idReservacion: f['id_reservacion'] as int,
      // La base guarda fecha y hora por separado; aquí se juntan en un solo DateTime.
      inicio: DateTime.parse('${f['fecha']}T${f['hora']}'),
      comensales: f['num_comensales'] as int,
      estado: EstadoReservacion.desdeBd(f['estado'] as String),
      idCliente: f['id_cliente'] as int,
      nombreCliente: cliente?['nombre'] as String?,
      numeroMesa: mesa?['numero_mesa'] as int?,
    );
  }

  ClienteReserva _aCliente(Map<String, dynamic> f) => ClienteReserva(
        idCliente: f['id_cliente'] as int,
        nombre: f['nombre'] as String,
        telefono: f['telefono'] as String?,
      );
}