import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';
import '../services/usuario_service.dart';
import '../theme/colors.dart';

class PerfilScreen extends StatelessWidget {
  final String nombreUsuario;
  const PerfilScreen({super.key, required this.nombreUsuario});

  void _abrir(BuildContext context, String titulo, String contenido) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.blanco,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MI PERFIL')),
      body: StreamBuilder<Usuario?>(
        stream: UsuarioService().miUsuario(),
        builder: (context, snap) {
          final u = snap.data;
          final esAdmin = u?.esAdmin ?? false;
          return ListView(
            children: [
              const SizedBox(height: 24),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: AppColors.dorado, width: 3),
                  ),
                  child: const CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.granate,
                    child: Icon(Icons.person,
                        size: 56, color: AppColors.dorado),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  u?.nombre ?? nombreUsuario,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.granate,
                  ),
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
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: esAdmin ? AppColors.granate : AppColors.negro,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        esAdmin
                            ? Icons.admin_panel_settings
                            : Icons.person_outline,
                        color: AppColors.dorado,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        esAdmin ? 'ADMINISTRADOR' : 'MIEMBRO',
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
              const SizedBox(height: 32),
              const Divider(),
              if (esAdmin)
                ListTile(
                  leading: const Icon(Icons.info_outline,
                      color: AppColors.granate),
                  title: const Text('Panel de administrador'),
                  subtitle: const Text(
                      'Como admin puedes agregar y borrar canciones'),
                  trailing: const Icon(Icons.chevron_right,
                      color: AppColors.dorado),
                  onTap: () => _abrir(
                    context,
                    'Panel de administrador',
                    'Como administrador puedes:\n\n'
                        '• Agregar canciones con el botón + en el Cancionero\n'
                        '• Subir partituras PDF y audios\n'
                        '• Borrar canciones (con confirmación)\n\n'
                        'Próximamente: editar eventos y la historia del grupo.',
                  ),
                ),
              ListTile(
                leading: const Icon(Icons.upload_file,
                    color: AppColors.granate),
                title: const Text('Mis subidas'),
                subtitle: const Text('Canciones y aportes que hiciste'),
                trailing: const Icon(Icons.chevron_right,
                    color: AppColors.dorado),
                onTap: () => _abrir(
                  context,
                  'Mis subidas',
                  esAdmin
                      ? 'Ve al Cancionero y toca el botón + para agregar contenido.'
                      : 'Por ahora solo el admin del grupo puede subir canciones. '
                          'En el futuro todos podrán aportar partituras.',
                ),
              ),
              ListTile(
                leading:
                    const Icon(Icons.settings, color: AppColors.granate),
                title: const Text('Ajustes'),
                subtitle:
                    const Text('Notificaciones, tema y preferencias'),
                trailing: const Icon(Icons.chevron_right,
                    color: AppColors.dorado),
                onTap: () => _abrir(
                  context,
                  'Ajustes',
                  'Próximamente:\n\n'
                      '• Notificaciones de eventos\n'
                      '• Modo offline\n'
                      '• Tamaño de letra para partituras',
                ),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline,
                    color: AppColors.granate),
                title: const Text('Acerca de'),
                subtitle: const Text('Versión e información'),
                trailing: const Icon(Icons.chevron_right,
                    color: AppColors.dorado),
                onTap: () => _abrir(
                  context,
                  'Acerca de',
                  'Sikuris App\nVersión 1.0.0\n\n'
                      'Aplicación oficial del grupo de sikuris.\n\n'
                      'Hecha con ❤️ para el grupo.',
                ),
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
}