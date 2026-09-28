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
    return Scaffold(
      appBar: AppBar(title: const Text('EDITAR HISTORIA')),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.granate))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Escribe la historia del grupo. Puedes usar saltos de línea '
                  'para separar secciones.',
                  style: TextStyle(color: AppColors.negro),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _ctrl,
                  maxLines: 20,
                  minLines: 15,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Historia del grupo',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: _guardando ? null : _guardar,
                    icon: const Icon(Icons.save),
                    label: const Text('GUARDAR HISTORIA',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
    );
  }
}