import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/evento.dart';
import '../services/evento_service.dart';
import '../theme/colors.dart';

class AgregarEventoScreen extends StatefulWidget {
  final Evento? evento;
  const AgregarEventoScreen({super.key, this.evento});

  @override
  State<AgregarEventoScreen> createState() => _AgregarEventoScreenState();
}

class _AgregarEventoScreenState extends State<AgregarEventoScreen> {
  final _titulo = TextEditingController();
  final _descripcion = TextEditingController();
  final _lugar = TextEditingController();

  DateTime _fecha = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _hora = const TimeOfDay(hour: 19, minute: 0);
  bool _guardando = false;

  bool get _esEdicion => widget.evento != null;

  @override
  void initState() {
    super.initState();
    if (_esEdicion) {
      final e = widget.evento!;
      _titulo.text = e.titulo;
      _descripcion.text = e.descripcion;
      _lugar.text = e.lugar;
      _fecha = e.fecha;
      _hora = TimeOfDay(hour: e.fecha.hour, minute: e.fecha.minute);
    }
  }

  @override
  void dispose() {
    _titulo.dispose();
    _descripcion.dispose();
    _lugar.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final f = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppColors.granate,
              ),
        ),
        child: child!,
      ),
    );
    if (f != null) setState(() => _fecha = f);
  }

  Future<void> _elegirHora() async {
    final h = await showTimePicker(
      context: context,
      initialTime: _hora,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppColors.granate,
              ),
        ),
        child: child!,
      ),
    );
    if (h != null) setState(() => _hora = h);
  }

  Future<void> _guardar() async {
    if (_titulo.text.trim().isEmpty) {
      _snack('El título es obligatorio');
      return;
    }
    setState(() => _guardando = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final fechaFinal = DateTime(
        _fecha.year,
        _fecha.month,
        _fecha.day,
        _hora.hour,
        _hora.minute,
      );
      final service = EventoService();

      if (_esEdicion) {
        await service.actualizar(widget.evento!.id, {
          'titulo': _titulo.text.trim(),
          'descripcion': _descripcion.text.trim(),
          'lugar': _lugar.text.trim(),
          'fecha': fechaFinal,
        });
      } else {
        await service.agregar(Evento(
          id: '',
          titulo: _titulo.text.trim(),
          descripcion: _descripcion.text.trim(),
          lugar: _lugar.text.trim(),
          fecha: fechaFinal,
          creadoPor: user.uid,
          creadorNombre: user.displayName ?? user.email ?? 'Anónimo',
        ));
      }

      if (mounted) {
        _snack(_esEdicion ? '¡Evento actualizado!' : '¡Evento creado!');
        Navigator.pop(context);
      }
    } catch (e) {
      _snack('Error: $e');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  void _snack(String m) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'EDITAR EVENTO' : 'AGREGAR EVENTO'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // Header con ícono
          _header(onSurface, _esEdicion),
          const SizedBox(height: 20),

          // Sección: básicos
          _seccion(onSurface, Icons.info_outline, 'INFORMACIÓN'),
          const SizedBox(height: 10),

          TextField(
            controller: _titulo,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Título *',
              prefixIcon: Icon(Icons.event),
              hintText: 'Ej: Fiesta patronal 2026',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _lugar,
            decoration: const InputDecoration(
              labelText: 'Lugar',
              prefixIcon: Icon(Icons.place_outlined),
              hintText: 'Ej: Plaza principal, Local del grupo',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descripcion,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Descripción',
              prefixIcon: Icon(Icons.notes),
              alignLabelWithHint: true,
              hintText: 'Detalles del evento, qué llevar, etc.',
            ),
          ),
          const SizedBox(height: 24),

          // Sección: fecha
          _seccion(onSurface, Icons.calendar_today, 'FECHA Y HORA'),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _botonFecha(
                    Icons.calendar_today, 
                    '${_fecha.day}/${_fecha.month}/${_fecha.year}',
                    _elegirFecha),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _botonFecha(
                    Icons.access_time, _hora.format(context), _elegirHora),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Botón guardar
          SizedBox(
            height: 54,
            child: FilledButton.icon(
              onPressed: _guardando ? null : _guardar,
              icon: _guardando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: AppColors.dorado,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(
                _guardando
                    ? 'GUARDANDO...'
                    : (_esEdicion
                        ? 'GUARDAR CAMBIOS'
                        : 'GUARDAR EVENTO'),
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(Color onSurface, bool esEdicion) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.granate.withOpacity(0.08),
            AppColors.dorado.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.dorado.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: AppColors.gradienteGranate,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.granate.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(esEdicion ? Icons.edit_calendar : Icons.event_available,
                color: AppColors.dorado, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(esEdicion ? 'Editando evento' : 'Nuevo evento',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: onSurface,
                        fontSize: 15,
                        letterSpacing: 0.3)),
                const SizedBox(height: 2),
                Text(
                  esEdicion
                      ? 'Modifica los datos del evento'
                      : 'Completa los datos del evento',
                  style: TextStyle(
                      fontSize: 12,
                      color: onSurface.withOpacity(0.55)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _seccion(Color onSurface, IconData icono, String titulo) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: AppColors.granate.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icono, size: 13, color: AppColors.granate),
        ),
        const SizedBox(width: 10),
        Text(titulo,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.granate,
                letterSpacing: 2)),
      ],
    );
  }

  Widget _botonFecha(IconData icono, String texto, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _guardando ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.cardColor(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.dorado.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.granate.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icono, color: AppColors.granate, size: 15),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  texto,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}