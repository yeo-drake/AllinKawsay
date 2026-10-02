import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/cancion.dart';
import '../models/recuerdo.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';
import '../services/cancion_service.dart';
import '../services/recuerdo_service.dart';
import '../services/storage_service.dart';
import '../services/usuario_service.dart';
import '../theme/colors.dart';
import '../theme/theme_provider.dart';
import '../widgets/social_buttons.dart';
import 'actividad_screen.dart';
import 'cancion_detalle_screen.dart';
import 'estadisticas_admin_screen.dart';
import 'exportar_respaldo_screen.dart';
import 'gestion_categorias_screen.dart';
import 'gestion_usuarios_screen.dart';

class PerfilScreen extends StatefulWidget {
  final String nombreUsuario;
  const PerfilScreen({super.key, required this.nombreUsuario});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  bool _subiendoFoto = false;

  Future<void> _cambiarFoto(Usuario u) async {
    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 500,
      maxHeight: 500,
    );
    if (x == null) return;

    setState(() => _subiendoFoto = true);
    try {
      final file = File(x.path);
      final url = await StorageService().subirFotoPerfil(file, u.uid);
      await UsuarioService().actualizarFotoPerfil(u.uid, url);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Foto actualizada!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _subiendoFoto = false);
    }
  }

  Future<void> _cambiarNombre(Usuario u) async {
    final ctrl = TextEditingController(text: u.nombre);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cambiar nombre'),
        content: TextField(
          controller: ctrl,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Nombre completo',
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
    if (ok == true && ctrl.text.trim().isNotEmpty) {
      try {
        await UsuarioService().actualizarNombre(u.uid, ctrl.text.trim());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('¡Nombre actualizado!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  Color _colorRol(String rol) {
    switch (rol) {
      case 'admin':
        return AppColors.granate;
      case 'miembro':
        return const Color(0xFF8B0000);
      default:
        return AppColors.negro;
    }
  }

  IconData _iconoRol(String rol) {
    switch (rol) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'miembro':
        return Icons.verified_user;
      default:
        return Icons.person_outline;
    }
  }

  void _abrirMisSubidas(BuildContext context, String uid) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.dorado,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Text('Mis subidas',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: onSurface)),
              const SizedBox(height: 8),
              const Divider(height: 1),
              Expanded(
                child: FutureBuilder<List<Cancion>>(
                  future: CancionService().listar().first,
                  builder: (context, canSnap) {
                    return FutureBuilder<List<Recuerdo>>(
                      future: RecuerdoService().listar().first,
                      builder: (context, recSnap) {
                        if (canSnap.connectionState ==
                                ConnectionState.waiting ||
                            recSnap.connectionState ==
                                ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.granate),
                          );
                        }

                        final misCanciones = (canSnap.data ?? [])
                            .where((c) => c.creadoPor == uid)
                            .toList();
                        final misRecuerdos = (recSnap.data ?? [])
                            .where((r) => r.creadoPor == uid)
                            .toList();

                        if (misCanciones.isEmpty &&
                            misRecuerdos.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.inbox,
                                      size: 60,
                                      color: AppColors.granate
                                          .withOpacity(0.3)),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Todavía no subiste nada',
                                    style: TextStyle(
                                      color: onSurface.withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return ListView(
                          controller: scrollController,
                          children: [
                            if (misCanciones.isNotEmpty) ...[
                              _subtitulo(
                                  'Canciones (${misCanciones.length})'),
                              ...misCanciones.map((c) => ListTile(
                                    leading: const CircleAvatar(
                                      backgroundColor: AppColors.granate,
                                      child: Icon(Icons.music_note,
                                          color: AppColors.dorado,
                                          size: 20),
                                    ),
                                    title: Text(c.titulo,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: onSurface)),
                                    subtitle: Text(c.ritmo),
                                    trailing: const Icon(
                                        Icons.chevron_right,
                                        color: AppColors.dorado),
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                CancionDetalleScreen(
                                                    cancion: c)),
                                      );
                                    },
                                  )),
                            ],
                            if (misRecuerdos.isNotEmpty) ...[
                              _subtitulo(
                                  'Recuerdos (${misRecuerdos.length})'),
                              ...misRecuerdos.map((r) => ListTile(
                                    leading: const CircleAvatar(
                                      backgroundColor: AppColors.granate,
                                      child: Icon(Icons.photo_library,
                                          color: AppColors.dorado,
                                          size: 20),
                                    ),
                                    title: Text(r.titulo,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: onSurface)),
                                    subtitle: Text(
                                        '${r.fotos.length} foto(s)'),
                                  )),
                            ],
                            const SizedBox(height: 24),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _subtitulo(String t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        t,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppColors.granate,
        ),
      ),
    );
  }