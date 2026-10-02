import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/recuerdo.dart';
import '../models/usuario.dart';
import '../services/recuerdo_service.dart';
import '../services/usuario_service.dart';
import '../theme/colors.dart';
import '../widgets/watermark_overlay.dart';
import 'agregar_recuerdo_screen.dart';

class RecuerdosScreen extends StatefulWidget {
  const RecuerdosScreen({super.key});

  @override
  State<RecuerdosScreen> createState() => _RecuerdosScreenState();
}

class _RecuerdosScreenState extends State<RecuerdosScreen> {
  final _service = RecuerdoService();
  Usuario? _usuario;

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
  }

  Future<void> _cargarUsuario() async {
    final u = await UsuarioService().miUsuarioActual();
    if (mounted) setState(() => _usuario = u);
  }

  void _eliminar(Recuerdo r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar recuerdo'),
        content: Text('¿Eliminar "${r.titulo}"?'),
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
    if (ok == true) await _service.eliminar(r.id);
  }

  void _editar(Recuerdo r) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AgregarRecuerdoScreen(recuerdo: r),
      ),
    );
  }

  Future<void> _editarNota(Recuerdo r) async {
    final ctrl = TextEditingController(
      text: _usuario?.notaRecuerdo(r.id) ?? '',
    );
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Nota: ${r.titulo}'),
        content: TextField(
          controller: ctrl,
          maxLines: 5,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Ej: yo estoy en la tercera foto, qué lindo día...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Guardar')),
        ],
      ),
    );
    if (ok == true) {
      await UsuarioService().guardarNotaRecuerdo(r.id, ctrl.text);
      await _cargarUsuario();
    }
  }

  void _verFoto(String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppColors.negro,
        insetPadding: const EdgeInsets.all(8),
        child: Stack(
          children: [
            InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: url,
                memCacheWidth: 1200,
                fit: BoxFit.contain,
                placeholder: (_, __) => const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.dorado),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: AppColors.dorado),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _descargarFoto(String url) async {
    final uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('No se pudo abrir la imagen')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final esAdmin = _usuario?.esAdmin ?? false;
    final puedeDescargar = _usuario?.puedeDescargar ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('RECUERDOS')),
      floatingActionButton: esAdmin
          ? FloatingActionButton(
              backgroundColor: AppColors.granate,
              foregroundColor: AppColors.dorado,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AgregarRecuerdoScreen()),
              ),
              child: const Icon(Icons.add_photo_alternate),
            )
          : null,
      body: WatermarkOverlay(
        child: StreamBuilder<List<Recuerdo>>(
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
                      Icon(Icons.photo_library,
                          size: 80,
                          color: AppColors.granate.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      const Text('Sin recuerdos aún',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.granate)),
                      const SizedBox(height: 8),
                      Text(
                        esAdmin
                            ? 'Toca el botón + para subir el primer recuerdo'
                            : 'El admin aún no ha subido fotos',
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
              padding: const EdgeInsets.all(12),
              itemCount: lista.length,
              itemBuilder: (context, i) {
                final r = lista[i];
                final nota = _usuario?.notaRecuerdo(r.id) ?? '';
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(r.titulo,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: AppColors.granate)),
                            ),
                            // Nota personal
                            IconButton(
                              icon: Icon(
                                nota.isEmpty
                                    ? Icons.sticky_note_2_outlined
                                    : Icons.sticky_note_2,
                                color: nota.isEmpty
                                    ? AppColors.negro.withOpacity(0.4)
                                    : AppColors.dorado,
                              ),
                              tooltip: 'Mi nota personal',
                              onPressed: () => _editarNota(r),
                            ),
                            if (esAdmin)
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert,
                                    color: AppColors.granate),
                                onSelected: (v) {
                                  if (v == 'editar') {
                                    _editar(r);
                                  } else if (v == 'eliminar') {
                                    _eliminar(r);
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
                                        Icon(Icons.delete_outline,
                                            size: 20),
                                        SizedBox(width: 8),
                                        Text('Eliminar'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        if (r.descripcion.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(r.descripcion,
                              style: TextStyle(
                                  color:
                                      AppColors.negro.withOpacity(0.7))),
                        ],
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Por ${r.creadorNombre}',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.negro
                                        .withOpacity(0.5)),
                              ),
                            ),
                            if (r.fecha != null)
                              Text(
                                '${r.fecha!.day}/${r.fecha!.month}/${r.fecha!.year}',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.negro
                                        .withOpacity(0.5)),
                              ),
                          ],
                        ),
                        if (r.fotos.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 130,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: r.fotos.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (context, j) {
                                return Stack(
                                  children: [
                                    GestureDetector(
                                      onTap: () => _verFoto(r.fotos[j]),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        child: CachedNetworkImage(
                                          imageUrl: r.fotos[j],
                                          memCacheWidth: 300,
                                          width: 130,
                                          height: 130,
                                          fit: BoxFit.cover,
                                          placeholder: (_, __) =>
                                              Container(
                                            width: 130,
                                            height: 130,
                                            color: AppColors.grisClaro,
                                            child: const Center(
                                              child:
                                                  CircularProgressIndicator(
                                                      color: AppColors
                                                          .granate),
                                            ),
                                          ),
                                          errorWidget: (_, __, ___) =>
                                              Container(
                                            width: 130,
                                            height: 130,
                                            color: AppColors.grisClaro,
                                            child: const Icon(
                                                Icons.broken_image,
                                                color:
                                                    AppColors.granate),
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (puedeDescargar)
                                      Positioned(
                                        bottom: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () => _descargarFoto(
                                              r.fotos[j]),
                                          child: Container(
                                            padding:
                                                const EdgeInsets.all(6),
                                            decoration:
                                                const BoxDecoration(
                                              color: Colors.black54,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.download,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                        // Nota visible
                        if (nota.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.dorado.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: AppColors.dorado
                                      .withOpacity(0.5)),
                            ),
                            child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.sticky_note_2,
                                    size: 16, color: AppColors.granate),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    nota,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontStyle: FontStyle.italic,
                                      color: AppColors.negro,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
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