import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/recuerdo.dart';
import '../services/recuerdo_service.dart';
import '../services/storage_service.dart';
import '../theme/colors.dart';

class AgregarRecuerdoScreen extends StatefulWidget {
  final Recuerdo? recuerdo;
  const AgregarRecuerdoScreen({super.key, this.recuerdo});

  @override
  State<AgregarRecuerdoScreen> createState() =>
      _AgregarRecuerdoScreenState();
}

class _AgregarRecuerdoScreenState extends State<AgregarRecuerdoScreen> {
  final _titulo = TextEditingController();
  final _descripcion = TextEditingController();
  final List<File> _fotosNuevas = [];
  final List<String> _fotosExistentes = [];
  bool _guardando = false;
  String _estado = '';

  bool get _esEdicion => widget.recuerdo != null;

  @override
  void initState() {
    super.initState();
    if (_esEdicion) {
      final r = widget.recuerdo!;
      _titulo.text = r.titulo;
      _descripcion.text = r.descripcion;
      _fotosExistentes.addAll(r.fotos);
    }
  }

  @override
  void dispose() {
    _titulo.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  Future<void> _elegirFotos() async {
    final picker = ImagePicker();
    final lista = await picker.pickMultiImage(imageQuality: 70);
    if (lista.isNotEmpty) {
      setState(() {
        _fotosNuevas.addAll(lista.map((x) => File(x.path)));
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
      setState(() => _fotosNuevas.add(File(foto.path)));
    }
  }

  Future<void> _guardar() async {
    if (_titulo.text.trim().isEmpty) {
      _snack('El título es obligatorio');
      return;
    }
    if (_fotosExistentes.isEmpty && _fotosNuevas.isEmpty) {
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
      final service = RecuerdoService();

      final urls = <String>[..._fotosExistentes];
      final carpeta = 'recuerdos/${DateTime.now().millisecondsSinceEpoch}';

      for (int i = 0; i < _fotosNuevas.length; i++) {
        setState(() => _estado =
            'Subiendo foto ${i + 1} de ${_fotosNuevas.length}...');
        final url = await storage.subirFoto(_fotosNuevas[i], carpeta);
        urls.add(url);
      }

      setState(() => _estado = 'Guardando...');

      if (_esEdicion) {
        await service.actualizar(widget.recuerdo!.id, {
          'titulo': _titulo.text.trim(),
          'descripcion': _descripcion.text.trim(),
          'fotos': urls,
        });
      } else {
        await service.agregar(Recuerdo(
          id: '',
          titulo: _titulo.text.trim(),
          descripcion: _descripcion.text.trim(),
          fotos: urls,
          creadoPor: user.uid,
          creadorNombre: user.displayName ?? user.email ?? 'Anónimo',
        ));
      }

      if (mounted) {
        _snack(_esEdicion
            ? '¡Recuerdo actualizado!'
            : '¡Recuerdo guardado!');
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
    final totalFotos = _fotosExistentes.length + _fotosNuevas.length;
    return Scaffold(
      appBar: AppBar(
        title:
            Text(_esEdicion ? 'EDITAR RECUERDO' : 'AGREGAR RECUERDO'),
      ),
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
          if (totalFotos > 0) ...[
            Text('$totalFotos foto(s)',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.granate)),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (int i = 0; i < _fotosExistentes.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              _fotosExistentes[i],
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 120,
                                height: 120,
                                color: AppColors.grisClaro,
                                child: const Icon(Icons.broken_image,
                                    color: AppColors.granate),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => setState(() =>
                                  _fotosExistentes.removeAt(i)),
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
                      ),
                    ),
                  for (int i = 0; i < _fotosNuevas.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              _fotosNuevas[i],
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => setState(
                                  () => _fotosNuevas.removeAt(i)),
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
                      ),
                    ),
                ],
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
                _esEdicion ? 'GUARDAR CAMBIOS' : 'GUARDAR RECUERDO',
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