import 'package:flutter/material.dart';
import '../models/historia.dart';
import '../services/historia_service.dart';
import '../services/usuario_service.dart';
import '../theme/colors.dart';
import '../widgets/watermark_overlay.dart';
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
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: const Text('NUESTRA HISTORIA'),
        actions: [
          if (_esAdmin)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const EditarHistoriaScreen()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.dorado.withOpacity(0.4)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit,
                            size: 14, color: AppColors.dorado),
                        SizedBox(width: 6),
                        Text('Editar',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.dorado,
                                letterSpacing: 0.5)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: WatermarkOverlay(
        opacity: 0.05,
        child: StreamBuilder<Historia>(
          stream: HistoriaService().stream(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.granate));
            }
            if (snap.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Error: ${snap.error}',
                      textAlign: TextAlign.center),
                ),
              );
            }
            final h = snap.data;
            if (h == null || h.contenido.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.granate.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.history_edu,
                            size: 48,
                            color: AppColors.granate.withOpacity(0.4)),
                      ),
                      const SizedBox(height: 20),
                      const Text('Historia vacía',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.granate,
                              letterSpacing: 0.5)),
                      const SizedBox(height: 8),
                      Text(
                        _esAdmin
                            ? 'Toca el botón "Editar" para escribir la historia del grupo'
                            : 'El admin aún no ha escrito la historia',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: onSurface.withOpacity(0.55),
                            fontSize: 13),
                      ),
                    ],
                  ),
                ),
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header decorativo
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.granate.withOpacity(0.08),
                          AppColors.dorado.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.dorado.withOpacity(0.25)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: AppColors.gradienteDorado,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.dorado
                                    .withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.auto_stories,
                              color: AppColors.granate, size: 22),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Text('Historia del grupo',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.granate,
                                  letterSpacing: 0.5)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Contenido
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.cardColor(context),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.dorado.withOpacity(0.2)),
                    ),
                    child: Text(
                      h.contenido,
                      style: TextStyle(
                          fontSize: 15,
                          height: 1.8,
                          color: onSurface.withOpacity(0.9),
                          letterSpacing: 0.2),
                    ),
                  ),
                  if (h.actualizadoPor.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.granate.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.edit_note,
                              size: 16,
                              color: onSurface.withOpacity(0.5)),
                          const SizedBox(width: 8),
                          Text(
                            'Última edición: ${h.actualizadoPor}',
                            style: TextStyle(
                                fontSize: 11,
                                color: onSurface.withOpacity(0.55),
                                letterSpacing: 0.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}