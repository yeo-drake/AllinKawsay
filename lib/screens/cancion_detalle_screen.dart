import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/cancion.dart';
import '../models/comentario.dart';
import '../services/comentario_service.dart';
import '../theme/colors.dart';
import '../widgets/numerofonia_widget.dart';

class CancionDetalleScreen extends StatefulWidget {
  final Cancion cancion;
  const CancionDetalleScreen({super.key, required this.cancion});

  @override
  State<CancionDetalleScreen> createState() => _CancionDetalleScreenState();
}

class _CancionDetalleScreenState extends State<CancionDetalleScreen> {
  final _player = AudioPlayer();
  bool _listo = false;
  String? _error;
  final _comentarioCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarAudio();
  }

  Future<void> _cargarAudio() async {
    if (widget.cancion.audioUrl.isEmpty) return;
    try {
      await _player.setUrl(widget.cancion.audioUrl);
      if (mounted) setState(() => _listo = true);
    } catch (e) {
      if (mounted) setState(() => _error = 'No se pudo cargar el audio');
    }
  }

  @override
  void dispose() {
    _player.dispose();
    _comentarioCtrl.dispose();
    super.dispose();
  }

  void _enviarComentario() async {
    final texto = _comentarioCtrl.text.trim();
    if (texto.isEmpty) return;
    final user = FirebaseAuth.instance.currentUser!;
    await ComentarioService().agregar(
      widget.cancion.id,
      Comentario(
        id: '',
        texto: texto,
        autorUid: user.uid,
        autorNombre: user.displayName ?? user.email ?? 'Anónimo',
      ),
    );
    _comentarioCtrl.clear();
    FocusScope.of(context).unfocus();
  }

  void _verImagen() {
    if (widget.cancion.imagenUrl.isEmpty) return;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(4),
        child: Stack(
          children: [
            InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: widget.cancion.imagenUrl,
                fit: BoxFit.contain,
                placeholder: (_, __) => const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.dorado),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: AppColors.dorado),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.cancion;
    return Scaffold(
      appBar: AppBar(title: Text(c.titulo)),
      body: ListView(
        children: [
          // === 1. IMAGEN DE PARTITURA ===
          if (c.imagenUrl.isNotEmpty)
            GestureDetector(
              onTap: _verImagen,
              child: Container(
                color: AppColors.grisClaro,
                child: CachedNetworkImage(
                  imageUrl: c.imagenUrl,
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                  placeholder: (_, __) => const SizedBox(
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(
                          color: AppColors.granate),
                    ),
                  ),
                  errorWidget: (_, __, ___) => const SizedBox(
                    height: 200,
                    child: Center(
                      child: Icon(Icons.broken_image,
                          size: 60, color: AppColors.granate),
                    ),
                  ),
                ),
              ),
            )
          else
            Container(
              height: 150,
              color: AppColors.grisClaro,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.image_not_supported,
                        size: 50,
                        color: AppColors.granate.withOpacity(0.4)),
                    const SizedBox(height: 8),
                    Text('Sin partitura subida',
                        style: TextStyle(
                            color:
                                AppColors.negro.withOpacity(0.5))),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          // === 2. AUDIO ===
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _audioPlayer(),
          ),

          const SizedBox(height: 24),

          // === 3. LETRA ===
          if (c.letra.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Letra',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.granate)),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                c.letra,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 16, height: 1.8, fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // === 4. NUMEROFONÍA (si hay) ===
          if (c.numerofonia.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(),
            ),
            NumerofoniaWidget(numerofonia: c.numerofonia),
            const SizedBox(height: 16),
          ],

          const Divider(),

          // === 5. INFO DESPLEGABLE ===
          ExpansionTile(
            leading: const Icon(Icons.info_outline,
                color: AppColors.granate),
            title: const Text('Información',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.granate)),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: [
                    _fila(Icons.music_note, 'Nombre', c.titulo),
                    _fila(Icons.person, 'Autor', c.autor.isEmpty ? '—' : c.autor),
                    _fila(
                        Icons.category,
                        'Tipo',
                        c.tipo == 'original'
                            ? 'Original'
                            : 'Adaptación'),
                    _fila(Icons.graphic_eq, 'Ritmo',
                        c.ritmo.isEmpty ? '—' : c.ritmo),
                    _fila(Icons.place, 'Región',
                        c.region.isEmpty ? '—' : c.region),
                    if (c.tags.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: c.tags
                              .map((t) => Chip(
                                    label: Text(t,
                                        style: const TextStyle(
                                            fontSize: 12)),
                                    backgroundColor:
                                        AppColors.dorado.withOpacity(0.2),
                                    padding: EdgeInsets.zero,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ))
                              .toList(),
                        ),
                      ),
                    if (c.creadorNombre.isNotEmpty)
                      _fila(Icons.upload, 'Subido por', c.creadorNombre),
                    if (c.descripcion.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Notas',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    AppColors.negro.withOpacity(0.7))),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(c.descripcion,
                            style: const TextStyle(height: 1.5)),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // === 6. COMENTARIOS DESPLEGABLE ===
          ExpansionTile(
            leading: const Icon(Icons.comment,
                color: AppColors.granate),
            title: const Text('Comentarios',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.granate)),
            children: [
              SizedBox(
                height: 300,
                child: _comentariosBody(),
              ),
              _comentarioInput(),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _audioPlayer() {
    if (widget.cancion.audioUrl.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.grisClaro,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.music_off,
                color: AppColors.granate.withOpacity(0.4)),
            const SizedBox(width: 12),
            Text('Sin audio subido',
                style: TextStyle(
                    color: AppColors.negro.withOpacity(0.5))),
          ],
        ),
      );
    }
    if (_error != null) {
      return Text(_error!,
          style: const TextStyle(color: AppColors.granate));
    }
    if (!_listo) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.granate));
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.negro,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          StreamBuilder<PlayerState>(
            stream: _player.playerStateStream,
            builder: (context, snap) {
              final playing = snap.data?.playing ?? false;
              final processing =
                  snap.data?.processingState == ProcessingState.loading ||
                      snap.data?.processingState == ProcessingState.buffering;
              return IconButton(
                iconSize: 64,
                icon: Icon(
                  processing
                      ? Icons.hourglass_top
                      : playing
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                  color: AppColors.dorado,
                ),
                onPressed: () {
                  if (playing) {
                    _player.pause();
                  } else {
                    _player.play();
                  }
                },
              );
            },
          ),
          StreamBuilder<Duration>(
            stream: _player.positionStream,
            builder: (context, snap) {
              final pos = snap.data ?? Duration.zero;
              final dur = _player.duration ?? Duration.zero;
              return Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.dorado,
                      thumbColor: AppColors.dorado,
                      inactiveTrackColor:
                          AppColors.dorado.withOpacity(0.2),
                    ),
                    child: Slider(
                      value: pos.inSeconds.toDouble().clamp(
                          0,
                          dur.inSeconds
                              .toDouble()
                              .clamp(1, double.infinity)),
                      max: dur.inSeconds.toDouble().clamp(1, double.infinity),
                      onChanged: (v) =>
                          _player.seek(Duration(seconds: v.toInt())),
                    ),
                  ),
                  Text('${_fmt(pos)} / ${_fmt(dur)}',
                      style: const TextStyle(color: AppColors.dorado)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _comentariosBody() {
    return StreamBuilder<List<Comentario>>(
      stream: ComentarioService().listar(widget.cancion.id),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child:
                  CircularProgressIndicator(color: AppColors.granate));
        }
        final lista = snap.data ?? [];
        if (lista.isEmpty) {
          return Center(
            child: Text('Sin comentarios aún',
                style: TextStyle(
                    color: AppColors.negro.withOpacity(0.5))),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: lista.length,
          itemBuilder: (context, i) {
            final c = lista[i];
            final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
            final esMio = c.autorUid == uid;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.granate,
                  child: Text(
                    c.autorNombre.isNotEmpty
                        ? c.autorNombre[0].toUpperCase()
                        : '?',
                    style: const TextStyle(color: AppColors.dorado),
                  ),
                ),
                title: Text(c.autorNombre,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(c.texto),
                    const SizedBox(height: 4),
                    Text(
                      _fmtFecha(c.fecha),
                      style: TextStyle(
                          fontSize: 11,
                          color: AppColors.negro.withOpacity(0.5)),
                    ),
                  ],
                ),
                trailing: esMio
                    ? IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: AppColors.granate, size: 20),
                        onPressed: () => ComentarioService()
                            .eliminar(widget.cancion.id, c.id),
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }

  Widget _comentarioInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
            top: BorderSide(color: AppColors.dorado.withOpacity(0.5))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _comentarioCtrl,
                decoration: const InputDecoration(
                  hintText: 'Escribe un comentario...',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send, color: AppColors.granate),
              onPressed: _enviarComentario,
            ),
          ],
        ),
      ),
    );
  }

  String _fmtFecha(DateTime? d) {
    if (d == null) return '...';
    return '${d.day}/${d.month}/${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Widget _fila(IconData icono, String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icono, size: 20, color: AppColors.granate),
          const SizedBox(width: 12),
          Text('$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(
              child: Text(valor,
                  style: const TextStyle(color: AppColors.negro))),
        ],
      ),
    );
  }
}