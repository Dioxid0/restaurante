import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Marco común de las secciones de Gerencia: encabezado, botón opcional y contenido.
class SeccionGerencia extends StatelessWidget {
  const SeccionGerencia({
    super.key,
    required this.kicker,
    required this.titulo,
    required this.descripcion,
    required this.hijo,
    this.accion,
  });

  final String kicker;
  final String titulo;
  final String descripcion;
  final Widget hijo;
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 18, 28, 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kicker,
                          style: const TextStyle(
                            color: AppColors.amber,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(titulo, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(descripcion, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                      ],
                    ),
                  ),
                  ?accion,
                ],
              ),
              const SizedBox(height: 22),
              hijo,
            ],
          ),
        ),
      ),
    );
  }
}

/// Botón principal ámbar de cada sección.
class BotonAccion extends StatelessWidget {
  const BotonAccion({super.key, required this.etiqueta, required this.icono, required this.alPresionar});
  final String etiqueta;
  final IconData icono;
  final VoidCallback alPresionar;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: alPresionar,
      icon: Icon(icono, size: 20),
      label: Text(etiqueta),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.amber,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      ),
    );
  }
}

/// Contenedor blanco con borde para tablas y listas.
class PanelBlanco extends StatelessWidget {
  const PanelBlanco({super.key, required this.hijo});
  final Widget hijo;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: hijo,
    );
  }
}

/// Fila de tabla con columnas proporcionales ([flex]).
class FilaTabla extends StatelessWidget {
  const FilaTabla({super.key, required this.flex, required this.celdas, this.encabezado = false});
  final List<int> flex;
  final List<Widget> celdas;
  final bool encabezado;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: encabezado ? 40 : 52),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: encabezado ? const Color(0xFFF8FAFC) : Colors.white,
        border: const Border(top: BorderSide(color: AppColors.borderSoft)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < celdas.length; i++)
            Expanded(
              flex: flex[i],
              child: Align(alignment: Alignment.centerLeft, child: celdas[i]),
            ),
        ],
      ),
    );
  }
}

Widget encabezadoTabla(String t) => Text(
      t,
      style: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 10.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
      ),
    );

/// Estado de carga / error de una sección con datos asíncronos.
class CargandoOError extends StatelessWidget {
  const CargandoOError({super.key, this.mensaje, this.alReintentar});
  final String? mensaje;
  final VoidCallback? alReintentar;

  @override
  Widget build(BuildContext context) {
    if (mensaje == null) {
      return const Padding(padding: EdgeInsets.all(60), child: Center(child: CircularProgressIndicator()));
    }
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Center(
        child: Column(
          children: [
            Text(mensaje!),
            const SizedBox(height: 12),
            FilledButton(onPressed: alReintentar, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}

/// Pide confirmación antes de una acción destructiva. Devuelve true si se confirma.
Future<bool> confirmar(BuildContext context, {required String titulo, required String mensaje, String boton = 'Eliminar'}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      title: Text(titulo),
      content: Text(mensaje),
      actions: [
        TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancelar')),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
          child: Text(boton),
        ),
      ],
    ),
  );
  return r == true;
}

void avisar(BuildContext context, String texto) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(texto)));
}
