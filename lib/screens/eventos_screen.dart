import 'package:flutter/material.dart';
import '../models/evento.dart';
import '../models/usuario.dart';
import '../services/evento_service.dart';
import '../services/usuario_service.dart';
import '../theme/colors.dart';
import '../widgets/watermark_overlay.dart';
import 'agregar_evento_screen.dart';

class EventosScreen extends StatefulWidget {
  const EventosScreen({super.key});

  @override
  State<EventosScreen> createState() => _EventosScreenState();
}

class _EventosScreenState extends State<EventosScreen> {
  final _service = EventoService();
  bool _esAdmin = false;
  Usuario? _usuario;

  @override
  void initState() {
    super.initState();
    _chequearAdmin();
    _cargarUsuario();
  }

  Future<void> _chequearAdmin() async {
    final a = await UsuarioService().soyAdmin();
    if (mounted) setState(() => _esAdmin = a);
  }

  Future<void> _cargarUsuario() async {
    final u = await UsuarioService().miUsuarioActual();
    if (mounted) setState(() => _usuario = u);
  }

  void _eliminar(Evento e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar evento'),
        content: Text('¿Eliminar "${e.titulo}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok == true) await _service.eliminar(e.id);
  }

  void _editar(Evento e) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AgregarEventoScreen(evento: e),
      ),
    );
  }

  Future<void> _editarNota(Evento e) async {
    final ctrl = TextEditingController(
      text: _usuario?.notaEvento(e.id) ?? '',
    );
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Nota: ${e.titulo}'),
        content: TextField(
          controller: ctrl,
          maxLines: 5,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Ej: llevar tal instrumento, ir a tal hora...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Guardar')),
        ],
      ),
    );
    if (ok == true) {
      await UsuarioService().guardarNotaEvento(e.id, ctrl.text);
      await _cargarUsuario();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PRÓXIMOS EVENTOS')),
      floatingActionButton: _esAdmin
          ? FloatingActionButton(
              backgroundColor: AppColors.granate,
              foregroundColor: AppColors.dorado,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AgregarEventoScreen()),
              ),
              child: const Icon(Icons.add),
            )
          : null,
      body: WatermarkOverlay(
        child: StreamBuilder<List<Evento>>(
          stream: _service.listar(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.granate));
            }
            if (snap.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Error: ${snap.error}',
                      textAlign: TextAlign.center),
                ),
              );
            }
            final lista = snap.data ?? [];
            if (lista.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.event,
                          size: 80,
                          color: AppColors.granate.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      const Text('Sin eventos',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.granate)),
                      const SizedBox(height: 8),
                      Text(
                        _esAdmin
                            ? 'Toca el botón + para agregar el primero'
                            : 'El admin aún no ha publicado eventos',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppColors.negro.withOpacity(0.6)),
                      ),
                    ],
                  ),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: lista.length,
              itemBuilder: (context, i) {
                final e = lista[i];
                final pasado = e.fecha.isBefore(DateTime.now());
                final nota = _usuario?.notaEvento(e.id) ?? '';
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Opacity(
                    opacity: pasado ? 0.55 : 1,
                    child: Column(
                      children: [
                        ListTile(
                          leading: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: pasado
                                  ? AppColors.negro
                                  : AppColors.granate,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${e.fecha.day}',
                                  style: const TextStyle(
                                      color: AppColors.dorado,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  _mes(e.fecha.month),
                                  style: const TextStyle(
                                      color: AppColors.dorado,
                                      fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          title: Text(e.titulo,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.negro)),
                          subtitle: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('${_hora(e.fecha)} · ${e.lugar}'),
                              if (e.descripcion.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(e.descripcion,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: AppColors.negro
                                            .withOpacity(0.7))),
                              ],
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Nota personal
                              IconButton(
                                icon: Icon(
                                  nota.isEmpty
                                      ? Icons.sticky_note_2_outlined
                                      : Icons.sticky_note_2,
                                  color: nota.isEmpty
                                      ? AppColors.negro.withOpacity(0.4)
                                      : AppColors.dorado,
                                ),
                                tooltip: 'Mi nota personal',
                                onPressed: () => _editarNota(e),
                              ),
                              if (_esAdmin)
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert,
                                      color: AppColors.granate),
                                  onSelected: (v) {
                                    if (v == 'editar') {
                                      _editar(e);
                                    } else if (v == 'eliminar') {
                                      _eliminar(e);
                                    }
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                      value: 'editar',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, size: 20),
                                          SizedBox(width: 8),
                                          Text('Editar'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'eliminar',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete_outline,
                                              size: 20),
                                          SizedBox(width: 8),
                                          Text('Eliminar'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        // Nota visible
                        if (nota.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.fromLTRB(
                                12, 0, 12, 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.dorado.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: AppColors.dorado
                                      .withOpacity(0.5)),
                            ),
                            child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.sticky_note_2,
                                    size: 16, color: AppColors.granate),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    nota,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontStyle: FontStyle.italic,
                                      color: AppColors.negro,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _mes(int m) {
    const meses = [
      '', 'ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN',
      'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC'
    ];
    return meses[m];
  }

  String _hora(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}