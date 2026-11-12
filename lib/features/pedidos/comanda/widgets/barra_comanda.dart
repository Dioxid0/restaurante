import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/mesa.dart';
import '../../../../domain/entities/pedido.dart';

/// Barra oscura superior: volver, mesa, "Sin mesa" y tipo de pedido.
/// El cliente solo ve el botón de volver.
class BarraComanda extends StatelessWidget {
  const BarraComanda({
    super.key,
    required this.mostrarOpciones,
    required this.mesas,
    required this.idMesa,
    required this.tipo,
    required this.sinMesa,
    required this.alVolver,
    required this.alCambiarMesa,
    required this.alCambiarTipo,
    required this.alCambiarSinMesa,
  });

  /// false para el cliente: sin mesa ni tipo.
  final bool mostrarOpciones;
  final List<Mesa> mesas;
  final int? idMesa;
  final TipoPedido tipo;
  final bool sinMesa;
  final VoidCallback alVolver;
  final ValueChanged<int?> alCambiarMesa;
  final ValueChanged<TipoPedido> alCambiarTipo;
  final ValueChanged<bool> alCambiarSinMesa;

  @override
  Widget build(BuildContext context) {
    final paraLlevar = tipo == TipoPedido.paraLlevar;
    return Container(
      width: double.infinity, // la barra oscura ocupa todo el ancho, como en el diseño
      color: AppColors.navy900,
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
      child: Wrap(
        spacing: 14,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          OutlinedButton.icon(
            onPressed: alVolver,
            icon: const Icon(Icons.arrow_back, size: 16),
            label: Text(mostrarOpciones ? 'Volver al Dashboard' : 'Volver'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFE2E8F0),
              side: const BorderSide(color: AppColors.navyBorder),
              backgroundColor: const Color(0xFF111B30),
              minimumSize: const Size(0, 44),
              textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
            ),
          ),
          if (mostrarOpciones) ...[
            const Text(
              'Mesa',
              style: TextStyle(color: AppColors.textFaint, fontSize: 11.5, fontWeight: FontWeight.w700),
            ),
            _SelectorMesa(
              mesas: mesas,
              idMesa: idMesa,
              deshabilitado: paraLlevar && sinMesa,
              alCambiar: alCambiarMesa,
            ),
            if (paraLlevar)
              InkWell(
                onTap: () => alCambiarSinMesa(!sinMesa),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: Checkbox(
                          value: sinMesa,
                          onChanged: (v) => alCambiarSinMesa(v ?? false),
                          activeColor: AppColors.amber,
                          side: const BorderSide(color: AppColors.textFaint),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Sin mesa',
                        style: TextStyle(
                          color: Color(0xFFE2E8F0),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            _InterruptorTipo(tipo: tipo, alCambiar: alCambiarTipo),
          ],
        ],
      ),
    );
  }
}

class _SelectorMesa extends StatelessWidget {
  const _SelectorMesa({
    required this.mesas,
    required this.idMesa,
    required this.deshabilitado,
    required this.alCambiar,
  });

  final List<Mesa> mesas;
  final int? idMesa;
  final bool deshabilitado;
  final ValueChanged<int?> alCambiar;

  @override
  Widget build(BuildContext context) {
    final valor = mesas.any((m) => m.idMesa == idMesa) ? idMesa : null;
    return Opacity(
      opacity: deshabilitado ? 0.45 : 1,
      child: Container(
        width: 230,
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: AppColors.navyBorder),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: valor,
            isExpanded: true,
            dropdownColor: const Color(0xFF1E293B),
            iconEnabledColor: Colors.white,
            iconDisabledColor: AppColors.textMuted,
            borderRadius: BorderRadius.circular(10),
            hint: const Text(
              'Seleccionar mesa *',
              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
            ),
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
            onChanged: deshabilitado ? null : alCambiar,
            items: [
              for (final m in mesas)
                DropdownMenuItem(
                  value: m.idMesa,
                  child: Row(
                    children: [
                      Expanded(child: Text(m.etiqueta)),
                      if (m.estado == EstadoMesa.ocupada)
                        const Text(
                          'Ocupada',
                          style: TextStyle(color: Color(0xFFFBBF24), fontSize: 10.5),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InterruptorTipo extends StatelessWidget {
  const _InterruptorTipo({required this.tipo, required this.alCambiar});
  final TipoPedido tipo;
  final ValueChanged<TipoPedido> alCambiar;

  @override
  Widget build(BuildContext context) {
    Widget opcion(String texto, TipoPedido valor) {
      final activo = tipo == valor;
      return InkWell(
        onTap: () => alCambiar(valor),
        borderRadius: BorderRadius.circular(9),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          decoration: BoxDecoration(
            color: activo ? AppColors.amber : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            texto,
            style: TextStyle(
              color: activo ? Colors.white : AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF111B30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.navyBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          opcion('Presencial', TipoPedido.enMesa),
          opcion('Para Llevar', TipoPedido.paraLlevar),
        ],
      ),
    );
  }
}
