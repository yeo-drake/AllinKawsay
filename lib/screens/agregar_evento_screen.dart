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
    );
    if (f != null) setState(() => _fecha = f);
  }

  Future<void> _elegirHora() async {
    final h = await showTimePicker(context: context, initialTime: _hora);
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'EDITAR EVENTO' : 'AGREGAR EVENTO'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titulo,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
                labelText: 'Título *', prefixIcon: Icon(Icons.event)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _lugar,
            decoration: const InputDecoration(
                labelText: 'Lugar', prefixIcon: Icon(Icons.place)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descripcion,
            maxLines: 4,
            decoration: const InputDecoration(
                labelText: 'Descripción',
                prefixIcon: Icon(Icons.description)),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _guardando ? null : _elegirFecha,
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    '${_fecha.day}/${_fecha.month}/${_fecha.year}',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _guardando ? null : _elegirHora,
                  icon: const Icon(Icons.access_time),
                  label: Text(_hora.format(context)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          if (_guardando)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Center(
                child:
                    CircularProgressIndicator(color: AppColors.granate),
              ),
            ),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: _guardando ? null : _guardar,
              icon: const Icon(Icons.save),
              label: Text(
                _esEdicion ? 'GUARDAR CAMBIOS' : 'GUARDAR EVENTO',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}