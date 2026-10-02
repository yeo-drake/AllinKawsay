import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../models/cancion.dart';
import '../services/compartir_service.dart';
import '../theme/colors.dart';
import '../widgets/tarjeta_compartible.dart';

class CompartirImagenScreen extends StatefulWidget {
  final Cancion cancion;
  const CompartirImagenScreen({super.key, required this.cancion});

  @override
  State<CompartirImagenScreen> createState() =>
      _CompartirImagenScreenState();
}

class _CompartirImagenScreenState extends State<CompartirImagenScreen> {
  final _repaintKey = GlobalKey();
  bool _compartiendo = false;

  Future<void> _compartir() async {
    setState(() => _compartiendo = true);
    try {
      await Future.delayed(const Duration(milliseconds: 200));

      final boundary = _repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('No se pudo capturar la imagen');
      }

      // Verificar que el boundary tenga tamaño válido
      final size = boundary.size;
      if (size.width.isInfinite ||
          size.height.isInfinite ||
          size.width <= 0 ||
          size.height <= 0) {
        throw Exception('Tamaño de imagen inválido');
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('No se pudo generar el PNG');
      }

      final Uint8List bytes = byteData.buffer.asUint8List();
      final nombre =
          'allin_kawsay_${widget.cancion.titulo.replaceAll(" ", "_")}.png';

      await CompartirService.compartirImagen(bytes, nombre);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Listo para compartir!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _compartiendo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisClaro,
      appBar: AppBar(
        title: const Text('COMPARTIR IMAGEN'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 2.0,
                child: Center(
                  // Envolver con SizedBox de tamaño fijo para que
                  // RenderRepaintBoundary no tenga dimensiones infinitas
                  child: RepaintBoundary(
                    key: _repaintKey,
                    child: SizedBox(
                      width: 800,
                      child: Material(
                        color: AppColors.blanco,
                        child: TarjetaCompartible(
                            cancion: widget.cancion),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _compartiendo ? null : _compartir,
                  icon: _compartiendo
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.dorado,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Icon(Icons.share),
                  label: Text(
                    _compartiendo
                        ? 'GENERANDO...'
                        : 'COMPARTIR IMAGEN',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}