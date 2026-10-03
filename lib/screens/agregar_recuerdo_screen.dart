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
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final totalFotos =
        _fotosExistentes.length + _fotosNuevas.length;

    return Scaffold(
      appBar: AppBar(
        title:
            Text(_esEdicion ? 'EDITAR RECUERDO' : 'AGREGAR RECUERDO'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // Header
          _header(onSurface, _esEdicion),
          const SizedBox(height: 20),

          // Sección: datos
          _seccion(Icons.info_outline, 'INFORMACIÓN'),
          const SizedBox(height: 10),

          TextField(
            controller: _titulo,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Título *',
              prefixIcon: Icon(Icons.title),
              hintText: 'Ej: Viaje a Puno 2024',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descripcion,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Descripción',
              prefixIcon: Icon(Icons.notes),
              alignLabelWithHint: true,
              hintText: 'Qué pasó, quiénes fueron, anécdotas...',
            ),
          ),
          const SizedBox(height: 24),

          // Sección: fotos
          Row(
            children: [
              _seccion(Icons.photo_library, 'FOTOS'),
              const Spacer(),
              if (totalFotos > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.granate.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$totalFotos foto${totalFotos > 1 ? "s" : ""}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.granate,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Botones agregar fotos
          Row(
            children: [
              Expanded(
                child: _botonFoto(
                  Icons.photo_library_outlined,
                  'Galería',
                  _guardando ? null : _elegirFotos,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _botonFoto(
                  Icons.camera_alt_outlined,
                  'Cámara',
                  _guardando ? null : _tomarFoto,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Preview fotos
          if (totalFotos > 0)
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (int i = 0; i < _fotosExistentes.length; i++)
                    _fotoPreview(
                      onDelete: () => setState(
                          () => _fotosExistentes.removeAt(i)),
                      child: Image.network(
                        _fotosExistentes[i],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.grisClaro,
                          child: const Icon(Icons.broken_image,
                              color: AppColors.granate),
                        ),
                      ),
                    ),
                  for (int i = 0; i < _fotosNuevas.length; i++)
                    _fotoPreview(
                      onDelete: () =>
                          setState(() => _fotosNuevas.removeAt(i)),
                      child: Image.file(
                        _fotosNuevas[i],
                        fit: BoxFit.cover,
                      ),
                    ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.granate.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.granate.withOpacity(0.2),
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.photo_library_outlined,
                      color: onSurface.withOpacity(0.3), size: 36),
                  const SizedBox(height: 8),
                  Text(
                    'Sin fotos aún',
                    style: TextStyle(
                        color: onSurface.withOpacity(0.5),
                        fontSize: 13,
                        fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 32),

          // Estado de subida
          if (_guardando)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.granate.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.granate.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: AppColors.granate,
                      strokeWidth: 2.5,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(_estado,
                        style: const TextStyle(
                            color: AppColors.granate,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          if (_guardando) const SizedBox(height: 16),

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
                    ? 'SUBIENDO...'
                    : (_esEdicion
                        ? 'GUARDAR CAMBIOS'
                        : 'GUARDAR RECUERDO'),
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
            child: Icon(
                esEdicion
                    ? Icons.photo_library
                    : Icons.add_photo_alternate,
                color: AppColors.dorado,
                size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(esEdicion ? 'Editando recuerdo' : 'Nuevo recuerdo',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: onSurface,
                        fontSize: 15,
                        letterSpacing: 0.3)),
                const SizedBox(height: 2),
                Text(
                  esEdicion
                      ? 'Modifica las fotos o los datos'
                      : 'Comparte fotos y anécdotas del grupo',
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

  Widget _seccion(IconData icono, String titulo) {
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

  Widget _botonFoto(
      IconData icono, String texto, VoidCallback? onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.cardColor(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.dorado.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icono, color: AppColors.granate, size: 18),
              const SizedBox(width: 8),
              Text(
                texto,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.granate,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fotoPreview({
    required VoidCallback onDelete,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 120,
              height: 120,
              child: child,
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close,
                    size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
