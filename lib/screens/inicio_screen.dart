import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/cancion.dart';
import '../models/evento.dart';
import '../models/recuerdo.dart';
import '../services/cancion_service.dart';
import '../services/evento_service.dart';
import '../services/recuerdo_service.dart';
import '../theme/colors.dart';
import '../widgets/logo.dart';
import '../widgets/social_buttons.dart';
import 'cancion_detalle_screen.dart';
import 'historia_screen.dart';

class InicioScreen extends StatelessWidget {
  final String nombreUsuario;
  const InicioScreen({super.key, required this.nombreUsuario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blanco,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // === HEADER ===
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
                  const SikuriLogo(size: 90),
                  const SizedBox(height: 12),
                  const Text(
                    'SIKURIS',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dorado,
                      letterSpacing: 5,
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

            const SizedBox(height: 20),

            // === PRÓXIMO EVENTO ===
            _titulo('Próximo evento'),
            _proximoEvento(context),

            const SizedBox(height: 20),

            // === ÚLTIMAS CANCIONES ===
            _titulo('Últimas canciones'),
            _ultimasCanciones(context),

            const SizedBox(height: 20),

            // === ÚLTIMO RECUERDO ===
            _titulo('Último recuerdo'),
            _ultimoRecuerdo(context),

            const SizedBox(height: 20),

            // === HISTORIA ===
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
                  title: const Text('Conoce nuestra historia',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.negro)),
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

            // === REDES SOCIALES ===
            const Divider(),
            const SocialButtons(),
            const Divider(),
            const SizedBox(height: 24),
          ],
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