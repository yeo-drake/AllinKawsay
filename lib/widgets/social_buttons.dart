import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialButtons extends StatelessWidget {
  const SocialButtons({super.key});

  // ⚠️ CAMBIA ESTAS URLs POR LAS DE TU GRUPO
  static const String _facebook = 'https://www.facebook.com/share/1CvfrrGhag/';
  static const String _tiktok = 'https://www.tiktok.com/@allin.kawsay';
  static const String _whatsapp =
      'https://chat.whatsapp.com/FKfCZogyh6aAwaTzKzbyMY?s=cl&p=a&mlu=4&ilr=4';

  Future<void> _abrir(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo abrir el enlace')),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Síguenos',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6E1423))),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _boton(
                context,
                icono: Icons.facebook,
                color: const Color(0xFF1877F2),
                label: 'Facebook',
                url: _facebook,
              ),
              _boton(
                context,
                icono: Icons.music_note,
                color: const Color(0xFF000000),
                label: 'TikTok',
                url: _tiktok,
              ),
              _boton(
                context,
                icono: Icons.chat,
                color: const Color(0xFF25D366),
                label: 'WhatsApp',
                url: _whatsapp,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _boton(
    BuildContext context, {
    required IconData icono,
    required Color color,
    required String label,
    required String url,
  }) {
    return GestureDetector(
      onTap: () => _abrir(context, url),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icono, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}