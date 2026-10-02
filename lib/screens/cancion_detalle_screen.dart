import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/cancion.dart';
import '../models/comentario.dart';
import '../models/usuario.dart';
import '../services/cancion_service.dart';
import '../services/comentario_service.dart';
import '../services/player_service.dart';
import '../services/usuario_service.dart';
import '../theme/colors.dart';
import '../widgets/visor_numerofonia.dart';
import '../widgets/watermark_overlay.dart';
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

  Future<void> _descargar(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo abrir el enlace')),
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

  Future<void> _abrirVideo(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo abrir el video')),
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
        sb.writeln('7: ${e.fila7.join(" | ")}');
        sb.writeln('6: ${e.fila6.join(" | ")}');
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
        if (c.tieneVideo)
          IconButton(
            icon: const Icon(Icons.video_library),
            tooltip: 'Ver video',
            onPressed: () => _abrirVideo(c.videoUrl),
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
          icon: const Icon(Icons.share),
          tooltip: 'Compartir',
          onPressed: _compartir,
        ),
      ],
    ),
    body: WatermarkOverlay(
      opacity: 0.05,
      child: ListView(
        children: [
          // === 1. TÍTULO ===
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.titulo,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.granate,
                  ),
                ),
                if (c.autor.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    c.autor,
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: AppColors.negro.withOpacity(0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // === 2. NUMEROFONÍA ===
          if (c.tieneNumerofonia) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
              child: VisorNumerofonia(estrofas: c.estrofas),
            ),
          ] else if (c.tieneNumerofoniaString) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Numerofonía',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.granate)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.blanco,
                      border:
                          Border.all(color: AppColors.negro, width: 1),
                    ),
                    child: Text(
                      c.numerofonia,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.negro,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // === 3. AUDIO ===
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: _audioPlayerCompacto(puedeDescargar),
          ),

          // === 4. LETRA ===
          if (c.letra.isNotEmpty) ...[
            const Divider(),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text('Letra',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.granate)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Text(
                c.letra,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 16,
                    height: 1.8,
                    fontStyle: FontStyle.italic),
              ),
            ),
          ],

          // === 5. DESCRIPCIÓN ===
          if (c.descripcion.isNotEmpty) ...[
            const Divider(),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text('Descripción',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.granate)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(c.descripcion,
                  style: const TextStyle(fontSize: 15, height: 1.5)),
            ),
          ],

          const Divider(),

          // === 6. INFORMACIÓN ===
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
                    _fila(Icons.person, 'Autor',
                        c.autor.isEmpty ? '—' : c.autor),
                    _fila(
                        Icons.category,
                        'Tipo',
                        c.tipo == 'original'
                            ? 'Original'
                            : 'Adaptación'),
                    _fila(Icons.graphic_eq, 'Ritmo',
                        c.ritmo.isEmpty ? '—' : c.ritmo),
                    _fila(Icons.play_arrow, 'Reproducciones',
                        '${c.reproducciones}'),
                    if (c.tags.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8),
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: c.tags
                              .map((t) => Chip(
                                    label: Text(t,
                                        style: const TextStyle(
                                            fontSize: 12)),
                                    backgroundColor:
                                        AppColors.dorado
                                            .withOpacity(0.2),
                                    padding: EdgeInsets.zero,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize
                                            .shrinkWrap,
                                  ))
                              .toList(),
                        ),
                      ),
                    if (c.creadorNombre.isNotEmpty)
                      _fila(
                          Icons.upload, 'Subido por', c.creadorNombre),
                  ],
                ),
              ),
            ],
          ),

          // === 7. COMENTARIOS ===
          ExpansionTile(
            leading:
                const Icon(Icons.comment, color: AppColors.granate),
            title: const Text('Comentarios',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.granate)),
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
                        color: AppColors.negro.withOpacity(0.5),
                        fontStyle: FontStyle.italic),
                  ),
                ),
            ],
          ),

          // === 8. NOTA PERSONAL ===
          const Divider(),
          _notaPersonal(),

          const SizedBox(height: 24),
        ],
      ),
    ),
  );
}

Widget _audioPlayerCompacto(bool puedeDescargar) {
  if (widget.cancion.audioUrl.isEmpty) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.grisClaro,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.music_off,
              color: AppColors.granate.withOpacity(0.4), size: 22),
          const SizedBox(width: 12),
          Text('Sin audio subido',
              style: TextStyle(
                  color: AppColors.negro.withOpacity(0.5),
                  fontSize: 13)),
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.negro,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            IconButton(
              iconSize: 36,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(
                cargando
                    ? Icons.hourglass_top
                    : playing
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                color: AppColors.dorado,
              ),
              onPressed: _togglePlay,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: esEsta
                  ? StreamBuilder<Duration>(
                      stream: _player.player.positionStream,
                      builder: (context, snap) {
                        final pos = snap.data ?? Duration.zero;
                        final dur =
                            _player.player.duration ?? Duration.zero;
                        return Row(
                          children: [
                            Expanded(
                              child: SliderTheme(
                                data:
                                    SliderTheme.of(context).copyWith(
                                  activeTrackColor: AppColors.dorado,
                                  thumbColor: AppColors.dorado,
                                  thumbShape:
                                      const RoundSliderThumbShape(
                                          enabledThumbRadius: 6),
                                  overlayShape:
                                      const RoundSliderOverlayShape(
                                          overlayRadius: 12),
                                  inactiveTrackColor:
                                      AppColors.dorado
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
                                              .clamp(
                                                  1, double.infinity)),
                                  max: dur.inSeconds
                                      .toDouble()
                                      .clamp(1, double.infinity),
                                  onChanged: (v) => _player.player
                                      .seek(Duration(
                                          seconds: v.toInt())),
                                ),
                              ),
                            ),
                            Text(
                              '${_fmt(pos)} / ${_fmt(dur)}',
                              style: const TextStyle(
                                  color: AppColors.dorado,
                                  fontSize: 11),
                            ),
                          ],
                        );
                      },
                    )
                  : const Center(
                      child: Text('Toca play para escuchar',
                          style: TextStyle(
                              color: AppColors.dorado,
                              fontSize: 11,
                              fontStyle: FontStyle.italic)),
                    ),
            ),
            IconButton(
              iconSize: 22,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(
                bucle ? Icons.repeat_one : Icons.repeat,
                color: bucle
                    ? AppColors.dorado
                    : AppColors.dorado.withOpacity(0.5),
              ),
              tooltip: 'Modo bucle',
              onPressed: () => _player.toggleBucle(),
            ),
            if (puedeDescargar)
              IconButton(
                iconSize: 22,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon:
                    const Icon(Icons.download, color: AppColors.dorado),
                tooltip: 'Descargar audio',
                onPressed: () => _descargar(widget.cancion.audioUrl),
              ),
            const SizedBox(width: 4),
          ],
        ),
      );
    },
  );
}

  Widget _notaPersonal() {
    final textoActual = _usuario?.notaDe(widget.cancion.id) ?? '';
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sticky_note_2,
                  color: AppColors.granate),
              const SizedBox(width: 8),
              const Text(
                'Mi nota personal',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.granate,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.edit,
                    color: AppColors.granate, size: 20),
                onPressed: _editarNota,
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (textoActual.isEmpty)
            Text(
              'Toca el lápiz para escribir una nota privada '
              '(solo la ves vos)',
              style: TextStyle(
                color: AppColors.negro.withOpacity(0.5),
                fontStyle: FontStyle.italic,
                fontSize: 13,
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.dorado.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppColors.dorado.withOpacity(0.5)),
              ),
              child: Text(
                textoActual,
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: AppColors.negro,
                ),
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
            border: OutlineInputBorder(),
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
                style:
                    TextStyle(color: AppColors.negro.withOpacity(0.5))),
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