import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/colors.dart';
import '../utils/youtube_helper.dart';

class TarjetaVideo extends StatelessWidget {
  final String url;
  final String titulo;
  const TarjetaVideo({
    super.key,
    required this.url,
    required this.titulo,
  });

  Future<void> _abrir(BuildContext context) async {
    final uri = Uri.parse(url);
    try {
      // Intenta abrir la app de YouTube primero
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('No se pudo abrir el video')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final id = YoutubeHelper.extraerId(url);

    // Si no es un link de YouTube, mostrar botón simple
    if (id == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: OutlinedButton.icon(
          onPressed: () => _abrir(context),
          icon: const Icon(Icons.video_library),
          label: const Text('Ver video'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            foregroundColor: AppColors.granate,
            side: const BorderSide(color: AppColors.granate, width: 1.5),
          ),
        ),
      );
    }

    final thumbUrl =
        'https://img.youtube.com/vi/$id/hqdefault.jpg';

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: GestureDetector(
        onTap: () => _abrir(context),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                  color: AppColors.granate.withOpacity(0.3), width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Miniatura + play
                Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: CachedNetworkImage(
                        imageUrl: thumbUrl,
                        fit: BoxFit.cover,
                        memCacheWidth: 640,
                        placeholder: (_, __) => Container(
                          color: AppColors.negro,
                          child: const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.dorado),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.negro,
                          child: const Center(
                            child: Icon(Icons.video_library,
                                color: AppColors.dorado, size: 60),
                          ),
                        ),
                      ),
                    ),
                    // Botón de play gigante
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                    // Badge "YouTube"
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF0000),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.play_arrow,
                                color: Colors.white, size: 14),
                            SizedBox(width: 2),
                            Text(
                              'YouTube',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // Info
                Container(
                  padding: const EdgeInsets.all(12),
                  color: AppColors.blanco,
                  child: Row(
                    children: [
                      const Icon(Icons.video_library,
                          color: AppColors.granate, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Ver video de "$titulo"',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.negro,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.open_in_new,
                          color: AppColors.dorado, size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}