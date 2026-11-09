import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/reservacion.dart';
import '../../../domain/errors.dart';
import '../formato_reservacion.dart';
import '../reservaciones_providers.dart';

/// Formulario para crear (CU-10) o modificar (CU-13) una reservación.
/// Si [reservacion] viene null, es una reservación nueva.
/// El cliente reserva para sí mismo; el personal elige (o da de alta) al cliente.
/// Devuelve `true` si se guardó.
class ReservacionFormDialog extends ConsumerStatefulWidget {
  const ReservacionFormDialog({super.key, required this.esCliente, this.reservacion});

  final bool esCliente;
  final Reservacion? reservacion;

  @override
  ConsumerState<ReservacionFormDialog> createState() => _ReservacionFormDialogState();
}

class _ReservacionFormDialogState extends ConsumerState<ReservacionFormDialog> {
  static const _maxComensales = 20;

  final _formKey = GlobalKey<FormState>();
  final _nombreNuevo = TextEditingController();
  final _telefonoNuevo = TextEditingController();

  DateTime? _fecha; // solo día, mes y año
  TimeOfDay? _hora;
  int _comensales = 2;
  ClienteReserva? _cliente;
  bool _clienteNuevo = false;
  bool _guardando = false;
  String? _error;

  bool get _editando => widget.reservacion != null;

  @override
  void initState() {
    super.initState();
    final r = widget.reservacion;
    if (r != null) {
      _fecha = DateTime(r.inicio.year, r.inicio.month, r.inicio.day);
      _hora = TimeOfDay.fromDateTime(r.inicio);
      _comensales = r.comensales;
    }
  }

  @override
  void dispose() {
    _nombreNuevo.dispose();
    _telefonoNuevo.dispose();
    super.dispose();
  }

  String _horaTexto(TimeOfDay h) =>
      '${h.hour.toString().padLeft(2, '0')}:${h.minute.toString().padLeft(2, '0')}';

  Future<void> _elegirFecha() async {
    final hoy = DateTime.now();
    final inicio = DateTime(hoy.year, hoy.month, hoy.day);
    final elegida = await showDatePicker(
      context: context,
      initialDate: (_fecha != null && !_fecha!.isBefore(inicio)) ? _fecha! : inicio,
      firstDate: inicio,
      lastDate: inicio.add(const Duration(days: 365)),
      helpText: 'Fecha de la reservación',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );
    if (elegida != null) setState(() => _fecha = elegida);
  }

  Future<void> _elegirHora() async {
    final elegida = await showTimePicker(
      context: context,
      initialTime: _hora ?? const TimeOfDay(hour: 14, minute: 0),
      helpText: 'Hora de la reservación',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
      hourLabelText: 'Hora',
      minuteLabelText: 'Minuto',
    );
    if (elegida != null) setState(() => _hora = elegida);
  }

  Future<void> _guardar() async {
    setState(() => _error = null);
    final fecha = _fecha;
    final hora = _hora;
    if (fecha == null || hora == null) {
      setState(() => _error = 'Elige la fecha y la hora');
      return;
    }
    final inicio = DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute);
    if (!inicio.isAfter(DateTime.now())) {
      setState(() => _error = 'La fecha y hora de la reservación deben ser futuras');
      return;
    }
    final esPersonalNueva = !widget.esCliente && !_editando;
    if (esPersonalNueva) {
      if (_clienteNuevo) {
        if (!_formKey.currentState!.validate()) return;
      } else if (_cliente == null) {
        setState(() => _error = 'Elige un cliente');
        return;
      }
    }

    setState(() => _guardando = true);
    try {
      final lista = ref.read(reservacionesListaProvider.notifier);
      if (_editando) {
        await lista.modificar(
          idReservacion: widget.reservacion!.idReservacion,
          inicio: inicio,
          comensales: _comensales,
        );
      } else {
        int? idCliente;
        if (esPersonalNueva) {
          if (_clienteNuevo) {
            final nuevo = await ref
                .read(clientesReservaProvider.notifier)
                .crear(nombre: _nombreNuevo.text, telefono: _telefonoNuevo.text);
            // Si la reservación falla (p. ej. no hay mesa), al reintentar se reutiliza
            // este cliente en lugar de crear otro igual.
            if (mounted) {
              setState(() {
                _cliente = nuevo;
                _clienteNuevo = false;
              });
            }
            idCliente = nuevo.idCliente;
          } else {
            idCliente = _cliente!.idCliente;
          }
        }
        await lista.crear(inicio: inicio, comensales: _comensales, idCliente: idCliente);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _guardando = false;
          _error = mensajeDeError(
            e,
            porDefecto: _editando ? 'No se pudo modificar la reservación' : 'No se pudo crear la reservación',
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mostrarClientes = !widget.esCliente && !_editando;
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(_editando ? 'Modificar reservación' : 'Nueva reservación'),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!widget.esCliente && _editando) ...[
                  Text(
                    'Cliente: ${widget.reservacion!.nombreCliente ?? '—'}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const SizedBox(height: 14),
                ],
                if (mostrarClientes) ...[
                  _SeccionCliente(
                    cliente: _cliente,
                    clienteNuevo: _clienteNuevo,
                    nombre: _nombreNuevo,
                    telefono: _telefonoNuevo,
                    alElegir: (c) => setState(() => _cliente = c),
                    alAlternar: () => setState(() => _clienteNuevo = !_clienteNuevo),
                  ),
                  const SizedBox(height: 14),
                ],
                Row(
                  children: [
                    Expanded(
                      child: _CampoSeleccion(
                        etiqueta: 'Fecha',
                        valor: _fecha == null ? null : fechaCorta(_fecha!),
                        icono: Icons.calendar_today_outlined,
                        alTocar: _elegirFecha,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CampoSeleccion(
                        etiqueta: 'Hora',
                        valor: _hora == null ? null : _horaTexto(_hora!),
                        icono: Icons.schedule,
                        alTocar: _elegirHora,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Expanded(
                      child: Text('Comensales', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    IconButton.outlined(
                      onPressed: _comensales > 1 ? () => setState(() => _comensales--) : null,
                      icon: const Icon(Icons.remove, size: 18),
                      tooltip: 'Menos',
                    ),
                    SizedBox(
                      width: 44,
                      child: Text(
                        '$_comensales',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ),
                    IconButton.outlined(
                      onPressed: _comensales < _maxComensales ? () => setState(() => _comensales++) : null,
                      icon: const Icon(Icons.add, size: 18),
                      tooltip: 'Más',
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.amberRow,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.amberSoft),
                  ),
                  child: Text(
                    [
                      'La mesa se asigna sola según los comensales. '
                          'Cada reservación dura ${Reservacion.duracion.inHours} horas.',
                      if (widget.esCliente && _editando)
                        'Al modificarla volverá a quedar pendiente y tendrás que confirmarla.',
                    ].join('\n'),
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _guardando ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _guardando ? null : _guardar,
          style: FilledButton.styleFrom(backgroundColor: AppColors.amber),
          child: _guardando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                )
              : Text(_editando ? 'Guardar cambios' : 'Reservar'),
        ),
      ],
    );
  }
}

/// Campo de solo lectura que abre un selector (fecha u hora) al tocarlo.
class _CampoSeleccion extends StatelessWidget {
  const _CampoSeleccion({
    required this.etiqueta,
    required this.valor,
    required this.icono,
    required this.alTocar,
  });

  final String etiqueta;
  final String? valor;
  final IconData icono;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: alTocar,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: etiqueta,
          suffixIcon: Icon(icono, size: 18),
          border: const OutlineInputBorder(),
        ),
        child: Text(
          valor ?? 'Elegir',
          style: TextStyle(color: valor == null ? AppColors.textFaint : AppColors.text),
        ),
      ),
    );
  }
}

/// Solo para el personal: elegir un cliente existente o dar de alta uno nuevo.
class _SeccionCliente extends ConsumerWidget {
  const _SeccionCliente({
    required this.cliente,
    required this.clienteNuevo,
    required this.nombre,
    required this.telefono,
    required this.alElegir,
    required this.alAlternar,
  });

  final ClienteReserva? cliente;
  final bool clienteNuevo;
  final TextEditingController nombre;
  final TextEditingController telefono;
  final ValueChanged<ClienteReserva?> alElegir;
  final VoidCallback alAlternar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientes = ref.watch(clientesReservaProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (clienteNuevo) ...[
          TextFormField(
            controller: nombre,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Nombre del cliente'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Indica el nombre' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: telefono,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Teléfono (opcional)'),
          ),
        ] else
          clientes.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, _) => const Text(
              'No se pudieron cargar los clientes',
              style: TextStyle(color: AppColors.danger, fontSize: 13),
            ),
            data: (lista) {
              // Si acabamos de crear al cliente, puede que la lista aún no lo traiga.
              final opciones = [...lista];
              if (cliente != null && !opciones.contains(cliente)) opciones.add(cliente!);
              return DropdownButtonFormField<ClienteReserva>(
                key: ValueKey(cliente?.idCliente),
                initialValue: cliente,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Cliente'),
                items: [
                  for (final c in opciones)
                    DropdownMenuItem(
                      value: c,
                      child: Text(c.telefono == null ? c.nombre : '${c.nombre} · ${c.telefono}'),
                    ),
                ],
                onChanged: alElegir,
              );
            },
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: alAlternar,
            icon: Icon(clienteNuevo ? Icons.list : Icons.person_add_alt, size: 18),
            label: Text(clienteNuevo ? 'Elegir un cliente existente' : 'Cliente nuevo (sin cuenta)'),
          ),
        ),
      ],
    );
  }
}