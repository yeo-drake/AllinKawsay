import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/usuario_service.dart';
import '../theme/colors.dart';

class GestionUsuariosScreen extends StatelessWidget {
  const GestionUsuariosScreen({super.key});

  Color _colorRol(String rol) {
    switch (rol) {
      case 'admin':
        return AppColors.granate;
      case 'miembro':
        return const Color(0xFF8B0000);
      default:
        return AppColors.negro;
    }
  }

  void _cambiarRol(BuildContext context, Usuario u, String nuevoRol) async {
    if (u.rol == nuevoRol) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cambiar rol'),
        content: Text(
            '¿Cambiar a "${u.nombre}" al rol ${nuevoRol.toUpperCase()}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirmar')),
        ],
      ),
    );
    if (ok == true) {
      try {
        await UsuarioService().cambiarRol(u.uid, nuevoRol);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    '${u.nombre} ahora es ${nuevoRol.toUpperCase()}')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GESTIÓN DE USUARIOS')),
      body: StreamBuilder<List<Usuario>>(
        stream: UsuarioService().listar(),
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
                child: Text('Error: ${snap.error}',
                    textAlign: TextAlign.center),
              ),
            );
          }
          final lista = snap.data ?? [];
          if (lista.isEmpty) {
            return const Center(child: Text('Sin usuarios'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: lista.length,
            itemBuilder: (context, i) {
              final u = lista[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _colorRol(u.rol),
                    child: Text(
                      u.nombre.isNotEmpty
                          ? u.nombre[0].toUpperCase()
                          : '?',
                      style: const TextStyle(color: AppColors.dorado),
                    ),
                  ),
                  title: Text(u.nombre,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.negro)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(u.email,
                          style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _colorRol(u.rol),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          u.rolNombre,
                          style: const TextStyle(
                            color: AppColors.dorado,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert,
                        color: AppColors.granate),
                    onSelected: (rol) => _cambiarRol(context, u, rol),
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'publico',
                        child: Row(
                          children: [
                            Icon(Icons.person_outline, size: 20),
                            SizedBox(width: 8),
                            Text('Público'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'miembro',
                        child: Row(
                          children: [
                            Icon(Icons.verified_user, size: 20),
                            SizedBox(width: 8),
                            Text('Miembro oficial'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'admin',
                        child: Row(
                          children: [
                            Icon(Icons.admin_panel_settings, size: 20),
                            SizedBox(width: 8),
                            Text('Administrador'),
                          ],
                        ),
                      ),
                    ],
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