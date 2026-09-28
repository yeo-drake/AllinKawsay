import 'package:flutter/material.dart';
import '../models/cancion.dart';
import '../services/cancion_service.dart';
import '../services/usuario_service.dart';
import '../theme/colors.dart';
import 'agregar_cancion_screen.dart';
import 'cancion_detalle_screen.dart';

class CancioneroScreen extends StatefulWidget {
  const CancioneroScreen({super.key});

  @override
  State<CancioneroScreen> createState() => _CancioneroScreenState();
}

class _CancioneroScreenState extends State<CancioneroScreen> {
  final _service = CancionService();
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

  void _eliminar(Cancion c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar canción'),
        content: Text('¿Eliminar "${c.titulo}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok == true) await _service.eliminar(c.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CANCIONERO')),
      floatingActionButton: _esAdmin
          ? FloatingActionButton(
              backgroundColor: AppColors.granate,
              foregroundColor: AppColors.dorado,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AgregarCancionScreen()),
              ),
              child: const Icon(Icons.add),
            )
          : null,
      body: StreamBuilder<List<Cancion>>(
        stream: _service.listar(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                    CircularProgressIndicator(color: AppColors.granate));
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final lista = snap.data ?? [];
          if (lista.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.library_music,
                        size: 80,
                        color: AppColors.granate.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    const Text(
                      'Aún no hay canciones',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.granate),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _esAdmin
                          ? 'Toca el botón + para agregar la primera'
                          : 'El admin del grupo aún no ha subido canciones',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.negro.withOpacity(0.6)),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            itemCount: lista.length,
            itemBuilder: (context, i) {
              final c = lista[i];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.granate,
                  child: Text('${i + 1}',
                      style: const TextStyle(color: AppColors.dorado)),
                ),
                title: Text(c.titulo,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.negro)),
                subtitle: Text('${c.ritmo} · ${c.region}'),
                trailing: _esAdmin
                    ? IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: AppColors.granate),
                        onPressed: () => _eliminar(c),
                      )
                    : const Icon(Icons.chevron_right,
                        color: AppColors.dorado),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => CancionDetalleScreen(cancion: c)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}