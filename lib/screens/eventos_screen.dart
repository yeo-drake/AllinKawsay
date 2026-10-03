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
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(title: const Text('PRÓXIMOS EVENTOS')),
      floatingActionButton: _esAdmin
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AgregarEventoScreen()),
              ),
              child: const Icon(Icons.add, size: 26),
            )
          : null,
      body: WatermarkOverlay(
        opacity: 0.04,
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
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.granate.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.event_busy,
                            size: 48,
                            color: AppColors.granate.withOpacity(0.4)),
                      ),
                      const SizedBox(height: 20),
                      const Text('Sin eventos',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.granate,
                              letterSpacing: 0.5)),
                      const SizedBox(height: 8),
                      Text(
                        _esAdmin
                            ? 'Toca el botón + para agregar el primero'
                            : 'El admin aún no ha publicado eventos',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: onSurface.withOpacity(0.55),
                            fontSize: 13),
                      ),
                    ],
                  ),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: lista.length,
              itemBuilder: (context, i) {
                final e = lista[i];
                final pasado = e.fecha.isBefore(DateTime.now());
                final nota = _usuario?.notaEvento(e.id) ?? '';
                return _tarjetaEvento(
                    context, e, pasado, nota, onSurface);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _tarjetaEvento(BuildContext context, Evento e, bool pasado,
      String nota, Color onSurface) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Opacity(
        opacity: pasado ? 0.6 : 1,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardColor(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: pasado
                  ? onSurface.withOpacity(0.15)
                  : AppColors.dorado.withOpacity(0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(pasado ? 0.02 : 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fecha cuadrada
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: pasado
                            ? const LinearGradient(colors: [
                                Color(0xFF424242),
                                Color(0xFF212121)
                              ])
                            : AppColors.gradienteGranate,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (pasado ? Colors.black : AppColors.granate)
                                    .withOpacity(0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${e.fecha.day}',
                            style: const TextStyle(
                                color: AppColors.dorado,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                height: 1),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _mes(e.fecha.month),
                            style: TextStyle(
                                color: AppColors.dorado.withOpacity(0.9),
                                fontSize: 10,
                                letterSpacing: 2,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.titulo,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: onSurface,
                                fontSize: 16,
                                letterSpacing: 0.2),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.access_time,
                                  size: 12,
                                  color: onSurface.withOpacity(0.5)),
                              const SizedBox(width: 4),
                              Text(_hora(e.fecha),
                                  style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          onSurface.withOpacity(0.65))),
                              if (e.lugar.isNotEmpty) ...[
                                const SizedBox(width: 12),
                                Icon(Icons.place,
                                    size: 12,
                                    color: onSurface.withOpacity(0.5)),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(e.lugar,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: onSurface
                                              .withOpacity(0.65))),
                                ),
                              ],
                            ],
                          ),
                          if (e.descripcion.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(e.descripcion,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: onSurface.withOpacity(0.55),
                                    height: 1.4)),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Acciones
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                        color: AppColors.dorado.withOpacity(0.15)),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => _editarNota(e),
                      icon: Icon(
                        nota.isEmpty
                            ? Icons.sticky_note_2_outlined
                            : Icons.sticky_note_2,
                        size: 16,
                        color: nota.isEmpty
                            ? onSurface.withOpacity(0.4)
                            : AppColors.dorado,
                      ),
                      label: Text(
                        nota.isEmpty ? 'Nota' : 'Mi nota',
                        style: TextStyle(
                            fontSize: 12,
                            color: nota.isEmpty
                                ? onSurface.withOpacity(0.5)
                                : AppColors.granate,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    const Spacer(),
                    if (_esAdmin)
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert,
                            color: onSurface.withOpacity(0.5),
                            size: 20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
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
                                SizedBox(width: 10),
                                Text('Editar'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'eliminar',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline,
                                    size: 20, color: Colors.red),
                                SizedBox(width: 10),
                                Text('Eliminar',
                                    style:
                                        TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              // Nota
              if (nota.isNotEmpty)
                Container(
                  margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      AppColors.dorado.withOpacity(0.12),
                      AppColors.dorado.withOpacity(0.06),
                    ]),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.dorado.withOpacity(0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.sticky_note_2,
                          size: 14, color: AppColors.granate),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          nota,
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: onSurface.withOpacity(0.85),
                            height: 1.4,
                          ),
                        ),
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