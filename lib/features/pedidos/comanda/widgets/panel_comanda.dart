import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formato.dart';
import '../comanda_state.dart';

/// Panel derecho: resumen de la comanda, totales y acciones.
class PanelComanda extends StatelessWidget {
  const PanelComanda({
    super.key,
    required this.estado,
    required this.subtitulo,
    required this.textoEnviar,
    required this.alIncrementar,
    required this.alDecrementar,
    required this.alCambiarNota,
    required this.alEnviar,
    required this.alVaciar,
    this.textoSecundario = 'Cancelar / Vaciar',
    this.alCancelarPedido,
  });

  final ComandaState estado;

  /// "Mesa 1 · Presencial"
  final String subtitulo;
  final String textoEnviar;

  /// "Cancelar / Vaciar" al crear; "Descartar Cambios" al editar.
  final String textoSecundario;
  final ValueChanged<int> alIncrementar;
  final ValueChanged<int> alDecrementar;
  final void Function(int idLinea, String nota) alCambiarNota;
  final VoidCallback alEnviar;
  final VoidCallback alVaciar;

  /// Solo en modo edición: botón rojo "Cancelar Pedido".
  final VoidCallback? alCancelarPedido;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text(
                  'COMANDA ACTUAL',
                  style: TextStyle(
                    color: AppColors.amber,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.amberSoft,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  '${estado.numeroLineas}',
                  key: const Key('badge_lineas'),
                  style: const TextStyle(
                    color: Color(0xFFB45309),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const Text('Resumen de Comanda', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(subtitulo, style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: AppColors.border),
          ),
          Expanded(
            child: estado.lineas.isEmpty
                ? const _Vacia()
                : ListView.separated(
                    itemCount: estado.lineas.length,
                    separatorBuilder: (_, _) => const Divider(height: 22, color: AppColors.borderSoft),
                    itemBuilder: (_, i) {
                      final l = estado.lineas[i];
                      return _Linea(
                        key: ValueKey(l.id),
                        linea: l,
                        alIncrementar: () => alIncrementar(l.id),
                        alDecrementar: () => alDecrementar(l.id),
                        alCambiarNota: (n) => alCambiarNota(l.id, n),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.pageBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text('Subtotal', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ),
                    Text(
                      formatoMoneda(estado.total),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1, color: AppColors.border),
                ),
                Row(
                  children: [
                    const Expanded(child: Text('Total', style: TextStyle(fontWeight: FontWeight.w700))),
                    Text(
                      formatoMoneda(estado.total),
                      key: const Key('total_comanda'),
                      style: const TextStyle(
                        color: Color(0xFFB45309),
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text('*IVA incluido', style: TextStyle(color: AppColors.textFaint, fontSize: 9.5)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 50,
            child: FilledButton(
              onPressed: estado.enviando ? null : alEnviar,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.amber,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
              ),
              child: estado.enviando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Si el texto no cabe (p. ej. con zoom alto) se encoge en vez de desbordar.
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              textoEnviar,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 16),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 46,
            child: OutlinedButton(
              onPressed: estado.enviando ? null : alVaciar,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textMuted,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
              ),
              child: Text(textoSecundario),
            ),
          ),
          if (alCancelarPedido != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 46,
              child: FilledButton(
                onPressed: estado.enviando ? null : alCancelarPedido,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                  textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
                ),
                child: const Text('Cancelar Pedido'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Vacia extends StatelessWidget {
  const _Vacia();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined, size: 30, color: AppColors.amber),
          SizedBox(height: 12),
          Text(
            'Agrega platillos para iniciar la comanda.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textFaint, fontSize: 11.5),
          ),
        ],
      ),
    );
  }
}

class _Linea extends StatelessWidget {
  const _Linea({
    super.key,
    required this.linea,
    required this.alIncrementar,
    required this.alDecrementar,
    required this.alCambiarNota,
  });

  final LineaComanda linea;
  final VoidCallback alIncrementar;
  final VoidCallback alDecrementar;
  final ValueChanged<String> alCambiarNota;

  @override
  Widget build(BuildContext context) {
    Widget boton(IconData icono, String tooltip, VoidCallback alTocar) => Tooltip(
          message: tooltip,
          child: InkWell(
            onTap: alTocar,
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(width: 30, height: 30, child: Icon(icono, size: 16, color: AppColors.textMuted)),
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                linea.nombre,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              formatoMoneda(linea.subtotal),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        Text(
          '${formatoMoneda(linea.precio)} c/u',
          style: const TextStyle(color: AppColors.textFaint, fontSize: 10.5),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.pageBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  boton(Icons.remove, 'Quitar uno', alDecrementar),
                  SizedBox(
                    width: 28,
                    child: Text(
                      '${linea.cantidad}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                    ),
                  ),
                  boton(Icons.add, 'Agregar uno', alIncrementar),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _NotaEditable(
                cantidad: linea.cantidad,
                nombre: linea.nombre,
                nota: linea.nota,
                alCambiar: alCambiarNota,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Chip "2x Enchiladas Verdes · Nota: [texto]" con la nota editable en línea.
class _NotaEditable extends StatefulWidget {
  const _NotaEditable({
    required this.cantidad,
    required this.nombre,
    required this.nota,
    required this.alCambiar,
  });

  final int cantidad;
  final String nombre;
  final String nota;
  final ValueChanged<String> alCambiar;

  @override
  State<_NotaEditable> createState() => _NotaEditableState();
}

class _NotaEditableState extends State<_NotaEditable> {
  late final TextEditingController _controlador = TextEditingController(text: widget.nota);

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          Flexible(
            flex: 3,
            child: Text(
              '${widget.cantidad}x ${widget.nombre} · Nota:',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFFB45309), fontSize: 9.5, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            flex: 2,
            child: TextField(
              controller: _controlador,
              maxLength: 200,
              onChanged: widget.alCambiar,
              style: const TextStyle(fontSize: 10.5, color: Color(0xFF92400E)),
              decoration: const InputDecoration(
                hintText: 'N/A',
                hintStyle: TextStyle(color: Color(0xFFB45309), fontSize: 10.5),
                counterText: '',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 5),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFDBA74))),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.amber)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
