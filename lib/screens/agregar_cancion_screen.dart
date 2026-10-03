import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/cancion.dart';
import '../models/categoria.dart';
import '../models/numerofonia.dart';
import '../services/cancion_service.dart';
import '../services/categoria_service.dart';
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
  String _categoriaId = '';
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
      _categoriaId = c.categoriaId;
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
          categoriaId: _categoriaId,
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
        'categoriaId': _categoriaId,
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
  final onSurface = Theme.of(context).colorScheme.onSurface;

  return Scaffold(
    appBar: AppBar(
      title: Text(_esEdicion ? 'EDITAR CANCIÓN' : 'AGREGAR CANCIÓN'),
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        _header(onSurface, _esEdicion),
        const SizedBox(height: 20),

        // === INFO BÁSICA ===
        _seccion(Icons.info_outline, 'INFORMACIÓN BÁSICA'),
        const SizedBox(height: 10),

        TextField(
          controller: _titulo,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Título *',
            prefixIcon: Icon(Icons.music_note),
            hintText: 'Ej: El Cóndor Pasa',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _autor,
          decoration: const InputDecoration(
            labelText: 'Autor',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 12),

        // Tipo
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.cardColor(context),
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: AppColors.dorado.withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.granate.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.category_outlined,
                        color: AppColors.granate, size: 14),
                  ),
                  const SizedBox(width: 8),
                  const Text('Tipo',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.granate,
                          letterSpacing: 1)),
                ],
              ),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                      value: 'original', label: Text('Original')),
                  ButtonSegment(
                      value: 'adaptacion', label: Text('Adaptación')),
                ],
                selected: {_tipo},
                onSelectionChanged: (s) =>
                    setState(() => _tipo = s.first),
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: AppColors.granate,
                  selectedForegroundColor: AppColors.dorado,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        TextField(
          controller: _ritmo,
          decoration: const InputDecoration(
            labelText: 'Ritmo',
            prefixIcon: Icon(Icons.graphic_eq),
            hintText: 'Ej: Huayño, Sikuri, Carnaval',
          ),
        ),
        const SizedBox(height: 12),

        // Categoría
        StreamBuilder<List<Categoria>>(
          stream: CategoriaService().listar(),
          builder: (context, snap) {
            final categorias = snap.data ?? [];
            return DropdownButtonFormField<String>(
              value: _categoriaId.isEmpty ? null : _categoriaId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                prefixIcon: Icon(Icons.folder_outlined),
              ),
              dropdownColor: AppColors.cardColor(context),
              borderRadius: BorderRadius.circular(16),
              items: [
                const DropdownMenuItem<String>(
                  value: '',
                  child: Text('Sin categoría'),
                ),
                ...categorias.map((cat) => DropdownMenuItem<String>(
                      value: cat.id,
                      child: Text('${cat.emoji} ${cat.nombre}'),
                    )),
              ],
              onChanged: (v) =>
                  setState(() => _categoriaId = v ?? ''),
            );
          },
        ),
        const SizedBox(height: 24),

        // === TAGS ===
        _seccion(Icons.tag, 'TAGS PARA BÚSQUEDA'),
        const SizedBox(height: 10),

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
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.gradienteGranate,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.granate.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: _agregarTag,
                icon: const Icon(Icons.add,
                    color: AppColors.dorado, size: 22),
                tooltip: 'Agregar tag',
              ),
            ),
          ],
        ),
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tags
                .map((t) => Chip(
                      label: Text(t),
                      labelStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dorado),
                      deleteIcon: const Icon(Icons.close,
                          size: 16, color: AppColors.dorado),
                      onDeleted: () =>
                          setState(() => _tags.remove(t)),
                      backgroundColor: AppColors.granate,
                      side: BorderSide.none,
                    ))
                .toList(),
          ),
        ],
        const SizedBox(height: 24),

          // === NUMEROFONÍA ===
          _seccion(Icons.grid_on, 'NUMEROFONÍA'),
          const SizedBox(height: 10),

          EditorNumerofonia(
            inicial: _numerofoniaEstrofas,
            autor: _autor.text.trim(),
            ritmo: _ritmo.text.trim(),
            onChanged: (v) => _numerofoniaEstrofas = v,
          ),
          const SizedBox(height: 24),

          // === LETRA Y DESCRIPCIÓN ===
          _seccion(Icons.text_fields, 'LETRA Y DESCRIPCIÓN'),
          const SizedBox(height: 10),

          TextField(
            controller: _letra,
            maxLines: 6,
            style: TextStyle(color: onSurface, height: 1.5),
            decoration: const InputDecoration(
              labelText: 'Letra de la canción',
              alignLabelWithHint: true,
              hintText: 'Escribí la letra acá...',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descripcion,
            maxLines: 3,
            style: TextStyle(color: onSurface, height: 1.5),
            decoration: const InputDecoration(
              labelText: 'Descripción / notas',
              alignLabelWithHint: true,
              hintText: 'Detalles adicionales, historia, etc.',
            ),
          ),
          const SizedBox(height: 24),

          // === AUDIO ===
          _seccion(Icons.audiotrack, 'AUDIO'),
          const SizedBox(height: 10),

          if (_audioNuevo != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: Colors.green.withOpacity(0.4), width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle,
                        color: Colors.green, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Audio listo',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                                fontSize: 13)),
                        const SizedBox(height: 2),
                        Text(
                          _audioNuevo!.path.split('/').last,
                          style: TextStyle(
                              fontSize: 11,
                              color: onSurface.withOpacity(0.6)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () =>
                        setState(() => _audioNuevo = null),
                  ),
                ],
              ),
            )
          else
            _botonConIcono(
              icono: _audioUrlActual.isNotEmpty
                  ? Icons.audiotrack
                  : Icons.upload_file,
              texto: _audioUrlActual.isNotEmpty
                  ? 'Reemplazar audio actual'
                  : 'Elegir audio (MP3)',
              onTap: _guardando ? null : _elegirAudio,
            ),
          const SizedBox(height: 24),

          // === VIDEO ===
          _seccion(Icons.video_library_outlined, 'VIDEO (OPCIONAL)'),
          const SizedBox(height: 10),

          TextField(
            controller: _videoCtrl,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'Link de YouTube, Drive, etc.',
              hintText: 'https://youtube.com/watch?v=...',
              prefixIcon: Icon(Icons.link),
            ),
          ),
          const SizedBox(height: 32),

          // Estado
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
                    ? 'GUARDANDO...'
                    : (_esEdicion
                        ? 'GUARDAR CAMBIOS'
                        : 'GUARDAR CANCIÓN'),
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
                esEdicion ? Icons.edit : Icons.music_note,
                color: AppColors.dorado,
                size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    esEdicion
                        ? 'Editando canción'
                        : 'Nueva canción',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: onSurface,
                        fontSize: 15,
                        letterSpacing: 0.3)),
                const SizedBox(height: 2),
                Text(
                  esEdicion
                      ? 'Modifica los datos de la canción'
                      : 'Completa los datos del cancionero',
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

  Widget _botonConIcono({
    required IconData icono,
    required String texto,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.cardColor(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.dorado.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Icon(icono, color: AppColors.granate, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  texto,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.granate,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios,
                  size: 14, color: AppColors.granate.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    );
  }
}