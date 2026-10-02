import 'package:flutter/material.dart';
import '../models/cancion.dart';
import '../theme/colors.dart';
import 'visor_numerofonia.dart';

class TarjetaCompartible extends StatelessWidget {
  final Cancion cancion;
  const TarjetaCompartible({super.key, required this.cancion});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 800,
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        color: AppColors.blanco,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.blanco, AppColors.grisClaro],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/logo.png',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 60,
                    height: 60,
                    color: AppColors.granate,
                    child: const Icon(Icons.music_note,
                        color: AppColors.dorado),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ALLIN KAWSAY',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.granate,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Grupo de Sikuris',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.negro,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Container(height: 2, color: AppColors.dorado),
          const SizedBox(height: 20),

          // Título
          Text(
            cancion.titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: AppColors.granate,
              letterSpacing: 1,
            ),
          ),

          if (cancion.autor.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              cancion.autor,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: AppColors.negro,
              ),
            ),
          ],

          if (cancion.ritmo.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              cancion.ritmo,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.negro.withOpacity(0.6),
              ),
            ),
          ],

          // Numerofonía
          if (cancion.tieneNumerofonia) ...[
            const SizedBox(height: 24),
            VisorNumerofonia(
              estrofas: cancion.estrofas,
              escala: 1.2,
            ),
          ],

          // Letra
          if (cancion.letra.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'LETRA',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.granate,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.blanco,
                border: Border.all(color: AppColors.negro, width: 1),
              ),
              child: Text(
                cancion.letra,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.9,
                  color: AppColors.negro,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),
          Container(height: 1, color: AppColors.dorado),
          const SizedBox(height: 8),

          // Footer
          const Text(
            'Compartido desde la app oficial',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.negro,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}