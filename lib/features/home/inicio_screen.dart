import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import '../pedidos/comanderia_screen.dart';
import '../pedidos/mis_pedidos_screen.dart';
import '../shell/shell_autenticado.dart';

/// "Inicio": el personal (mesero, chef, gerente) ve la Comandería; el cliente, "Mis pedidos".
class InicioScreen extends ConsumerWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perfil = ref.watch(perfilActualProvider).value;
    return InicioPorRol(
      rol: perfil?.rol,
      personal: const ComanderiaScreen(),
      cliente: const MisPedidosScreen(),
    );
  }
}
