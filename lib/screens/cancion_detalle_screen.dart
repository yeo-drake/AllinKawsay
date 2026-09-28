import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  @override
  Widget build(BuildContext context) {
    final c = widget.cancion;
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(c.titulo),
          bottom: const TabBar(
            labelColor: AppColors.dorado,
            unselectedLabelColor: AppColors.blanco,
            indicatorColor: AppColors.dorado,
            indicatorWeight: 3,
            isScrollable: true,
            tabs: [
              Tab(text: 'INFO'),
              Tab(text: 'PARTITURA'),
              Tab(text: 'NUMEROFONÍA'),
              Tab(text: 'AUDIO'),
              Tab(text: 'COMENTARIOS'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _infoTab(c),
            _partituraTab(c),
            NumerofoniaWidget(numerofonia: c.numerofonia),
            _audioTab(),
            _comentariosTab(),
          ],
        ),
      ),
    );
  }

  Widget _infoTab(Cancion c) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(c.titulo,
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.granate)),
        const SizedBox(height: 16),
        if (c.compositor.isNotEmpty)
          _fila(Icons.person, 'Compositor', c.compositor),
        if (c.ritmo.isNotEmpty)
          _fila(Icons.music_note, 'Ritmo', c.ritmo),
        if (c.region.isNotEmpty)
          _fila(Icons.place, 'Región', c.region),
        if (c.creadorNombre.isNotEmpty)
          _fila(Icons.upload, 'Subido por', c.creadorNombre),
        const SizedBox(height: 16),
        if (c.descripcion.isNotEmpty) ...[
          const Text('Descripción',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.granate)),
          const SizedBox(height: 8),
          Text(c.descripcion, style: const TextStyle(height: 1.5)),
        ],
      ],
    );
  }

  Widget _partituraTab(Cancion c) {
    if (c.pdfUrl.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.picture_as_pdf,
                  size: 80, color: AppColors.granate.withOpacity(0.3)),
              const SizedBox(height: 16),
              const Text(
                'Sin partitura',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.granate),
              ),
              const SizedBox(height: 8),
              Text(
                'El admin aún no subió el PDF de esta canción.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.negro.withOpacity(0.6), height: 1.5),
              ),
            ],
          ),
        ),
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.picture_as_pdf,
                size: 100, color: AppColors.granate),
            const SizedBox(height: 20),
            const Text(
              'Partitura PDF',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.granate),
            ),
            const SizedBox(height: 8),
            Text(
              'Toca el botón para abrir la partitura en el visor de PDF de tu celular.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.negro.withOpacity(0.6), height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                icon: const Icon(Icons.open_in_new),
                label: const Text('ABRIR PARTITURA'),
                onPressed: () async {
                  final uri = Uri.parse(c.pdfUrl);
                  if (!await launchUrl(uri,
                      mode: LaunchMode.externalApplication)) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('No se pudo abrir el PDF')),
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _audioTab() {
    if (widget.cancion.audioUrl.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.music_off,
                  size: 80, color: AppColors.granate.withOpacity(0.3)),
              const SizedBox(height: 16),
              const Text('Sin audio',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.granate)),
              const SizedBox(height: 8),
              Text('El admin aún no subió audio de esta canción.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppColors.negro.withOpacity(0.6))),
            ],
          ),
        ),
      );
    }
    if (_error != null) {
      return Center(
          child: Text(_error!,
              style: const TextStyle(color: AppColors.granate)));
    }
    if (!_listo) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.granate));
    }
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.granate.withOpacity(0.08),
            ),
            child: const Icon(Icons.music_note,
                size: 72, color: AppColors.granate),
          ),
          const SizedBox(height: 24),
          StreamBuilder<PlayerState>(
            stream: _player.playerStateStream,
            builder: (context, snap) {
              final playing = snap.data?.playing ?? false;
              final processing =
                  snap.data?.processingState == ProcessingState.loading ||
                      snap.data?.processingState == ProcessingState.buffering;
              return IconButton(
                iconSize: 84,
                icon: Icon(
                  processing
                      ? Icons.hourglass_top
                      : playing
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                  color: AppColors.granate,
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
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.granate,
                        thumbColor: AppColors.dorado,
                        inactiveTrackColor:
                            AppColors.granate.withOpacity(0.2),
                      ),
                      child: Slider(
                        value: pos.inSeconds.toDouble().clamp(
                            0,
                            dur.inSeconds
                                .toDouble()
                                .clamp(1, double.infinity)),
                        max: dur.inSeconds
                            .toDouble()
                            .clamp(1, double.infinity),
                        onChanged: (v) =>
                            _player.seek(Duration(seconds: v.toInt())),
                      ),
                    ),
                    Text('${_fmt(pos)} / ${_fmt(dur)}',
                        style: const TextStyle(color: AppColors.negro)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _comentariosTab() {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<Comentario>>(
            stream: ComentarioService().listar(widget.cancion.id),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.granate));
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
                  final uid =
                      FirebaseAuth.instance.currentUser?.uid ?? '';
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
                                color:
                                    AppColors.negro.withOpacity(0.5)),
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
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.blanco,
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
        ),
      ],
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