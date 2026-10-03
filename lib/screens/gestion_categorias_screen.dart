import 'package:flutter/material.dart';
import '../models/categoria.dart';
import '../services/categoria_service.dart';
import '../theme/colors.dart';
import '../widgets/watermark_overlay.dart';

class GestionCategoriasScreen extends StatefulWidget {
  const GestionCategoriasScreen({super.key});

  @override
  State<GestionCategoriasScreen> createState() =>
      _GestionCategoriasScreenState();
}

class _GestionCategoriasScreenState extends State<GestionCategoriasScreen> {
  final _service = CategoriaService();

  void _abrirFormulario({Categoria? categoria}) {
    final nombreCtrl =
        TextEditingController(text: categoria?.nombre ?? '');
    final emojiCtrl = TextEditingController(text: categoria?.emoji ?? '📁');
    final ordenCtrl = TextEditingController(
        text: (categoria?.orden ?? 0).toString());

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.dorado,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  categoria == null
                      ? 'Nueva categoría'
                      : 'Editar categoría',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.granate,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Emoji
                Row(
                  children: [
                    SizedBox(
                      width: 90,
                      child: TextField(
                        controller: emojiCtrl,
                        textAlign: TextAlign.center,
                        maxLength: 2,
                        style: const TextStyle(fontSize: 32),
                        decoration: const InputDecoration(
                          labelText: 'Emoji',
                          counterText: '',
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: nombreCtrl,
                        textCapitalization:
                            TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Nombre',
                          hintText: 'Ej: Carnaval, Religioso',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ordenCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Orden (0 = primero)',
                    prefixIcon: Icon(Icons.sort),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: FilledButton(
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
                        if (mounted) Navigator.pop(context);
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(
                                  content: Text('Error: $e')));
                        }
                      }
                    },
                    child: Text(
                      categoria == null ? 'CREAR' : 'GUARDAR',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
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
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(title: const Text('CATEGORÍAS')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add, size: 26),
      ),
      body: WatermarkOverlay(
        opacity: 0.04,
        child: StreamBuilder<List<Categoria>>(
          stream: _service.listar(),
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
                  child: Text(
                    'Error: ${snap.error}\n\n'
                    'Verificá que hayas publicado las reglas de Firestore.',
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
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.granate.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.category_outlined,
                            size: 48,
                            color: AppColors.granate.withOpacity(0.4)),
                      ),
                      const SizedBox(height: 20),
                      const Text('Sin categorías',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.granate,
                              letterSpacing: 0.5)),
                      const SizedBox(height: 8),
                      Text(
                        'Toca el botón + para crear la primera.\n'
                        'Ejemplos: 🎭 Carnaval, ⛪ Religioso, 💃 Huayño',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: onSurface.withOpacity(0.55),
                            fontSize: 12,
                            height: 1.6),
                      ),
                    ],
                  ),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: lista.length,
              itemBuilder: (context, i) {
                final c = lista[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardColor(context),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: AppColors.dorado.withOpacity(0.2)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: AppColors.gradienteGranate,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.granate
                                      .withOpacity(0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Text(c.emoji,
                                style: const TextStyle(fontSize: 26)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(c.nombre,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: onSurface,
                                        fontSize: 15,
                                        letterSpacing: 0.2)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.sort,
                                        size: 11,
                                        color: onSurface
                                            .withOpacity(0.4)),
                                    const SizedBox(width: 3),
                                    Text('Orden: ${c.orden}',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: onSurface
                                                .withOpacity(0.5))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert,
                                color: onSurface.withOpacity(0.5),
                                size: 20),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
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
                                    SizedBox(width: 10),
                                    Text('Editar'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'eliminar',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline,
                                        size: 20, color: Colors.red),
                                    SizedBox(width: 10),
                                    Text('Eliminar',
                                        style: TextStyle(
                                            color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
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
      ),
    );
  }
}