import 'package:flutter/material.dart';
import '../services/actividad_service.dart';
import '../theme/colors.dart';

class ActividadScreen extends StatelessWidget {
  const ActividadScreen({super.key});

  IconData _icono(String accion) {
    if (accion.contains('crear_cancion') ||
        accion.contains('editar_cancion') ||
        accion.contains('eliminar_cancion')) {
      return Icons.library_music;
    }
    if (accion.contains('evento')) return Icons.event;
    if (accion.contains('recuerdo')) return Icons.photo_library;
    if (accion.contains('historia')) return Icons.history_edu;
    if (accion.contains('rol') || accion.contains('usuario')) {
      return Icons.people;
    }
    if (accion.contains('nombre')) return Icons.person;
    return Icons.info;
  }

  Color _color(String accion) {
    if (accion.contains('crear')) return Colors.green;
    if (accion.contains('editar')) return AppColors.dorado;
    if (accion.contains('eliminar')) return AppColors.granate;
    return AppColors.negro;
  }

  String _formatoFecha(DateTime? d) {
    if (d == null) return '...';
    final hoy = DateTime.now();
    final diff = hoy.difference(d);

    if (diff.inMinutes < 1) return 'Hace un momento';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} d';

    return '${d.day}/${d.month}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HISTORIAL DE ACTIVIDAD')),
      body: StreamBuilder<List<Actividad>>(
        stream: ActividadService().listar(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                    CircularProgressIndicator(color: AppColors.granate));
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Error: ${snap.error}\n\n'
                  'Verificá que hayas publicado las reglas nuevas de Firestore.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final lista = snap.data ?? [];
          if (lista.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history,
                        size: 80,
                        color: AppColors.granate.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    const Text(
                      'Sin actividad registrada',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.granate),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Las acciones del grupo aparecerán acá.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.negro.withOpacity(0.5)),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: lista.length,
            itemBuilder: (context, i) {
              final a = lista[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _color(a.accion).withOpacity(0.15),
                    child: Icon(
                      _icono(a.accion),
                      color: _color(a.accion),
                      size: 22,
                    ),
                  ),
                  title: Text(
                    a.detalle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.negro,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.person,
                            size: 12, color: AppColors.granate),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            a.autorNombre,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.negro.withOpacity(0.7),
                            ),
                          ),
                        ),
                        Text(
                          _formatoFecha(a.fecha),
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.negro.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}