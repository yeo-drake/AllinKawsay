import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'login_screen.dart';

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
      body: ListView(
        children: [
          const SizedBox(height: 24),
          Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.dorado, width: 3),
              ),
              child: const CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.granate,
                child: Icon(Icons.person, size: 56, color: AppColors.dorado),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              nombreUsuario,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.granate,
              ),
            ),
          ),
          Center(
            child: Text(
              'Miembro del grupo',
              style: TextStyle(color: AppColors.negro.withOpacity(0.6)),
            ),
          ),
          const SizedBox(height: 32),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.upload_file, color: AppColors.granate),
            title: const Text('Mis subidas'),
            subtitle: const Text('Canciones, fotos y partituras que subiste'),
            trailing: const Icon(Icons.chevron_right,
                color: AppColors.dorado),
            onTap: () => _abrir(
              context,
              'Mis subidas',
              'Aún no has subido contenido.\n\n'
                  'En la próxima versión vas a poder subir:\n'
                  '• Partituras en PDF\n'
                  '• Audios de ensayos\n'
                  '• Fotos de viajes',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: AppColors.granate),
            title: const Text('Ajustes'),
            subtitle: const Text('Notificaciones, tema y preferencias'),
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
            leading:
                const Icon(Icons.info_outline, color: AppColors.granate),
            title: const Text('Acerca de'),
            subtitle: const Text('Versión e información del grupo'),
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
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
