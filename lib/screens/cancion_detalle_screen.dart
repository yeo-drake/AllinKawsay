import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/cancion.dart';
import '../models/comentario.dart';
import '../models/usuario.dart';
import '../services/comentario_service.dart';
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
  final _player = AudioPlayer();
  bool _listo = false;
  String? _error;
  final _comentarioCtrl = TextEditingController();
  Usuario? _usuario;

  @override
  void initState() {
    super.initState();
    _cargarAudio();
    _cargarUsuario();
  }

  Future<void> _cargarUsuario() async {
    final u = await UsuarioService().miUsuarioActual();
    if (mounted) setState(() => _usuario = u);
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

  Future<void> _compartir() async {
    final c = widget.cancion;
    final sb = StringBuffer();
    sb.writeln('🎵 *${c.titulo}*');
    if (c.autor.isNotEmpty) sb.writeln('✍️ Autor: ${c.autor}');
    if (c.ritmo.isNotEmpty) sb.writeln('🎶 Ritmo: ${c.ritmo}');
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
            const SnackBar(
                content: Text('No se pudo abrir WhatsApp')),
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