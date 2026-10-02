import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/usuario_service.dart';
import '../theme/colors.dart';

class GestionUsuariosScreen extends StatefulWidget {
  const GestionUsuariosScreen({super.key});

  @override
  State<GestionUsuariosScreen> createState() =>
      _GestionUsuariosScreenState();
}

class _GestionUsuariosScreenState extends State<GestionUsuariosScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GESTIÓN DE USUARIOS'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.dorado,
          unselectedLabelColor: AppColors.dorado.withOpacity(0.5),
          indicatorColor: AppColors.dorado,
          tabs: const [
            Tab(text: 'ACTIVOS', icon: Icon(Icons.people, size: 18)),
            Tab(text: 'BANEADOS', icon: Icon(Icons.block, size: 18)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ListaUsuarios(baneados: false),
          _ListaUsuarios(baneados: true),
        ],
      ),
    );
  }
}

class _ListaUsuarios extends StatelessWidget {
  final bool baneados;
  const _ListaUsuarios({required this.baneados});

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

  void _banear(BuildContext context, Usuario u) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Suspender usuario'),
        content: Text(
            '¿Suspender a "${u.nombre}"?\n\n'
            'No podrá entrar a la app hasta que lo reactives. '
            'Sus datos se conservan.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                  backgroundColor: Colors.red),
              child: const Text('Suspender')),
        ],
      ),
    );
    if (ok == true) {
      try {
        await UsuarioService().banear(u.uid);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${u.nombre} fue suspendido')),
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

  void _desbanear(BuildContext context, Usuario u) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reactivar usuario'),
        content: Text('¿Reactivar a "${u.nombre}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Reactivar')),
        ],
      ),
    );
    if (ok == true) {
      try {
        await UsuarioService().desbanear(u.uid);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${u.nombre} fue reactivado')),
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
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final stream = baneados
        ? UsuarioService().listarBaneados()
        : UsuarioService().listar();

    return StreamBuilder<List<Usuario>>(
      stream: stream,
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
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    baneados ? Icons.check_circle : Icons.people,
                    size: 60,
                    color: AppColors.granate.withOpacity(0.3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    baneados
                        ? 'No hay usuarios suspendidos'
                        : 'No hay usuarios activos',
                    style: TextStyle(color: onSurface.withOpacity(0.6)),
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
            final u = lista[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      baneados ? Colors.grey : _colorRol(u.rol),
                  backgroundImage: u.fotoUrl.isNotEmpty
                      ? NetworkImage(u.fotoUrl)
                      : null,
                  child: u.fotoUrl.isEmpty
                      ? Text(
                          u.nombre.isNotEmpty
                              ? u.nombre[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                              color: AppColors.dorado),
                        )
                      : null,
                ),
                title: Text(u.nombre,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: baneados ? onSurface.withOpacity(0.5) : onSurface,
                        decoration: baneados
                            ? TextDecoration.lineThrough
                            : null)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(u.email,
                        style: TextStyle(
                            fontSize: 12,
                            color: onSurface.withOpacity(0.6))),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: baneados ? Colors.red : _colorRol(u.rol),
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
                trailing: baneados
                    ? IconButton(
                        icon: const Icon(Icons.restore,
                            color: Colors.green),
                        tooltip: 'Reactivar',
                        onPressed: () => _desbanear(context, u),
                      )
                    : PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert,
                            color: onSurface.withOpacity(0.6)),
                        onSelected: (v) {
                          if (v == 'publico' ||
                              v == 'miembro' ||
                              v == 'admin') {
                            _cambiarRol(context, u, v);
                          } else if (v == 'banear') {
                            _banear(context, u);
                          }
                        },
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
                                Icon(Icons.admin_panel_settings,
                                    size: 20),
                                SizedBox(width: 8),
                                Text('Administrador'),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(),
                          const PopupMenuItem(
                            value: 'banear',
                            child: Row(
                              children: [
                                Icon(Icons.block,
                                    size: 20, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Suspender',
                                    style:
                                        TextStyle(color: Colors.red)),
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
    );
  }
}