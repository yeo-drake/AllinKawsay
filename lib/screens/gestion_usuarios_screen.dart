import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/usuario_service.dart';
import '../theme/colors.dart';
import '../widgets/watermark_overlay.dart';

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('GESTIÓN DE USUARIOS'),
        backgroundColor: AppColors.granate,
        foregroundColor: AppColors.dorado,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            color: AppColors.granate,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.dorado,
              indicatorWeight: 3,
              labelColor: AppColors.dorado,
              unselectedLabelColor: AppColors.dorado.withOpacity(0.5),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                fontSize: 12,
              ),
              tabs: const [
                Tab(
                    text: 'ACTIVOS',
                    icon: Icon(Icons.people, size: 20)),
                Tab(
                    text: 'BANEADOS',
                    icon: Icon(Icons.block, size: 20)),
              ],
            ),
          ),
        ),
      ),
      body: WatermarkOverlay(
        opacity: 0.04,
        child: TabBarView(
          controller: _tabController,
          children: [
            _ListaUsuarios(baneados: false),
            _ListaUsuarios(baneados: true),
          ],
        ),
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
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
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
        final lista = snap.data ?? [];
        if (lista.isEmpty) {
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
                    child: Icon(
                      baneados
                          ? Icons.check_circle_outline
                          : Icons.people_outline,
                      size: 48,
                      color: AppColors.granate.withOpacity(0.4),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    baneados
                        ? 'No hay usuarios suspendidos'
                        : 'No hay usuarios activos',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.granate,
                        letterSpacing: 0.5),
                  ),
                ],
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: lista.length,
          itemBuilder: (context, i) {
            final u = lista[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardColor(context),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: baneados
                        ? Colors.red.withOpacity(0.3)
                        : AppColors.dorado.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: baneados
                            ? LinearGradient(colors: [
                                Colors.grey,
                                Colors.grey.shade700,
                              ])
                            : AppColors.gradienteGranate,
                      ),
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor:
                            Theme.of(context).colorScheme.surface,
                        backgroundImage: u.fotoUrl.isNotEmpty
                            ? NetworkImage(u.fotoUrl)
                            : null,
                        child: u.fotoUrl.isEmpty
                            ? Text(
                                u.nombre.isNotEmpty
                                    ? u.nombre[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: AppColors.dorado,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            u.nombre,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: baneados
                                  ? onSurface.withOpacity(0.5)
                                  : onSurface,
                              decoration: baneados
                                  ? TextDecoration.lineThrough
                                  : null,
                              fontSize: 14,
                              letterSpacing: 0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(u.email,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: onSurface.withOpacity(0.55)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: baneados
                                  ? Colors.red
                                  : _colorRol(u.rol),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              u.rolNombre,
                              style: const TextStyle(
                                color: AppColors.dorado,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (baneados)
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.green.withOpacity(0.4)),
                          ),
                          child: const Icon(Icons.restore,
                              color: Colors.green, size: 18),
                        ),
                        tooltip: 'Reactivar',
                        onPressed: () => _desbanear(context, u),
                      )
                    else
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert,
                            color: onSurface.withOpacity(0.5),
                            size: 20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        onSelected: (v) {
                          if (v == 'publico' ||
                              v == 'miembro' ||
                              v == 'admin') {
                            _cambiarRol(context, u, v);
                          } else if (v == 'banear') {
                            _banear(context, u);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'publico',
                            child: Row(
                              children: [
                                Icon(Icons.person_outline, size: 20),
                                SizedBox(width: 10),
                                Text('Público'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'miembro',
                            child: Row(
                              children: [
                                Icon(Icons.verified_user, size: 20),
                                SizedBox(width: 10),
                                Text('Miembro oficial'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'admin',
                            child: Row(
                              children: [
                                Icon(Icons.admin_panel_settings,
                                    size: 20),
                                SizedBox(width: 10),
                                Text('Administrador'),
                              ],
                            ),
                          ),
                          PopupMenuDivider(),
                          PopupMenuItem(
                            value: 'banear',
                            child: Row(
                              children: [
                                Icon(Icons.block,
                                    size: 20, color: Colors.red),
                                SizedBox(width: 10),
                                Text('Suspender',
                                    style:
                                        TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
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