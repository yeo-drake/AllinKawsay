import 'package:flutter/material.dart';
import '../models/categoria.dart';
import '../services/categoria_service.dart';
import '../theme/colors.dart';

class GestionCategoriasScreen extends StatefulWidget {
  const GestionCategoriasScreen({super.key});

  @override
  State<GestionCategoriasScreen> createState() =>
      _GestionCategoriasScreenState();
}

class _GestionCategoriasScreenState
    extends State<GestionCategoriasScreen> {
  final _service = CategoriaService();

  void _abrirFormulario({Categoria? categoria}) {
    final nombreCtrl = TextEditingController(text: categoria?.nombre ?? '');
    final emojiCtrl = TextEditingController(text: categoria?.emoji ?? '📁');
    final ordenCtrl = TextEditingController(
        text: (categoria?.orden ?? 0).toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(categoria == null ? 'Nueva categoría' : 'Editar'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emojiCtrl,
                maxLength: 2,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 32),
                decoration: const InputDecoration(
                  labelText: 'Emoji',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nombreCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  hintText: 'Ej: Carnaval, Religioso',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ordenCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Orden (0 = primero)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              final nombre = nombreCtrl.text.trim();
              final emoji = emojiCtrl.text.trim();
              final orden =
                  int.tryParse(ordenCtrl.text.trim()) ?? 0;

              if (nombre.isEmpty) return;

              try {
                if (categoria == null) {
                  await _service.agregar(Categoria(
                    id: '',
                    nombre: nombre,
                    emoji: emoji.isEmpty ? '📁' : emoji,
                    orden: orden,
                  ));
                } else {
                  await _service.actualizar(categoria.id, {
                    'nombre': nombre,
                    'emoji': emoji.isEmpty ? '📁' : emoji,
                    'orden': orden,
                  });
                }
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminar(Categoria c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar categoría'),
        content: Text(
            '¿Eliminar "${c.emoji} ${c.nombre}"?\n\n'
            'Las canciones que tenían esta categoría quedarán sin categoría.'),
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
    if (ok == true) {
      await _service.eliminar(c.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CATEGORÍAS')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.granate,
        foregroundColor: AppColors.dorado,
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Categoria>>(
        stream: _service.listar(),
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
                  'Verificá que hayas publicado las reglas nuevas.',
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
                    Icon(Icons.category,
                        size: 80,
                        color: AppColors.granate.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    const Text('Sin categorías',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.granate)),
                    const SizedBox(height: 8),
                    Text(
                      'Toca el botón + para crear la primera.\n'
                      'Ejemplos: 🎭 Carnaval, ⛪ Religioso, 💃 Huayño',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.negro.withOpacity(0.6),
                          height: 1.5),
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
              final c = lista[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.granate.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(c.emoji,
                        style: const TextStyle(fontSize: 22)),
                  ),
                  title: Text(c.nombre,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.negro)),
                  subtitle: Text('Orden: ${c.orden}'),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert,
                        color: AppColors.granate),
                    onSelected: (v) {
                      if (v == 'editar') {
                        _abrirFormulario(categoria: c);
                      } else if (v == 'eliminar') {
                        _confirmarEliminar(c);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'editar',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'eliminar',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 20),
                            SizedBox(width: 8),
                            Text('Eliminar'),
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