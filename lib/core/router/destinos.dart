import 'package:flutter/material.dart';

import '../../domain/entities/perfil.dart';

/// Secciones de la aplicación (pestañas bajo el encabezado).
enum Destino {
  inicio('/inicio', 'Inicio', Icons.home_outlined),
  reservaciones('/reservaciones', 'Reservaciones', Icons.event_seat_outlined),
  cocina('/cocina', 'Cocina', Icons.soup_kitchen_outlined),
  gerencia('/gerencia', 'Gerencia', Icons.admin_panel_settings_outlined);

  const Destino(this.ruta, this.etiqueta, this.icono);
  final String ruta;
  final String etiqueta;
  final IconData icono;

  /// Roles que pueden entrar a esta sección.
  Set<RolUsuario> get roles => switch (this) {
        Destino.inicio => RolUsuario.values.toSet(),
        Destino.reservaciones => {RolUsuario.cliente, RolUsuario.mesero, RolUsuario.gerente},
        Destino.cocina => {RolUsuario.chef, RolUsuario.gerente},
        Destino.gerencia => {RolUsuario.gerente},
      };

  bool permite(RolUsuario rol) => roles.contains(rol);
}

/// Pestañas visibles para un rol (mesero: Inicio + Reservaciones; chef: Inicio + Cocina; gerente: todo).
/// OJO: esto es solo experiencia de usuario. La seguridad real está en RLS y
/// en las reglas de la base de datos.
List<Destino> destinosPara(RolUsuario rol) =>
    Destino.values.where((d) => d.permite(rol)).toList();
