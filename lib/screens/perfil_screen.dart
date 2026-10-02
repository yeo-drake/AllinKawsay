import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';
import '../services/cancion_service.dart';
import '../services/storage_service.dart';
import '../services/usuario_service.dart';
import '../theme/colors.dart';
import '../widgets/social_buttons.dart';
import 'actividad_screen.dart';
import 'estadisticas_admin_screen.dart';
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

  void _abrir(BuildContext context, String titulo, String contenido) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.dorado,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(titulo,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.granate)),
            const SizedBox(height: 16),
            Text(contenido,
                style: const TextStyle(fontSize: 15, height: 1.5)),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
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