import 'package:flutter/material.dart';
import '../models/historia.dart';
import '../services/historia_service.dart';
import '../services/usuario_service.dart';
import '../theme/colors.dart';
import 'editar_historia_screen.dart';

class HistoriaScreen extends StatefulWidget {
  const HistoriaScreen({super.key});

  @override
  State<HistoriaScreen> createState() => _HistoriaScreenState();
}

class _HistoriaScreenState extends State<HistoriaScreen> {
  bool _esAdmin = false;

  @override
  void initState() {
    super.initState();
    _chequearAdmin();
  }

  Future<void> _chequearAdmin() async {
    final a = await UsuarioService().soyAdmin();
    if (mounted) setState(() => _esAdmin = a);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NUESTRA HISTORIA'),
        actions: [
          if (_esAdmin)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const EditarHistoriaScreen()),
              ),
            ),
        ],
      ),
      body: StreamBuilder<Historia>(
        stream: HistoriaService().stream(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                    CircularProgressIndicator(color: AppColors.granate));
          }
          final h = snap.data;
          if (h == null || h.contenido.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history_edu,
                        size: 80,
                        color: AppColors.granate.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    const Text('Historia vacía',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.granate)),
                    const SizedBox(height: 8),
                    Text(
                      _esAdmin
                          ? 'Toca el lápiz de arriba para escribir la historia del grupo'
                          : 'El admin aún no ha escrito la historia',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.negro.withOpacity(0.6)),
                    ),
                  ],
                ),
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Historia del grupo',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.granate)),
                const SizedBox(height: 12),
                Text(h.contenido,
                    style: const TextStyle(fontSize: 16, height: 1.6)),
                if (h.actualizadoPor.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  const Divider(),
                  Text(
                    'Última edición: ${h.actualizadoPor}',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.negro.withOpacity(0.5)),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}