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