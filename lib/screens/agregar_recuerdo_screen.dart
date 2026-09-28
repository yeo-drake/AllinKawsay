import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/recuerdo.dart';
import '../services/recuerdo_service.dart';
import '../services/storage_service.dart';
import '../theme/colors.dart';

class AgregarRecuerdoScreen extends StatefulWidget {
  const AgregarRecuerdoScreen({super.key});

  @override
  State<AgregarRecuerdoScreen> createState() =>
      _AgregarRecuerdoScreenState();
}

class _AgregarRecuerdoScreenState extends State<AgregarRecuerdoScreen> {
  final _titulo = TextEditingController();
  final _descripcion = TextEditingController();
  final List<File> _fotos = [];
  bool _guardando = false;
  String _estado = '';

  Future<void> _elegirFotos() async {
    final picker = ImagePicker();
    final lista = await picker.pickMultiImage(imageQuality: 70);
    if (lista.isNotEmpty) {
      setState(() {
        _fotos.addAll(lista.map((x) => File(x.path)));
      });
    }
  }

  Future<void> _tomarFoto() async {
    final picker = ImagePicker();
    final foto = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );
    if (foto != null) {
      setState(() => _fotos.add(File(foto.path)));
    }
  }

  Future<void> _guardar() async {
    if (_titulo.text.trim().isEmpty) {
      _snack('El título es obligatorio');
      return;
    }
    if (_fotos.isEmpty) {
      _snack('Agrega al menos una foto');
      return;
    }
    setState(() {
      _guardando = true;
      _estado = 'Subiendo fotos...';
    });

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final storage = StorageService();
      final urls = <String>[];

      for (int i = 0; i < _fotos.length; i++) {
        setState(() =>
            _estado = 'Subiendo foto ${i + 1} de ${_fotos.length}...');
        final carpeta = 'recuerdos/${DateTime.now().millisecondsSinceEpoch}';
        final url = await storage.subirFoto(_fotos[i], carpeta);
        urls.add(url);
      }

      setState(() => _estado = 'Guardando recuerdo...');
      await RecuerdoService().agregar(Recuerdo(
        id: '',
        titulo: _titulo.text.trim(),
        descripcion: _descripcion.text.trim(),
        fotos: urls,
        creadoPor: user.uid,
        creadorNombre: user.displayName ?? user.email ?? 'Anónimo',
      ));

      if (mounted) {
        _snack('¡Recuerdo guardado!');
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
      appBar: AppBar(title: const Text('AGREGAR RECUERDO')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titulo,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
                labelText: 'Título (ej: Viaje a Puno 2024)',
                prefixIcon: Icon(Icons.title)),
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
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _guardando ? null : _elegirFotos,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galería'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _guardando ? null : _tomarFoto,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Cámara'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_fotos.isNotEmpty) ...[
            Text('${_fotos.length} foto(s) seleccionada(s)',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.granate)),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _fotos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(_fotos[i],
                            width: 100, height: 100, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _fotos.removeAt(i)),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 24),
          if (_guardando)
            Column(
              children: [
                const CircularProgressIndicator(
                    color: AppColors.granate),
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
              label: const Text('GUARDAR RECUERDO',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}