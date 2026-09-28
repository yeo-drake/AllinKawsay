import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  final _compositor = TextEditingController();
  final _ritmo = TextEditingController();
  final _region = TextEditingController();
  final _numerofonia = TextEditingController();
  final _descripcion = TextEditingController();

  File? _pdf;
  File? _audio;
  bool _guardando = false;
  String _estado = '';

  Future<void> _elegirPDF() async {
    final r = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (r != null && r.files.single.path != null) {
      setState(() => _pdf = File(r.files.single.path!));
    }
  }

  Future<void> _elegirAudio() async {
    final r = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );
    if (r != null && r.files.single.path != null) {
      setState(() => _audio = File(r.files.single.path!));
    }
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
        compositor: _compositor.text.trim(),
        ritmo: _ritmo.text.trim(),
        region: _region.text.trim(),
        numerofonia: _numerofonia.text.trim(),
        audioUrl: '',
        pdfUrl: '',
        descripcion: _descripcion.text.trim(),
        creadoPor: user.uid,
        creadorNombre: user.displayName ?? user.email ?? 'Anónimo',
      ));

      String pdfUrl = '';
      String audioUrl = '';

      if (_pdf != null) {
        setState(() => _estado = 'Subiendo partitura...');
        pdfUrl = await storage.subirPDF(_pdf!, id);
      }
      if (_audio != null) {
        setState(() => _estado = 'Subiendo audio...');
        audioUrl = await storage.subirAudio(_audio!, id);
      }

      if (pdfUrl.isNotEmpty || audioUrl.isNotEmpty) {
        await service.actualizar(id, {
          'pdfUrl': pdfUrl,
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
          TextField(
            controller: _titulo,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
                labelText: 'Título *', prefixIcon: Icon(Icons.music_note)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _compositor,
            decoration: const InputDecoration(
                labelText: 'Compositor', prefixIcon: Icon(Icons.person)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ritmo,
            decoration: const InputDecoration(
                labelText: 'Ritmo (huayño, sikuri, etc.)',
                prefixIcon: Icon(Icons.graphic_eq)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _region,
            decoration: const InputDecoration(
                labelText: 'Región', prefixIcon: Icon(Icons.place)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _numerofonia,
            maxLines: 3,
            decoration: const InputDecoration(
                labelText: 'Numerofonía (ej: 5 5 6 5 | 3 3 5 3)',
                prefixIcon: Icon(Icons.numbers)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descripcion,
            maxLines: 3,
            decoration: const InputDecoration(
                labelText: 'Descripción',
                prefixIcon: Icon(Icons.description)),
          ),
          const SizedBox(height: 24),
          _archivoBtn(
            icono: Icons.picture_as_pdf,
            texto: _pdf == null
                ? 'Elegir partitura PDF'
                : 'PDF: ${_pdf!.path.split('/').last}',
            onTap: _elegirPDF,
            activo: _pdf != null,
          ),
          const SizedBox(height: 12),
          _archivoBtn(
            icono: Icons.audiotrack,
            texto: _audio == null
                ? 'Elegir audio (MP3)'
                : 'Audio: ${_audio!.path.split('/').last}',
            onTap: _elegirAudio,
            activo: _audio != null,
          ),
          const SizedBox(height: 32),
          if (_guardando)
            Column(
              children: [
                const CircularProgressIndicator(color: AppColors.granate),
                const SizedBox(height: 8),
                Text(_estado,
                    style:
                        const TextStyle(color: AppColors.granate)),
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

  Widget _archivoBtn({
    required IconData icono,
    required String texto,
    required VoidCallback onTap,
    required bool activo,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icono, color: activo ? Colors.green : AppColors.granate),
      label: Text(
        texto,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            color: activo ? Colors.green : AppColors.granate),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(
            color: activo ? Colors.green : AppColors.granate, width: 1.5),
      ),
    );
  }
}