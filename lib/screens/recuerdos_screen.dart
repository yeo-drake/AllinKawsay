import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/recuerdo.dart';
import '../models/usuario.dart';
import '../services/descarga_service.dart';
import '../services/recuerdo_service.dart';
import '../services/usuario_service.dart';
import '../theme/colors.dart';
import '../widgets/watermark_overlay.dart';
import 'agregar_recuerdo_screen.dart';
import 'foto_fullscreen_screen.dart';

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

  void _verFoto(String url,
      {String titulo = '', bool puedeDescargar = false}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FotoFullscreenScreen(
          url: url,
          titulo: titulo,
          puedeDescargar: puedeDescargar,
        ),
      ),
    );
  }

  Future<void> _descargarFoto(String url, {String titulo = ''}) async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: AppColors.dorado,
                  strokeWidth: 2.5,
                ),
              ),
              SizedBox(width: 12),
              Text('Descargando...'),
            ],
          ),
          duration: Duration(seconds: 30),
        ),
      );
    }

    final nombre = DescargaService.nombreConTimestamp(
        titulo.isEmpty ? 'recuerdo' : titulo, 'jpg');

    final resultado =
        await DescargaService.descargar(url, nombre, 'image/jpeg');

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (resultado != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle,
                    color: AppColors.dorado),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Guardado en Descargas: $resultado'),
                ),
              ],
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo descargar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final esAdmin = _usuario?.esAdmin ?? false;
    final puedeDescargar = _usuario?.puedeDescargar ?? false;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(title: const Text('RECUERDOS')),
      floatingActionButton: esAdmin
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AgregarRecuerdoScreen()),
              ),
              child: const Icon(Icons.add_photo_alternate, size: 24),
            )
          : null,
      body: WatermarkOverlay(
        opacity: 0.04,
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
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.granate.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.photo_library,
                            size: 48,
                            color: AppColors.granate.withOpacity(0.4)),
                      ),
                      const SizedBox(height: 20),
                      const Text('Sin recuerdos aún',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.granate,
                              letterSpacing: 0.5)),
                      const SizedBox(height: 8),
                      Text(
                        esAdmin
                            ? 'Toca el botón + para subir el primer recuerdo'
                            : 'El admin aún no ha subido fotos',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: onSurface.withOpacity(0.55),
                            fontSize: 13),
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
                final r = lista[i];
                final nota = _usuario?.notaRecuerdo(r.id) ?? '';
                return _tarjetaRecuerdo(
                    context, r, nota, esAdmin, puedeDescargar, onSurface);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _tarjetaRecuerdo(
    BuildContext context,
    Recuerdo r,
    String nota,
    bool esAdmin,
    bool puedeDescargar,
    Color onSurface,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.cardColor(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.dorado.withOpacity(0.25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.titulo,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: onSurface,
                                letterSpacing: 0.2)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.person_outline,
                                size: 11,
                                color: onSurface.withOpacity(0.45)),
                            const SizedBox(width: 3),
                            Text('Por ${r.creadorNombre}',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: onSurface.withOpacity(0.55))),
                            if (r.fecha != null) ...[
                              const SizedBox(width: 10),
                              Icon(Icons.calendar_today,
                                  size: 10,
                                  color: onSurface.withOpacity(0.45)),
                              const SizedBox(width: 3),
                              Text(
                                  '${r.fecha!.day}/${r.fecha!.month}/${r.fecha!.year}',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color:
                                          onSurface.withOpacity(0.55))),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Nota
                  IconButton(
                    icon: Icon(
                      nota.isEmpty
                          ? Icons.sticky_note_2_outlined
                          : Icons.sticky_note_2,
                      color: nota.isEmpty
                          ? onSurface.withOpacity(0.35)
                          : AppColors.dorado,
                      size: 20,
                    ),
                    onPressed: () => _editarNota(r),
                  ),
                  if (esAdmin)
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert,
                          color: onSurface.withOpacity(0.5), size: 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
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
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            // Descripción
            if (r.descripcion.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Text(r.descripcion,
                    style: TextStyle(
                        fontSize: 13,
                        color: onSurface.withOpacity(0.7),
                        height: 1.4)),
              ),
            // Fotos
            if (r.fotos.isNotEmpty)
              SizedBox(
                height: 150,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: r.fotos.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: 10),
                  itemBuilder: (context, j) {
                    return Stack(
                      children: [
                        GestureDetector(
                          onTap: () => _verFoto(
                            r.fotos[j],
                            titulo: '${r.titulo} (${j + 1}/${r.fotos.length})',
                            puedeDescargar: puedeDescargar,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: CachedNetworkImage(
                              imageUrl: r.fotos[j],
                              memCacheWidth: 300,
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                width: 150,
                                height: 150,
                                color: AppColors.grisClaro,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                      color: AppColors.granate),
                                ),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                width: 150,
                                height: 150,
                                color: AppColors.grisClaro,
                                child: const Icon(Icons.broken_image,
                                    color: AppColors.granate),
                              ),
                            ),
                          ),
                        ),
                        if (puedeDescargar)
                          Positioned(
                            bottom: 6,
                            right: 6,
                            child: GestureDetector(
                              onTap: () =>
                                  _descargarFoto(r.fotos[j],
                                      titulo: r.titulo),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.download,
                                  color: Colors.white,
                                  size: 15,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            // Nota personal
            if (nota.isNotEmpty)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    AppColors.dorado.withOpacity(0.12),
                    AppColors.dorado.withOpacity(0.05),
                  ]),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.dorado.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.sticky_note_2,
                        size: 14, color: AppColors.granate),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        nota,
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: onSurface.withOpacity(0.85),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }
}
