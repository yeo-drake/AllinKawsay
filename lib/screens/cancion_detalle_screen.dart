import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/cancion.dart';
import '../models/comentario.dart';
import '../models/usuario.dart';
import '../services/cancion_service.dart';
import '../services/comentario_service.dart';
import '../services/descarga_service.dart';
import '../services/player_service.dart';
import '../services/usuario_service.dart';
import '../theme/colors.dart';
import '../widgets/tarjeta_video.dart';
import '../widgets/visor_numerofonia.dart';
import '../widgets/watermark_overlay.dart';
import 'compartir_imagen_screen.dart';
import 'numerofonia_fullscreen_screen.dart';
import 'presentacion_screen.dart';

class CancionDetalleScreen extends StatefulWidget {
  final Cancion cancion;
  const CancionDetalleScreen({super.key, required this.cancion});

  @override
  State<CancionDetalleScreen> createState() => _CancionDetalleScreenState();
}

class _CancionDetalleScreenState extends State<CancionDetalleScreen> {
  final _player = PlayerService();
  final _comentarioCtrl = TextEditingController();
  Usuario? _usuario;
  bool _reproduccionContada = false;

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
  }

  Future<void> _cargarUsuario() async {
    final u = await UsuarioService().miUsuarioActual();
    if (mounted) setState(() => _usuario = u);
  }

  @override
  void dispose() {
    _comentarioCtrl.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    await _player.toggle(widget.cancion);
    if (!_reproduccionContada && _player.sonando(widget.cancion.id)) {
      _reproduccionContada = true;
      await CancionService()
          .incrementarReproduccion(widget.cancion.id);
    }
  }

  Future<void> _descargar(String url,
      {String? nombre, String mime = 'application/octet-stream'}) async {
    if (url.isEmpty) return;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: AppColors.dorado,
                  strokeWidth: 2.5,
                ),
              ),
              SizedBox(width: 12),
              Text('Descargando...'),
            ],
          ),
          duration: Duration(seconds: 30),
        ),
      );
    }

    final nombreFinal = nombre ??
        DescargaService.nombreConTimestamp(
            widget.cancion.titulo, 'mp3');

    final resultado =
        await DescargaService.descargar(url, nombreFinal, mime);

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (resultado != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle,
                    color: AppColors.dorado),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Guardado en Descargas: $resultado'),
                ),
              ],
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo descargar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

 Future<void> _compartir() async {
  final c = widget.cancion;
  final sb = StringBuffer();
  sb.writeln('🎵 *${c.titulo}*');
  if (c.autor.isNotEmpty) sb.writeln('✍️ Autor: ${c.autor}');
  if (c.ritmo.isNotEmpty) sb.writeln('🎶 Ritmo: ${c.ritmo}');

  if (c.tieneNumerofonia) {
    sb.writeln('');
    sb.writeln('📊 *Numerofonía:*');
    for (int i = 0; i < c.estrofas.length; i++) {
      final e = c.estrofas[i];
      if (e.vacia) continue;
      sb.writeln('');
      sb.writeln('Estrofa ${i + 1}${e.bis ? " (BIS)" : ""}:');
      sb.writeln(e.texto);
    }
  }

  if (c.letra.isNotEmpty) {
    sb.writeln('');
    sb.writeln('📝 Letra:');
    sb.writeln(c.letra);
  }

  sb.writeln('');
  sb.writeln('— Enviado desde Allin Kawsay');

  final texto = Uri.encodeComponent(sb.toString());
  final url = Uri.parse('https://wa.me/?text=$texto');

  try {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir WhatsApp')),
        );
      }
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
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
  final puedeDescargar = _usuario?.puedeDescargar ?? false;
  final puedeComentar = _usuario?.puedeComentar ?? false;
  final esFavorito = _usuario?.esFavorito(c.id) ?? false;
  final onSurface = Theme.of(context).colorScheme.onSurface;

  return Scaffold(
    appBar: AppBar(
      title: Text(c.titulo),
      actions: [
        IconButton(
          icon: Icon(
            esFavorito ? Icons.favorite : Icons.favorite_border,
          ),
          tooltip: 'Favorito',
          onPressed: () async {
            await UsuarioService().toggleFavorito(c.id);
            await _cargarUsuario();
          },
        ),
        IconButton(
          icon: const Icon(Icons.slideshow),
          tooltip: 'Modo presentación',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  PresentacionScreen(cancion: widget.cancion),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.image),
          tooltip: 'Compartir como imagen',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CompartirImagenScreen(
                cancion: widget.cancion,
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.share),
          tooltip: 'Compartir texto',
          onPressed: _compartir,
        ),
      ],
    ),
    body: WatermarkOverlay(
      opacity: 0.04,
      child: ListView(
        children: [
          _heroTitulo(c, onSurface),
          const SizedBox(height: 20),

          // === NUMEROFONÍA ===
          if (c.tieneNumerofonia) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _headerNumerofonia(c, onSurface),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: VisorNumerofonia(estrofas: c.estrofas),
              ),
            ),
            const SizedBox(height: 20),
          ] else if (c.tieneNumerofoniaString) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _seccionCard(
                context,
                icono: Icons.grid_on,
                titulo: 'Numerofonía',
                child: Text(
                  c.numerofonia,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    color: onSurface,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // === VIDEO ===
          if (c.tieneVideo) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TarjetaVideo(
                url: c.videoUrl,
                titulo: c.titulo,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // === AUDIO ===
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _audioPlayerCompacto(puedeDescargar),
          ),
          const SizedBox(height: 16),

          // === LETRA ===
          if (c.letra.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _seccionCard(
                context,
                icono: Icons.text_fields,
                titulo: 'Letra',
                child: Text(
                  c.letra,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.9,
                    fontStyle: FontStyle.italic,
                    color: onSurface,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // === DESCRIPCIÓN ===
          if (c.descripcion.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _seccionCard(
                context,
                icono: Icons.notes,
                titulo: 'Descripción',
                child: Text(c.descripcion,
                    style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: onSurface.withOpacity(0.85))),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // === INFORMACIÓN EXPANDIBLE ===
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _expansionCard(
              context,
              icono: Icons.info_outline,
              titulo: 'Información',
              children: [
                _filaInfo(context, Icons.person, 'Autor',
                    c.autor.isEmpty ? '—' : c.autor),
                _filaInfo(
                    context,
                    Icons.category,
                    'Tipo',
                    c.tipo == 'original'
                        ? 'Original'
                        : 'Adaptación'),
                _filaInfo(context, Icons.graphic_eq, 'Ritmo',
                    c.ritmo.isEmpty ? '—' : c.ritmo),
                _filaInfo(context, Icons.play_arrow,
                    'Reproducciones', '${c.reproducciones}'),
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
                                        fontSize: 11)),
                                backgroundColor:
                                    AppColors.dorado.withOpacity(0.15),
                                padding: EdgeInsets.zero,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ))
                          .toList(),
                    ),
                  ),
                if (c.creadorNombre.isNotEmpty)
                  _filaInfo(context, Icons.upload, 'Subido por',
                      c.creadorNombre),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // === COMENTARIOS EXPANDIBLE ===
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _expansionCard(
              context,
              icono: Icons.comment,
              titulo: 'Comentarios',
              children: [
                SizedBox(height: 300, child: _comentariosBody()),
                if (puedeComentar)
                  _comentarioInput()
                else
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Solo los miembros del grupo pueden comentar.',
                      style: TextStyle(
                          color: onSurface.withOpacity(0.5),
                          fontStyle: FontStyle.italic,
                          fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // === NOTA PERSONAL ===
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _notaPersonal(context, onSurface),
          ),

          const SizedBox(height: 32),
        ],
      ),
    ),
  );
}

Widget _headerNumerofonia(Cancion c, Color onSurface) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.granate.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.grid_on,
            color: AppColors.granate, size: 14),
      ),
      const SizedBox(width: 10),
      const Expanded(
        child: Text('Numerofonía',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.granate,
                fontSize: 13,
                letterSpacing: 1)),
      ),
      // Botón pantalla completa
      Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NumerofoniaFullscreenScreen(
                estrofas: c.estrofas,
              ),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.granate.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppColors.granate.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.zoom_out_map,
                    size: 13, color: AppColors.granate),
                const SizedBox(width: 5),
                Text(
                  'Pantalla completa',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.granate.withOpacity(0.9),
                      letterSpacing: 0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

Widget _heroTitulo(Cancion c, Color onSurface) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.granate.withOpacity(0.08),
          AppColors.dorado.withOpacity(0.05),
        ],
      ),
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(28),
        bottomRight: Radius.circular(28),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          c.titulo,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.granate,
            letterSpacing: 0.3,
            height: 1.2,
          ),
        ),
        if (c.autor.isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.person_outline,
                  size: 14, color: onSurface.withOpacity(0.5)),
              const SizedBox(width: 4),
              Text(
                c.autor,
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
        if (c.ritmo.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.granate.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.graphic_eq,
                    size: 12, color: AppColors.granate),
                const SizedBox(width: 4),
                Text(
                  c.ritmo,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.granate,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    ),
  );
}

Widget _seccionCard(BuildContext context,
    {required IconData icono,
    required String titulo,
    required Widget child}) {
  return Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.cardColor(context),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.dorado.withOpacity(0.2)),
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
              child: Icon(icono,
                  color: AppColors.granate, size: 14),
            ),
            const SizedBox(width: 10),
            Text(titulo,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.granate,
                    fontSize: 13,
                    letterSpacing: 1)),
          ],
        ),
        const SizedBox(height: 14),
        child,
      ],
    ),
  );
}

Widget _expansionCard(BuildContext context,
    {required IconData icono,
    required String titulo,
    required List<Widget> children}) {
  return Container(
    decoration: BoxDecoration(
      color: AppColors.cardColor(context),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.dorado.withOpacity(0.2)),
    ),
    child: ExpansionTile(
      shape: const Border(),
      collapsedShape: const Border(),
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.granate.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child:
            Icon(icono, color: AppColors.granate, size: 18),
      ),
      title: Text(titulo,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.granate,
              letterSpacing: 0.5)),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    ),
  );
}

Widget _audioPlayerCompacto(bool puedeDescargar) {
  final onSurface = Theme.of(context).colorScheme.onSurface;

  if (widget.cancion.audioUrl.isEmpty) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardColor(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.dorado.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.granate.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.music_off,
                color: AppColors.granate.withOpacity(0.5), size: 20),
          ),
          const SizedBox(width: 12),
          Text('Sin audio subido',
              style: TextStyle(
                  color: onSurface.withOpacity(0.5),
                  fontSize: 13,
                  fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  return ValueListenableBuilder<EstadoPlayer>(
    valueListenable: _player.estado,
    builder: (context, estado, _) {
      final esEsta = estado.cancionId == widget.cancion.id;
      final playing = esEsta && estado.playing;
      final cargando = esEsta && estado.cargando;
      final bucle = estado.modoBucle;

      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.negro, Color(0xFF2A2A2A)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: _togglePlay,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: AppColors.gradienteDorado,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.dorado.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: cargando
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(
                              color: AppColors.granate,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Icon(
                            playing
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: AppColors.granate,
                            size: 32,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: esEsta
                      ? StreamBuilder<Duration>(
                          stream: _player.player.positionStream,
                          builder: (context, snap) {
                            final pos = snap.data ?? Duration.zero;
                            final dur =
                                _player.player.duration ?? Duration.zero;
                            return Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                SliderTheme(
                                  data: SliderTheme.of(context)
                                      .copyWith(
                                    activeTrackColor:
                                        AppColors.dorado,
                                    thumbColor: AppColors.dorado,
                                    thumbShape:
                                        const RoundSliderThumbShape(
                                            enabledThumbRadius: 6),
                                    overlayShape:
                                        const RoundSliderOverlayShape(
                                            overlayRadius: 14),
                                    inactiveTrackColor: AppColors
                                        .dorado
                                        .withOpacity(0.2),
                                    trackHeight: 3,
                                  ),
                                  child: Slider(
                                    value: pos.inSeconds
                                        .toDouble()
                                        .clamp(
                                            0,
                                            dur.inSeconds
                                                .toDouble()
                                                .clamp(1,
                                                    double.infinity)),
                                    max: dur.inSeconds
                                        .toDouble()
                                        .clamp(1, double.infinity),
                                    onChanged: (v) =>
                                        _player.player.seek(Duration(
                                            seconds: v.toInt())),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8),
                                  child: Text(
                                    '${_fmt(pos)} / ${_fmt(dur)}',
                                    style: TextStyle(
                                        color: AppColors.dorado
                                            .withOpacity(0.8),
                                        fontSize: 11,
                                        letterSpacing: 0.5),
                                  ),
                                ),
                              ],
                            );
                          },
                        )
                      : Center(
                          child: Text(
                            'Toca para escuchar',
                            style: TextStyle(
                                color: AppColors.dorado
                                    .withOpacity(0.6),
                                fontSize: 12,
                                fontStyle: FontStyle.italic),
                          ),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _botonControl(
                  icono:
                      bucle ? Icons.repeat_one : Icons.repeat,
                  label: 'Bucle',
                  activo: bucle,
                  onTap: () => _player.toggleBucle(),
                ),
                if (puedeDescargar)
                  _botonControl(
                    icono: Icons.download_outlined,
                    label: 'Descargar',
                    onTap: () => _descargar(
                      widget.cancion.audioUrl,
                      nombre: DescargaService.nombreConTimestamp(
                          widget.cancion.titulo, 'mp3'),
                      mime: 'audio/mpeg',
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

Widget _botonControl({
  required IconData icono,
  required String label,
  bool activo = false,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: activo
            ? AppColors.dorado.withOpacity(0.2)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: activo
              ? AppColors.dorado.withOpacity(0.5)
              : AppColors.dorado.withOpacity(0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono,
              color: activo
                  ? AppColors.dorado
                  : AppColors.dorado.withOpacity(0.7),
              size: 16),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: activo
                      ? AppColors.dorado
                      : AppColors.dorado.withOpacity(0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5)),
        ],
      ),
    ),
  );
}

Widget _filaInfo(BuildContext context, IconData icono, String label,
    String valor) {
  final onSurface = Theme.of(context).colorScheme.onSurface;
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Icon(icono, size: 18, color: AppColors.granate),
        const SizedBox(width: 12),
        Text('$label: ',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: onSurface.withOpacity(0.7),
                fontSize: 13)),
        Expanded(
            child: Text(valor,
                style: TextStyle(color: onSurface, fontSize: 13))),
      ],
    ),
  );
}

Widget _notaPersonal(BuildContext context, Color onSurface) {
  final textoActual = _usuario?.notaDe(widget.cancion.id) ?? '';
  return Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppColors.dorado.withOpacity(0.1),
          AppColors.dorado.withOpacity(0.05),
        ],
      ),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.dorado.withOpacity(0.3)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.dorado.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.sticky_note_2,
                  color: AppColors.granate, size: 14),
            ),
            const SizedBox(width: 10),
            const Text('Mi nota personal',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.granate,
                    fontSize: 13,
                    letterSpacing: 1)),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.edit,
                  color: AppColors.granate, size: 18),
              onPressed: _editarNota,
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (textoActual.isEmpty)
          Text(
            'Toca el lápiz para escribir una nota privada '
            '(solo la ves vos)',
            style: TextStyle(
              color: onSurface.withOpacity(0.5),
              fontStyle: FontStyle.italic,
              fontSize: 12,
            ),
          )
        else
          Text(
            textoActual,
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: onSurface,
              height: 1.5,
            ),
          ),
      ],
    ),
  );
}

  Future<void> _editarNota() async {
    final ctrl = TextEditingController(
      text: _usuario?.notaDe(widget.cancion.id) ?? '',
    );
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Mi nota personal'),
        content: TextField(
          controller: ctrl,
          maxLines: 5,
          autofocus: true,
          decoration: const InputDecoration(
            hintText:
                'Ej: esta la toco con la 6 tapada, entrada en la 3ra...',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Guardar')),
        ],
      ),
    );
    if (ok == true) {
      await UsuarioService()
          .guardarNota(widget.cancion.id, ctrl.text);
      await _cargarUsuario();
    }
  }

  Widget _comentariosBody() {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return StreamBuilder<List<Comentario>>(
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
                    color: onSurface.withOpacity(0.5),
                    fontStyle: FontStyle.italic)),
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
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppColors.gradienteGranate,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    c.autorNombre.isNotEmpty
                        ? c.autorNombre[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        color: AppColors.dorado,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(c.autorNombre,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: onSurface)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(c.texto,
                        style: TextStyle(
                            color: onSurface.withOpacity(0.8),
                            fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      _fmtFecha(c.fecha),
                      style: TextStyle(
                          fontSize: 10,
                          color: onSurface.withOpacity(0.4)),
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
            top: BorderSide(
                color: AppColors.dorado.withOpacity(0.3))),
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
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.gradienteGranate,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send,
                    color: AppColors.dorado, size: 20),
                onPressed: _enviarComentario,
              ),
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
}