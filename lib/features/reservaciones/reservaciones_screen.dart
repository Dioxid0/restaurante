import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/ui/toast.dart';
import '../../core/utils/formato.dart';
import '../../domain/entities/perfil.dart';
import '../../domain/entities/reservacion.dart';
import '../../domain/errors.dart';
import '../auth/auth_providers.dart';
import '../pedidos/pedidos_providers.dart';
import '../pedidos/widgets/boton_confirmable.dart';
import 'reservaciones_providers.dart';

enum _Filtro {
  proximas('Próximas'),
  historial('Historial'),
  todas('Todas');

  const _Filtro(this.etiqueta);
  final String etiqueta;
}

const _dias = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];
const _meses = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];

/// Reservaciones (CU-12): el cliente ve las suyas; el mesero y el gerente ven todas.
/// Aquí también se confirman ("¿Confirmas tu reservación?") y se cancelan (CU-14).
/// (Diseño provisional hasta recibir la pantalla de Figma.)
class ReservacionesScreen extends ConsumerStatefulWidget {
  const ReservacionesScreen({super.key});

  @override
  ConsumerState<ReservacionesScreen> createState() => _ReservacionesScreenState();
}

class _ReservacionesScreenState extends ConsumerState<ReservacionesScreen> {
  _Filtro _filtro = _Filtro.proximas;

  /// Ejecuta una acción y avisa con un toast si salió bien o por qué falló.
  Future<void> _ejecutar(Future<void> Function() accion, String exito) async {
    try {
      await accion();
      if (mounted) mostrarToast(context, exito);
    } catch (e) {
      if (mounted) mostrarToast(context, mensajeDeError(e), tipo: TipoToast.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reservaciones = ref.watch(reservacionesListaProvider);
    final perfil = ref.watch(perfilActualProvider).value;
    final esCliente = perfil?.rol == RolUsuario.cliente;
    // El reloj avanza solo, así "¿Confirmas?" aparece sin recargar la pantalla.
    final ahora = ref.watch(relojProvider).value ?? DateTime.now();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 26, 28, 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'RESERVACIONES',
                style: TextStyle(
                  color: AppColors.amber,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                esCliente ? 'Mis reservaciones' : 'Reservaciones',
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                esCliente
                    ? 'Consulta, confirma o cancela tus reservaciones.'
                    : 'Reservaciones de todos los clientes. La mesa se asigna sola.',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                children: [
                  for (final f in _Filtro.values)
                    ChoiceChip(
                      label: Text(f.etiqueta),
                      selected: _filtro == f,
                      onSelected: (_) => setState(() => _filtro = f),
                      selectedColor: AppColors.amberSoft,
                      showCheckmark: false,
                      labelStyle: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: _filtro == f ? AppColors.amber : AppColors.textMuted,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              reservaciones.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(60),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(48),
                  child: Center(
                    child: Column(
                      children: [
                        const Text('No se pudieron cargar las reservaciones'),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () => ref.invalidate(reservacionesListaProvider),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (lista) {
                  final visibles = _filtrar(lista, ahora);
                  if (visibles.isEmpty) return _Vacio(filtro: _filtro);
                  final notifier = ref.read(reservacionesListaProvider.notifier);
                  return Column(
                    children: [
                      for (final r in visibles)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _TarjetaReservacion(
                            reservacion: r,
                            ahora: ahora,
                            esCliente: esCliente,
                            alConfirmar: () => _ejecutar(
                              () => notifier.confirmar(r.idReservacion),
                              'Reservación confirmada',
                            ),
                            alCancelar: () => _ejecutar(
                              () => notifier.cancelar(r.idReservacion),
                              'Reservación cancelada',
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Reservacion> _filtrar(List<Reservacion> lista, DateTime ahora) {
    bool esProxima(Reservacion r) => r.estado.esActiva && r.fin.isAfter(ahora);
    return switch (_filtro) {
      _Filtro.proximas => lista.where(esProxima).toList(),
      // La más reciente primero.
      _Filtro.historial => lista.where((r) => !esProxima(r)).toList().reversed.toList(),
      _Filtro.todas => lista,
    };
  }
}

class _Vacio extends StatelessWidget {
  const _Vacio({required this.filtro});
  final _Filtro filtro;

  @override
  Widget build(BuildContext context) {
    final texto = switch (filtro) {
      _Filtro.proximas => 'No hay reservaciones próximas',
      _Filtro.historial => 'Todavía no hay historial',
      _Filtro.todas => 'No hay reservaciones',
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 56),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.event_seat_outlined, size: 40, color: AppColors.textFaint),
          const SizedBox(height: 10),
          Text(texto, style: const TextStyle(color: AppColors.textMuted, fontSize: 13.5)),
        ],
      ),
    );
  }
}

class _TarjetaReservacion extends StatelessWidget {
  const _TarjetaReservacion({
    required this.reservacion,
    required this.ahora,
    required this.esCliente,
    required this.alConfirmar,
    required this.alCancelar,
  });

  final Reservacion reservacion;
  final DateTime ahora;
  final bool esCliente;
  final VoidCallback alConfirmar;
  final VoidCallback alCancelar;

  @override
  Widget build(BuildContext context) {
    final r = reservacion;
    final futura = r.inicio.isAfter(ahora);

    // Quién puede hacer qué: el cliente tiene el límite de 5 horas (RN-07);
    // el personal no. Aun así, la base de datos es la que decide de verdad.
    final puedeCancelar = esCliente ? r.clientePuedeCambiar(ahora) : r.estado.esActiva;
    final puedeConfirmar = r.estado == EstadoReservacion.pendiente &&
        (esCliente ? r.requiereConfirmacion(ahora) : futura);
    final pidePreguntar = esCliente && r.requiereConfirmacion(ahora);
    final bloqueadaPorTiempo = esCliente && r.estado.esActiva && futura && !r.clientePuedeCambiar(ahora);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: pidePreguntar ? AppColors.amber : AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (pidePreguntar)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              color: AppColors.amberSoft,
              child: const Text(
                '¿Confirmas tu reservación? Te esperamos pronto.',
                style: TextStyle(color: Color(0xFFB45309), fontSize: 12.5, fontWeight: FontWeight.w700),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _BloqueFecha(fecha: r.inicio),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${formatoHora(r.inicio)} – ${formatoHora(r.fin)}',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _detalle(r),
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5),
                      ),
                      const SizedBox(height: 8),
                      _EstadoReservacionChip(r.estado),
                      if (bloqueadaPorTiempo) ...[
                        const SizedBox(height: 6),
                        const Text(
                          'Faltan menos de 5 horas: para cambiarla, contacta al restaurante.',
                          style: TextStyle(color: AppColors.textFaint, fontSize: 11.5),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (puedeConfirmar)
                      BotonConfirmable(
                        icono: Icons.check,
                        tooltip: 'Confirmar',
                        titulo: '¿Confirmar la reservación?',
                        textoConfirmar: 'Confirmar',
                        color: AppColors.green,
                        fondo: const Color(0xFFF0FDF4),
                        borde: const Color(0xFFBBF7D0),
                        alConfirmar: alConfirmar,
                      ),
                    if (puedeConfirmar && puedeCancelar) const SizedBox(width: 8),
                    if (puedeCancelar)
                      BotonConfirmable(
                        icono: Icons.close,
                        tooltip: 'Cancelar',
                        titulo: '¿Cancelar la reservación?',
                        detalle: 'Esta acción no se puede deshacer.',
                        textoConfirmar: 'Sí, cancelar',
                        color: AppColors.danger,
                        fondo: const Color(0xFFFEF2F2),
                        borde: const Color(0xFFFECACA),
                        alConfirmar: alCancelar,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// "4 personas · Mesa M-03 · Ana López" (la mesa y el nombre solo los ve el personal).
  String _detalle(Reservacion r) {
    final partes = <String>[
      r.comensales == 1 ? '1 persona' : '${r.comensales} personas',
      if (!esCliente && r.mesaEtiqueta != null) 'Mesa ${r.mesaEtiqueta}',
      if (!esCliente && r.nombreCliente != null) r.nombreCliente!,
    ];
    return partes.join(' · ');
  }
}

/// Cuadro con el día: "jue / 12 / nov".
class _BloqueFecha extends StatelessWidget {
  const _BloqueFecha({required this.fecha});
  final DateTime fecha;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.amberRow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.amberSoft),
      ),
      child: Column(
        children: [
          Text(
            _dias[fecha.weekday - 1].toUpperCase(),
            style: const TextStyle(color: AppColors.amber, fontSize: 10.5, fontWeight: FontWeight.w800),
          ),
          Text('${fecha.day}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          Text(
            _meses[fecha.month - 1].toUpperCase(),
            style: const TextStyle(color: AppColors.textMuted, fontSize: 10.5, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _EstadoReservacionChip extends StatelessWidget {
  const _EstadoReservacionChip(this.estado);
  final EstadoReservacion estado;

  static (Color fondo, Color texto) _colores(EstadoReservacion e) => switch (e) {
        EstadoReservacion.pendiente => (const Color(0xFFFEF3C7), const Color(0xFFB45309)),
        EstadoReservacion.confirmada => (const Color(0xFFECFDF5), const Color(0xFF059669)),
        EstadoReservacion.cancelada => (const Color(0xFFFEE2E2), const Color(0xFFB91C1C)),
        EstadoReservacion.completada => (const Color(0xFFE2E8F0), const Color(0xFF475569)),
      };

  @override
  Widget build(BuildContext context) {
    final (fondo, texto) = _colores(estado);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: fondo, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 7, color: texto),
          const SizedBox(width: 6),
          Text(
            estado.etiqueta,
            style: TextStyle(color: texto, fontSize: 11.5, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}