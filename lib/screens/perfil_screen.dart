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

  /// Bottom sheet con las canciones y recuerdos que subió el usuario
  void _abrirMisSubidas(BuildContext context, String uid) {
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
              const Text('Mis subidas',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
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
                                      color: AppColors.negro
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                            );
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
                                        style: const TextStyle(
                                            fontWeight:
                                                FontWeight.bold)),
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
                                        style: const TextStyle(
                                            fontWeight:
                                                FontWeight.bold)),
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

  /// Bottom sheet de ajustes con toggle de tema
  void _abrirAjustes(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                const Text('Ajustes',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Divider(height: 1),

                // Tema
                ValueListenableBuilder<ThemeMode>(
                  valueListenable: ThemeProvider.mode,
                  builder: (context, modo, _) {
                    return Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Tema de la app',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: AppColors.granate)),
                          ),
                        ),
                        RadioListTile<ThemeMode>(
                          value: ThemeMode.light,
                          groupValue: modo,
                          activeColor: AppColors.granate,
                          title: const Text('Claro'),
                          secondary: const Icon(Icons.light_mode,
                              color: AppColors.granate),
                          onChanged: (v) {
                            ThemeProvider.cambiar(ThemeMode.light);
                            setSheetState(() {});
                          },
                        ),
                        RadioListTile<ThemeMode>(
                          value: ThemeMode.dark,
                          groupValue: modo,
                          activeColor: AppColors.granate,
                          title: const Text('Oscuro'),
                          secondary: const Icon(Icons.dark_mode,
                              color: AppColors.granate),
                          onChanged: (v) {
                            ThemeProvider.cambiar(ThemeMode.dark);
                            setSheetState(() {});
                          },
                        ),
                        RadioListTile<ThemeMode>(
                          value: ThemeMode.system,
                          groupValue: modo,
                          activeColor: AppColors.granate,
                          title: const Text('Automático (sistema)'),
                          secondary: const Icon(Icons.brightness_auto,
                              color: AppColors.granate),
                          onChanged: (v) {
                            ThemeProvider.cambiar(ThemeMode.system);
                            setSheetState(() {});
                          },
                        ),
                      ],
                    );
                  },
                ),

                const Divider(height: 1),

                // Info próximas features
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Próximamente:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.granate)),
                      SizedBox(height: 8),
                      Text('• Notificaciones de eventos'),
                      Text('• Modo offline'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('MI PERFIL')),
    body: StreamBuilder<Usuario?>(
      stream: UsuarioService().miUsuario(),
      builder: (context, snap) {
        final u = snap.data;
        final esAdmin = u?.esAdmin ?? false;
        final rol = u?.rol ?? 'publico';

        return ListView(
          children: [
            const SizedBox(height: 24),
            // === FOTO DE PERFIL ===
            Center(
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: AppColors.dorado, width: 3),
                    ),
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: AppColors.granate,
                      backgroundImage:
                          (u?.fotoUrl.isNotEmpty ?? false)
                              ? NetworkImage(u!.fotoUrl)
                              : null,
                      child: (u?.fotoUrl.isEmpty ?? true)
                          ? const Icon(Icons.person,
                              size: 56, color: AppColors.dorado)
                          : null,
                    ),
                  ),
                  if (u != null)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _subiendoFoto
                            ? null
                            : () => _cambiarFoto(u),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.dorado,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.granate, width: 2),
                          ),
                          child: _subiendoFoto
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: AppColors.granate,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.camera_alt,
                                  size: 16, color: AppColors.granate),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // === NOMBRE ===
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    u?.nombre ?? widget.nombreUsuario,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.granate,
                    ),
                  ),
                  if (u != null) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.edit,
                          size: 16, color: AppColors.granate),
                      onPressed: () => _cambiarNombre(u),
                    ),
                  ],
                ],
              ),
            ),
            Center(
              child: Text(
                u?.email ?? '',
                style:
                    TextStyle(color: AppColors.negro.withOpacity(0.6)),
              ),
            ),
            const SizedBox(height: 12),
            // === BADGE DE ROL ===
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: _colorRol(rol),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_iconoRol(rol),
                        color: AppColors.dorado, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      u?.rolNombre ?? 'PÚBLICO',
                      style: const TextStyle(
                        color: AppColors.dorado,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // === ESTADÍSTICAS PERSONALES ===
            if (u != null)
              _estadisticasPersonales(u.uid)
            else
              const SizedBox.shrink(),

            const SizedBox(height: 8),

            // === REDES ===
            const Divider(),
            const SocialButtons(),
            const Divider(),

            // === ADMIN: ESTADÍSTICAS DEL GRUPO ===
            if (esAdmin)
              ListTile(
                leading: const Icon(Icons.insights,
                    color: AppColors.granate),
                title: const Text('Estadísticas del grupo'),
                subtitle: const Text(
                    'Totales, top canciones y usuarios por rol'),
                trailing: const Icon(Icons.chevron_right,
                    color: AppColors.dorado),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          const EstadisticasAdminScreen()),
                ),
              ),

            // === ADMIN: HISTORIAL DE ACTIVIDAD ===
            if (esAdmin)
              ListTile(
                leading: const Icon(Icons.history,
                    color: AppColors.granate),
                title: const Text('Historial de actividad'),
                subtitle: const Text(
                    'Quién subió, editó o eliminó qué'),
                trailing: const Icon(Icons.chevron_right,
                    color: AppColors.dorado),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ActividadScreen()),
                ),
              ),

            // === ADMIN: GESTIÓN DE USUARIOS ===
            if (esAdmin)
              ListTile(
                leading: const Icon(Icons.people,
                    color: AppColors.granate),
                title: const Text('Gestión de usuarios'),
                subtitle: const Text(
                    'Asciende a miembro o admin a los integrantes'),
                trailing: const Icon(Icons.chevron_right,
                    color: AppColors.dorado),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const GestionUsuariosScreen()),
                ),
              ),

            // === MIS SUBIDAS ===
            if (u != null)
              ListTile(
                leading: const Icon(Icons.upload_file,
                    color: AppColors.granate),
                title: const Text('Mis subidas'),
                subtitle: const Text(
                    'Canciones y recuerdos que subiste'),
                trailing: const Icon(Icons.chevron_right,
                    color: AppColors.dorado),
                onTap: () => _abrirMisSubidas(context, u.uid),
              ),

            // === AJUSTES ===
            ListTile(
              leading: const Icon(Icons.settings,
                  color: AppColors.granate),
              title: const Text('Ajustes'),
              subtitle:
                  const Text('Tema, notificaciones y preferencias'),
              trailing: const Icon(Icons.chevron_right,
                  color: AppColors.dorado),
              onTap: () => _abrirAjustes(context),
            ),

            // === ACERCA DE ===
            ListTile(
              leading: const Icon(Icons.info_outline,
                  color: AppColors.granate),
              title: const Text('Acerca de'),
              subtitle: const Text('Versión e información'),
              trailing: const Icon(Icons.chevron_right,
                  color: AppColors.dorado),
              onTap: () => _abrirAcercaDe(context),
            ),

            const Divider(),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('CERRAR SESIÓN'),
                  onPressed: () async {
                    await AuthService().logout();
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    ),
  );
}

  void _abrirAcercaDe(BuildContext context) {
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
            const Text('Acerca de',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.granate)),
            const SizedBox(height: 16),
            const Text(
                'Allin Kawsay\nVersión 1.0.0\n\n'
                'Aplicación oficial del grupo de sikuris.\n\n'
                'Hecha con ❤️ para el grupo.',
                style: TextStyle(fontSize: 15, height: 1.5)),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _estadisticasPersonales(String uid) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mis estadísticas',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.granate,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FutureBuilder<int>(
                      future: CancionService().contarPorUsuario(uid),
                      builder: (context, snap) {
                        return _statCard(
                          Icons.library_music,
                          snap.data?.toString() ?? '...',
                          'Canciones subidas',
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FutureBuilder<int>(
                      future: CancionService()
                          .totalReproduccionesDeUsuario(uid),
                      builder: (context, snap) {
                        return _statCard(
                          Icons.play_arrow,
                          snap.data?.toString() ?? '...',
                          'Reproducciones',
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(IconData icono, String valor, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.granate.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icono, color: AppColors.granate, size: 24),
          const SizedBox(height: 4),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.granate,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.negro.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}