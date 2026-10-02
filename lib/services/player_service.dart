import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../models/cancion.dart';

class EstadoPlayer {
  final String? cancionId;
  final bool playing;
  final bool cargando;
  final bool modoBucle;
  const EstadoPlayer({
    this.cancionId,
    this.playing = false,
    this.cargando = false,
    this.modoBucle = false,
  });
}

class PlayerService {
  static final PlayerService _instance = PlayerService._();
  factory PlayerService() => _instance;

  final AudioPlayer player = AudioPlayer();
  final ValueNotifier<EstadoPlayer> estado =
      ValueNotifier(const EstadoPlayer());

  String? _cancionId;
  bool _playing = false;
  bool _cargando = false;
  bool _bucle = false;

  PlayerService._() {
    player.playerStateStream.listen((s) {
      _playing = s.playing;
      _cargando = s.processingState == ProcessingState.loading ||
          s.processingState == ProcessingState.buffering;
      _notificar();
    });
  }

  void _notificar() {
    estado.value = EstadoPlayer(
      cancionId: _cancionId,
      playing: _playing,
      cargando: _cargando,
      modoBucle: _bucle,
    );
  }

  /// Si la canción ya está cargada → alterna play/pausa.
  /// Si es otra → la carga y la reproduce.
  Future<void> toggle(Cancion c) async {
    if (c.audioUrl.isEmpty) return;

    if (_cancionId == c.id) {
      if (_playing) {
        await player.pause();
      } else {
        await player.play();
      }
      return;
    }

    try {
      _cancionId = c.id;
      _cargando = true;
      _notificar();

      await player.setAudioSource(AudioSource.uri(
        Uri.parse(c.audioUrl),
        tag: MediaItem(
          id: c.id,
          album: 'Allin Kawsay',
          title: c.titulo,
          artist: c.autor.isNotEmpty ? c.autor : 'Anónimo',
          artUri: c.imagenUrl.isNotEmpty ? Uri.parse(c.imagenUrl) : null,
        ),
      ));
      await player.play();
    } catch (e) {
      _cancionId = null;
      _cargando = false;
      _notificar();
    }
  }

  Future<void> toggleBucle() async {
    _bucle = !_bucle;
    await player.setLoopMode(_bucle ? LoopMode.one : LoopMode.off);
    _notificar();
  }

  Future<void> detener() async {
    await player.stop();
    _cancionId = null;
    _playing = false;
    _cargando = false;
    _bucle = false;
    _notificar();
  }

  bool sonando(String cancionId) => _cancionId == cancionId && _playing;
  String? get cancionActualId => _cancionId;
}