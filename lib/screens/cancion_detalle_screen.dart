import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/cancion.dart';
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

  @override
  void initState() {
    super.initState();
    _cargarAudio();
  }

  Future<void> _cargarAudio() async {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.cancion;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(c.titulo),
          backgroundColor: const Color(0xFF8B4513),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Info'),
              Tab(text: 'Numerofonía'),
              Tab(text: 'Audio'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _infoTab(c),
            NumerofoniaWidget(numerofonia: c.numerofonia),
            _audioTab(),
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
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _fila(Icons.person, 'Compositor', c.compositor),
        _fila(Icons.music_note, 'Ritmo', c.ritmo),
        _fila(Icons.place, 'Región', c.region),
        const SizedBox(height: 16),
        if (c.descripcion.isNotEmpty) ...[
          const Text('Descripción',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(c.descripcion),
        ],
      ],
    );
  }

  Widget _audioTab() {
    if (_error != null) {
      return Center(
          child: Text(_error!, style: const TextStyle(color: Colors.red)));
    }
    if (!_listo) {
      return const Center(child: CircularProgressIndicator());
    }
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.music_note, size: 80, color: Color(0xFF8B4513)),
          const SizedBox(height: 24),
          StreamBuilder<PlayerState>(
            stream: _player.playerStateStream,
            builder: (context, snap) {
              final playing = snap.data?.playing ?? false;
              final processing =
                  snap.data?.processingState == ProcessingState.loading ||
                      snap.data?.processingState == ProcessingState.buffering;
              return IconButton(
                iconSize: 72,
                icon: Icon(
                  processing
                      ? Icons.hourglass_top
                      : playing
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                  color: const Color(0xFF8B4513),
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
                    Slider(
                      value: pos.inSeconds.toDouble().clamp(
                          0, dur.inSeconds.toDouble().clamp(1, double.infinity)),
                      max: dur.inSeconds.toDouble().clamp(1, double.infinity),
                      onChanged: (v) =>
                          _player.seek(Duration(seconds: v.toInt())),
                    ),
                    Text('${_fmt(pos)} / ${_fmt(dur)}'),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
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
          Icon(icono, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(valor)),
        ],
      ),
    );
  }
}
