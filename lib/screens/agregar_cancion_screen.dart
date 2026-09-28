import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/cancion.dart';
import '../services/cancion_service.dart';
import '../services/storage_service.dart';
import '../theme/colors.dart';

class AgregarCancionScreen extends StatefulWidget {
  const AgregarCancionScreen({super.key});

  @override
  State<AgregarCancionScreen> createState() => _AgregarCancionScreenState();
}

class _AgregarCancionScreenState extends State<AgregarCancionScreen> {
  final _titulo = TextEditingController();
  final _autor = TextEditingController();
  final _ritmo = TextEditingController();
  final _region = TextEditingController();
  final _numerofonia = TextEditingController();
  final _letra = TextEditingController();
  final _descripcion = TextEditingController();
  final _tagCtrl = TextEditingController();

  String _tipo = 'original';
  final List<String> _tags = [];
  File? _imagen;
  File? _audio;
  bool _guardando = false;
  String _estado = '';

  Future<void> _elegirImagen({bool camara = false}) async {
    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: camara ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 80,
    );
    if (x != null) setState(() => _imagen = File(x.path));
  }

  Future<void> _elegirAudio() async {
    final r = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );
    if (r != null && r.files.single.path != null) {
      setState(() => _audio = File(r.files.single.path!));
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
      _estado = 'Guardando...';
    });

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final service = CancionService();
      final storage = StorageService();

      final id = await service.agregar(Cancion(
        id: '',
        titulo: _titulo.text.trim(),
        autor: _autor.text.trim(),
        tipo: _tipo,
        ritmo: _ritmo.text.trim(),
        region: _region.text.trim(),
        numerofonia: _numerofonia.text.trim(),
        letra: _letra.text.trim(),
        imagenUrl: '',
        audioUrl: '',
        descripcion: _descripcion.text.trim(),
        tags: _tags,
        creadoPor: user.uid,
        creadorNombre: user.displayName ?? user.email ?? 'Anónimo',
      ));

      String imagenUrl = '';
      String audioUrl = '';

      if (_imagen != null) {
        setState(() => _estado = 'Subiendo partitura...');
        imagenUrl = await storage.subirPartitura(_imagen!, id);
      }
      if (_audio != null) {
        setState(() => _estado = 'Subiendo audio...');
        audioUrl = await storage.subirAudio(_audio!, id);
      }

      if (imagenUrl.isNotEmpty || audioUrl.isNotEmpty) {
        await service.actualizar(id, {
          'imagenUrl': imagenUrl,
          'audioUrl': audioUrl,
        });
      }

      if (mounted) {
        _snack('¡Canción guardada!');
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
      appBar: AppBar(title: const Text('AGREGAR CANCIÓN')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // === IMAGEN ===
          const Text('Partitura (imagen)',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.granate)),
          const SizedBox(height: 8),
          if (_imagen != null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_imagen!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    style: IconButton.styleFrom(
                        backgroundColor: Colors.black54),
                    onPressed: () => setState(() => _imagen = null),
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _guardando
                        ? null
                        : () => _elegirImagen(camara: false),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galería'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _guardando
                        ? null
                        : () => _elegirImagen(camara: true),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Cámara'),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 20),

          // === TÍTULO ===
          TextField(
            controller: _titulo,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
                labelText: 'Título *',
                prefixIcon: Icon(Icons.music_note)),
          ),
          const SizedBox(height: 12),

          // === AUTOR ===
          TextField(
            controller: _autor,
            decoration: const InputDecoration(
                labelText: 'Autor', prefixIcon: Icon(Icons.person)),
          ),
          const SizedBox(height: 12),

          // === TIPO ===
          const Text('Tipo',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.granate)),
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

          // === RITMO ===
          TextField(
            controller: _ritmo,
            decoration: const InputDecoration(
                labelText: 'Ritmo (huayño, sikuri, etc.)',
                prefixIcon: Icon(Icons.graphic_eq)),
          ),
          const SizedBox(height: 12),

          // === REGIÓN ===
          TextField(
            controller: _region,
            decoration: const InputDecoration(
                labelText: 'Región', prefixIcon: Icon(Icons.place)),
          ),
          const SizedBox(height: 12),

          // === TAGS ===
          const Text('Tags (para búsqueda)',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.granate)),
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
          const SizedBox(height: 12),

          // === NUMEROFONÍA ===
          TextField(
            controller: _numerofonia,
            maxLines: 3,
            decoration: const InputDecoration(
                labelText: 'Numerofonía (ej: 5 5 6 5 | 3 3 5 3)',
                prefixIcon: Icon(Icons.numbers)),
          ),
          const SizedBox(height: 12),

          // === LETRA ===
          TextField(
            controller: _letra,
            maxLines: 6,
            decoration: const InputDecoration(
                labelText: 'Letra de la canción',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.text_fields)),
          ),
          const SizedBox(height: 12),

          // === DESCRIPCIÓN ===
          TextField(
            controller: _descripcion,
            maxLines: 3,
            decoration: const InputDecoration(
                labelText: 'Notas / descripción',
                prefixIcon: Icon(Icons.description)),
          ),
          const SizedBox(height: 20),

          // === AUDIO ===
          const Text('Audio',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.granate)),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _guardando ? null : _elegirAudio,
            icon: Icon(Icons.audiotrack,
                color:
                    _audio != null ? Colors.green : AppColors.granate),
            label: Text(
              _audio == null
                  ? 'Elegir audio (MP3)'
                  : 'Audio: ${_audio!.path.split('/').last}',
              style: TextStyle(
                  color: _audio != null
                      ? Colors.green
                      : AppColors.granate),
              overflow: TextOverflow.ellipsis,
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(
                  color: _audio != null
                      ? Colors.green
                      : AppColors.granate,
                  width: 1.5),
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
              label: const Text('GUARDAR CANCIÓN',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}