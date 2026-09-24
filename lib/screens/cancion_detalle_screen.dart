import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/cancion.dart';
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
      length: 4,
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
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _infoTab(c),
            _partituraTab(c),
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
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.granate)),
        const SizedBox(height: 16),
        _fila(Icons.person, 'Compositor', c.compositor),
        _fila(Icons.music_note, 'Ritmo', c.ritmo),
        _fila(Icons.place, 'Región', c.region),
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
                'Partitura PDF',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.granate),
              ),
              const SizedBox(height: 8),
              Text(
                'Aún no hay partitura subida para esta canción.\n\n'
                'En la próxima versión, los miembros del grupo podrán '
                'subir el PDF de la partitura y verse aquí mismo.',
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
      child: Text('Partitura: ${c.pdfUrl}'),
    );
  }

  Widget _audioTab() {
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
                        value: pos.inSeconds
                            .toDouble()
                            .clamp(0, dur.inSeconds.toDouble().clamp(1, double.infinity)),
                        max: dur.inSeconds.toDouble().clamp(1, double.infinity),
                        onChanged: (v) =>
                            _player.seek(Duration(seconds: v.toInt())),
                      ),
                    ),
                    Text('${_fmt(pos)} / ${_fmt(dur)}',
                        style:
                            const TextStyle(color: AppColors.negro)),
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
