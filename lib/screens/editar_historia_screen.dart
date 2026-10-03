import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/historia.dart';
import '../services/historia_service.dart';
import '../theme/colors.dart';

class EditarHistoriaScreen extends StatefulWidget {
  const EditarHistoriaScreen({super.key});

  @override
  State<EditarHistoriaScreen> createState() =>
      _EditarHistoriaScreenState();
}

class _EditarHistoriaScreenState extends State<EditarHistoriaScreen> {
  final _ctrl = TextEditingController();
  bool _cargando = true;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final h = await HistoriaService().obtener();
    _ctrl.text = h.contenido;
    if (mounted) setState(() => _cargando = false);
  }

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await HistoriaService().guardar(Historia(
        contenido: _ctrl.text.trim(),
        actualizadoPor:
            user.displayName ?? user.email ?? 'Anónimo',
      ));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Historia guardada!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(title: const Text('EDITAR HISTORIA')),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(
                  color: AppColors.granate))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                // Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      AppColors.dorado.withOpacity(0.12),
                      AppColors.granate.withOpacity(0.06),
                    ]),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: AppColors.dorado.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.dorado.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.tips_and_updates_outlined,
                            color: AppColors.granate, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Escribí la historia del grupo. Podés usar '
                          'saltos de línea para separar secciones.',
                          style: TextStyle(
                            fontSize: 12,
                            color: onSurface.withOpacity(0.75),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Editor
                TextField(
                  controller: _ctrl,
                  maxLines: 20,
                  minLines: 15,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: onSurface),
                  decoration: const InputDecoration(
                    labelText: 'Historia del grupo',
                    alignLabelWithHint: true,
                    hintText:
                        'Fundación del grupo, primeros integrantes, '
                        'logros, viajes...',
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: _guardando ? null : _guardar,
                    icon: _guardando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.dorado,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(
                      _guardando ? 'GUARDANDO...' : 'GUARDAR HISTORIA',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}