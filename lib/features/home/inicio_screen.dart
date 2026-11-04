import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../presentation/widgets/en_construccion.dart';
import '../auth/auth_providers.dart';
import '../pedidos/comanderia_screen.dart';
import '../shell/shell_autenticado.dart';

/// "Inicio": el personal (mesero, chef, gerente) ve la Comandería; el cliente, su espacio.
class InicioScreen extends ConsumerWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perfil = ref.watch(perfilActualProvider).value;
    return InicioPorRol(
      rol: perfil?.rol,
      personal: const ComanderiaScreen(),
      cliente: EnConstruccion(
        titulo: 'Hola, ${perfil?.nombre ?? ''}',
        descripcion: 'Aquí podrás reservar una mesa y hacer pedidos en línea.\n'
            'Estas pantallas aún están en diseño.',
        icono: Icons.restaurant_menu,
      ),
    );
  }
}
