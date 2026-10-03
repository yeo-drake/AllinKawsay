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
import '../version.dart';
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
          decoration: const InputDecoration(labelText: 'Nombre completo'),
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

  void _abrirMisSubidas(String uid) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
              const SizedBox(height: 16),
              Text('Mis subidas',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: onSurface,
                      letterSpacing: 0.5)),
              const SizedBox(height: 12),
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
                                      fontStyle: FontStyle.italic,
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
                                    leading: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        gradient:
                                            AppColors.gradienteGranate,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                          Icons.music_note,
                                          color: AppColors.dorado,
                                          size: 18),
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
                                    leading: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        gradient:
                                            AppColors.gradienteGranate,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                          Icons.photo_library,
                                          color: AppColors.dorado,
                                          size: 18),
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.granate,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            t,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.granate,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

void _abrirAjustes() {
  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).cardColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => StatefulBuilder(
      builder: (context, setSheetState) {
        final onSurface = Theme.of(context).colorScheme.onSurface;
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
              const SizedBox(height: 16),
              Text('Ajustes',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: onSurface,
                      letterSpacing: 0.5)),
              const SizedBox(height: 12),
              const Divider(height: 1),
              ValueListenableBuilder<ThemeMode>(
                valueListenable: ThemeProvider.mode,
                builder: (context, modo, _) {
                  return Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 12, 20, 4),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('TEMA DE LA APP',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: AppColors.granate,
                                  letterSpacing: 2)),
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
              const Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PRÓXIMAMENTE',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: AppColors.granate,
                            letterSpacing: 2)),
                    SizedBox(height: 10),
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

void _abrirAcercaDe() {
  final onSurface = Theme.of(context).colorScheme.onSurface;
  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).cardColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.dorado,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.dorado.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.granate,
                    child: const Icon(Icons.music_note,
                        color: AppColors.dorado, size: 40),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text('ALLIN KAWSAY',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.granate,
                    letterSpacing: 4)),
          ),
          const SizedBox(height: 6),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.granate.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppColors.granate.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.tag,
                      size: 12, color: AppColors.granate),
                  const SizedBox(width: 4),
                  Text(
                    'Versión ${AppVersion.full}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.granate,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              'Aplicación oficial del grupo de sikuris.\n\n'
              'Hecha con ❤️ para el grupo.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: onSurface.withOpacity(0.75)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
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
              _headerPerfil(context, u, rol, onSurface),
              const SizedBox(height: 20),
              if (u != null)
                _estadisticasPersonales(u.uid)
              else
                const SizedBox.shrink(),
              const SizedBox(height: 12),
              const Divider(),
              const SocialButtons(),
              const Divider(),

              if (esAdmin) _seccionAdmin(onSurface),

              if (u != null)
                _itemMenu(
                  Icons.upload_file,
                  'Mis subidas',
                  'Canciones y recuerdos que subiste',
                  onSurface,
                  onTap: () => _abrirMisSubidas(u.uid),
                ),

              _itemMenu(
                Icons.settings,
                'Ajustes',
                'Tema, notificaciones y preferencias',
                onSurface,
                onTap: _abrirAjustes,
              ),
              _itemMenu(
                Icons.info_outline,
                'Acerca de',
                'Versión e información',
                onSurface,
                onTap: _abrirAcercaDe,
              ),

              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text('CERRAR SESIÓN',
                        style: TextStyle(letterSpacing: 1.5)),
                    onPressed: () async {
                      await AuthService().logout();
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _headerPerfil(BuildContext context, Usuario? u, String rol,
      Color onSurface) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
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
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Center(
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.gradienteDorado,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.dorado.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 52,
                    backgroundColor: AppColors.granate,
                    backgroundImage: (u?.fotoUrl.isNotEmpty ?? false)
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
                      onTap:
                          _subiendoFoto ? null : () => _cambiarFoto(u),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: AppColors.gradienteDorado,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.granate, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.dorado.withOpacity(0.4),
                              blurRadius: 8,
                            ),
                          ],
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
          const SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                u?.nombre ?? widget.nombreUsuario,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: onSurface,
                    letterSpacing: 0.3),
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
          Text(
            u?.email ?? '',
            style: TextStyle(
                color: onSurface.withOpacity(0.55), fontSize: 13),
          ),
          const SizedBox(height: 14),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            decoration: BoxDecoration(
              gradient: _colorRol(rol) == AppColors.negro
                  ? LinearGradient(
                      colors: [
                        AppColors.negro,
                        AppColors.negro.withOpacity(0.8)
                      ],
                    )
                  : AppColors.gradienteGranate,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _colorRol(rol).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_iconoRol(rol),
                    color: AppColors.dorado, size: 16),
                const SizedBox(width: 6),
                Text(
                  u?.rolNombre ?? 'PÚBLICO',
                  style: const TextStyle(
                    color: AppColors.dorado,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _seccionAdmin(Color onSurface) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 14,
                decoration: BoxDecoration(
                  color: AppColors.granate,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text('ADMINISTRACIÓN',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.granate,
                      letterSpacing: 2)),
            ],
          ),
        ),
        _itemMenu(
            Icons.insights,
            'Estadísticas del grupo',
            'Totales, top canciones y usuarios',
            onSurface,
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        const EstadisticasAdminScreen()))),
        _itemMenu(
            Icons.history,
            'Historial de actividad',
            'Quién subió, editó o eliminó qué',
            onSurface,
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ActividadScreen()))),
        _itemMenu(
            Icons.category,
            'Categorías',
            'Carnaval, Religioso, etc.',
            onSurface,
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        const GestionCategoriasScreen()))),
        _itemMenu(
            Icons.backup,
            'Exportar respaldo',
            'Descarga todos los datos',
            onSurface,
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        const ExportarRespaldoScreen()))),
        _itemMenu(
            Icons.people,
            'Gestión de usuarios',
            'Roles y suspensiones',
            onSurface,
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const GestionUsuariosScreen()))),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _itemMenu(
    IconData icono,
    String titulo,
    String subtitulo,
    Color onSurface, {
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.granate.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icono,
                      color: AppColors.granate, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titulo,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: onSurface,
                              fontSize: 14,
                              letterSpacing: 0.2)),
                      const SizedBox(height: 2),
                      Text(subtitulo,
                          style: TextStyle(
                              fontSize: 11,
                              color: onSurface.withOpacity(0.55))),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right,
                    color: AppColors.dorado.withOpacity(0.7), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _estadisticasPersonales(String uid) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.cardColor(context),
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: AppColors.dorado.withOpacity(0.2)),
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
                  child: const Icon(Icons.bar_chart,
                      color: AppColors.granate, size: 14),
                ),
                const SizedBox(width: 10),
                const Text('MIS ESTADÍSTICAS',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: AppColors.granate,
                        letterSpacing: 2)),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FutureBuilder<int>(
                    future: CancionService().contarPorUsuario(uid),
                    builder: (context, snap) {
                      return _statCard(
                        Icons.library_music,
                        snap.data?.toString() ?? '...',
                        'Canciones',
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FutureBuilder<int>(
                    future:
                        CancionService().totalReproduccionesDeUsuario(uid),
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
    );
  }

  Widget _statCard(IconData icono, String valor, String label) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.granate.withOpacity(0.12),
            AppColors.granate.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: AppColors.granate.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Icon(icono, color: AppColors.granate, size: 22),
          const SizedBox(height: 6),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.granate,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withOpacity(0.55),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}