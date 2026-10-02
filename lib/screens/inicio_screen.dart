import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/cancion.dart';
import '../models/evento.dart';
import '../models/recuerdo.dart';
import '../services/cancion_service.dart';
import '../services/evento_service.dart';
import '../services/recuerdo_service.dart';
import '../theme/colors.dart';
import '../widgets/social_buttons.dart';
import '../widgets/watermark_overlay.dart';
import 'busqueda_global_screen.dart';
import 'cancion_detalle_screen.dart';
import 'historia_screen.dart';

class InicioScreen extends StatelessWidget {
  final String nombreUsuario;
  const InicioScreen({super.key, required this.nombreUsuario});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: WatermarkOverlay(
          opacity: 0.05,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.negro, AppColors.granate],
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.negro.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/logo.png',
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: AppColors.granate,
                                child: const Icon(Icons.music_note,
                                    color: AppColors.dorado, size: 50),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'ALLIN KAWSAY',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.dorado,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Hola, $nombreUsuario',
                          style: TextStyle(
                            color: AppColors.dorado.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.search,
                          color: AppColors.dorado, size: 28),
                      tooltip: 'Buscar',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BusquedaGlobalScreen(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _titulo('Próximo evento'),
              _proximoEvento(context),
              const SizedBox(height: 20),
              _titulo('Últimas canciones'),
              _ultimasCanciones(context),
              const SizedBox(height: 20),
              _titulo('Último recuerdo'),
              _ultimoRecuerdo(context),
              const SizedBox(height: 20),
              _titulo('Nuestra historia'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.granate,
                      child: Icon(Icons.history_edu,
                          color: AppColors.dorado),
                    ),
                    title: Text('Conoce nuestra historia',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: onSurface)),
                    subtitle:
                        const Text('Cómo empezó el grupo y sus logros'),
                    trailing: const Icon(Icons.chevron_right,
                        color: AppColors.dorado),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const HistoriaScreen()),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SocialButtons(),
              const Divider(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _titulo(String texto) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.granate,
        ),
      ),
    );
  }