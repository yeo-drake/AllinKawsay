import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/cancion.dart';
import '../models/numerofonia.dart';
import '../services/cancion_service.dart';
import '../services/storage_service.dart';
import '../theme/colors.dart';
import '../widgets/editor_numerofonia.dart';

class AgregarCancionScreen extends StatefulWidget {
  final Cancion? cancion;
  const AgregarCancionScreen({super.key, this.cancion});

  @override
  State<AgregarCancionScreen> createState() => _AgregarCancionScreenState();
}

class _AgregarCancionScreenState extends State<AgregarCancionScreen> {
  final _titulo = TextEditingController();
  final _autor = TextEditingController();
  final _ritmo = TextEditingController();
  final _letra = TextEditingController();
  final _descripcion = TextEditingController();
  final _tagCtrl = TextEditingController();
  final _videoCtrl = TextEditingController();

  String _tipo = 'original';
  final List<String> _tags = [];
  List<EstrofaNumerofonia> _numerofoniaEstrofas = [];
  File? _audioNuevo;
  String _audioUrlActual = '';
  bool _guardando = false;
  String _estado = '';

  bool get _esEdicion => widget.cancion != null;

  @override
  void initState() {
    super.initState();
    if (_esEdicion) {
      final c = widget.cancion!;
      _titulo.text = c.titulo;
      _autor.text = c.autor;
      _ritmo.text = c.ritmo;
      _letra.text = c.letra;
      _descripcion.text = c.descripcion;
      _videoCtrl.text = c.videoUrl;
      _tipo = c.tipo;
      _tags.addAll(c.tags);
      _audioUrlActual = c.audioUrl;
      _numerofoniaEstrofas =
          c.estrofas.map((e) => e.copy()).toList();
    }
  }

  @override
  void dispose() {
    _titulo.dispose();
    _autor.dispose();
    _ritmo.dispose();
    _letra.dispose();
    _descripcion.dispose();
    _tagCtrl.dispose();
    _videoCtrl.dispose();
    super.dispose();
  }

  Future<void> _elegirAudio() async {
    final r = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (r != null && r.files.single.path != null) {
      setState(() => _audioNuevo = File(r.files.single.path!));
    }
  }

  void _agregarTag() {
    final t = _tagCtrl.text.trim().toLowerCase();
    if (t.isEmpty) return;
    if (!_tags.contains(t)) {
      setState(() => _tags.add(t));
    }
    _tagCtrl.clear();
  }

  Future<void> _guardar() async {
    if (_titulo.text.trim().isEmpty) {
      _snack('El título es obligatorio');
      return;
    }
    setState(() {
      _guardando = true;
      _estado = _esEdicion ? 'Actualizando...' : 'Guardando...';
    });

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final service = CancionService();
      final storage = StorageService();

      String id = widget.cancion?.id ?? '';
      String audioUrl = _audioUrlActual;

      if (!_esEdicion) {
        id = await service.agregar(Cancion(
          id: '',
          titulo: _titulo.text.trim(),
          autor: _autor.text.trim(),
          tipo: _tipo,
          ritmo: _ritmo.text.trim(),
          region: '',
          numerofonia: '',
          estrofas: _numerofoniaEstrofas,
          letra: _letra.text.trim(),
          imagenUrl: '',
          audioUrl: '',
          videoUrl: _videoCtrl.text.trim(),
          descripcion: _descripcion.text.trim(),
          tags: _tags,
          creadoPor: user.uid,
          creadorNombre: user.displayName ?? user.email ?? 'Anónimo',
        ));
      }

      if (_audioNuevo != null) {
        setState(() => _estado = 'Subiendo audio...');
        audioUrl = await storage.subirAudio(_audioNuevo!, id);
      }

      await service.actualizar(id, {
        'titulo': _titulo.text.trim(),
        'autor': _autor.text.trim(),
        'tipo': _tipo,
        'ritmo': _ritmo.text.trim(),
        'region': '',
        'numerofonia': '',
        'estrofas':
            _numerofoniaEstrofas.map((e) => e.toMap()).toList(),
        'letra': _letra.text.trim(),
        'descripcion': _descripcion.text.trim(),
        'tags': _tags,
        'imagenUrl': '',
        'audioUrl': audioUrl,
        'videoUrl': _videoCtrl.text.trim(),
      });

      if (mounted) {
        _snack(_esEdicion ? '¡Canción actualizada!' : '¡Canción guardada!');
        Navigator.pop(context);
      }
    } catch (e) {
      _snack('Error: $e');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  void _snack(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'EDITAR CANCIÓN' : 'AGREGAR CANCIÓN'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titulo,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
                labelText: 'Título *',
                prefixIcon: Icon(Icons.music_note)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _autor,
            decoration: const InputDecoration(
                labelText: 'Autor', prefixIcon: Icon(Icons.person)),
          ),
          const SizedBox(height: 12),
          const Text('Tipo',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.granate)),
          const SizedBox(height: 4),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'original', label: Text('Original')),
              ButtonSegment(value: 'adaptacion', label: Text('Adaptación')),
            ],
            selected: {_tipo},
            onSelectionChanged: (s) => setState(() => _tipo = s.first),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ritmo,
            decoration: const InputDecoration(
                labelText: 'Ritmo (huayño, sikuri, etc.)',
                prefixIcon: Icon(Icons.graphic_eq)),
          ),
          const SizedBox(height: 12),
          const Text('Tags (para búsqueda)',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.granate)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _tagCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Ej: carnaval, cusco, rápido',
                    prefixIcon: Icon(Icons.tag),
                  ),
                  onSubmitted: (_) => _agregarTag(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _agregarTag,
                icon: const Icon(Icons.add_circle,
                    color: AppColors.granate),
              ),
            ],
          ),
          if (_tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _tags
                  .map((t) => Chip(
                        label: Text(t),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () =>
                            setState(() => _tags.remove(t)),
                        backgroundColor:
                            AppColors.dorado.withOpacity(0.2),
                      ))
                  .toList(),
            ),
          ],
          const SizedBox(height: 16),
          EditorNumerofonia(
            inicial: _numerofoniaEstrofas,
            autor: _autor.text.trim(),
            ritmo: _ritmo.text.trim(),
            onChanged: (v) => _numerofoniaEstrofas = v,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _letra,
            maxLines: 6,
            decoration: const InputDecoration(
                labelText: 'Letra de la canción',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.text_fields)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descripcion,
            maxLines: 3,
            decoration: const InputDecoration(
                labelText: 'Descripción',
                prefixIcon: Icon(Icons.description)),
          ),
          const SizedBox(height: 20),
          const Text('Audio',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.granate)),
          const SizedBox(height: 8),
          if (_audioNuevo != null)
            OutlinedButton.icon(
              onPressed: () => setState(() => _audioNuevo = null),
              icon: const Icon(Icons.audiotrack, color: Colors.green),
              label: Text(
                'Nuevo audio: ${_audioNuevo!.path.split('/').last}',
                style: const TextStyle(color: Colors.green),
                overflow: TextOverflow.ellipsis,
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.green, width: 1.5),
              ),
            )
          else if (_esEdicion && _audioUrlActual.isNotEmpty)
            OutlinedButton.icon(
              onPressed: _elegirAudio,
              icon: const Icon(Icons.audiotrack,
                  color: AppColors.granate),
              label: const Text('Reemplazar audio actual'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(
                    color: AppColors.granate, width: 1.5),
              ),
            )
          else
            OutlinedButton.icon(
              onPressed: _elegirAudio,
              icon: const Icon(Icons.audiotrack,
                  color: AppColors.granate),
              label: const Text('Elegir audio (MP3)'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(
                    color: AppColors.granate, width: 1.5),
              ),
            ),
          const SizedBox(height: 16),
          // === VIDEO LINK ===
          const Text('Video (opcional)',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.granate)),
          const SizedBox(height: 8),
          TextField(
            controller: _videoCtrl,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'Link de YouTube, Drive, etc.',
              hintText: 'https://youtube.com/watch?v=...',
              prefixIcon: Icon(Icons.video_library),
            ),
          ),
          const SizedBox(height: 32),
          if (_guardando)
            Column(
              children: [
                const CircularProgressIndicator(
                    color: AppColors.granate),
                const SizedBox(height: 8),
                Text(_estado,
                    style: const TextStyle(color: AppColors.granate)),
                const SizedBox(height: 16),
              ],
            ),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: _guardando ? null : _guardar,
              icon: const Icon(Icons.save),
              label: Text(
                _esEdicion ? 'GUARDAR CAMBIOS' : 'GUARDAR CANCIÓN',
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