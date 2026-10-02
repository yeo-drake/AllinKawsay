import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/descarga_service.dart';
import '../theme/colors.dart';

class FotoFullscreenScreen extends StatefulWidget {
  final String url;
  final String titulo;
  final bool puedeDescargar;
  const FotoFullscreenScreen({
    super.key,
    required this.url,
    this.titulo = '',
    this.puedeDescargar = false,
  });

  @override
  State<FotoFullscreenScreen> createState() =>
      _FotoFullscreenScreenState();
}

class _FotoFullscreenScreenState extends State<FotoFullscreenScreen> {
  final _transformController = TransformationController();
  bool _zoomActivo = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _transformController.addListener(() {
      final z = _transformController.value.getMaxScaleOnAxis();
      if ((z > 1.05) != _zoomActivo) {
        setState(() => _zoomActivo = z > 1.05);
      }
    });
  }

  @override
  void dispose() {
    _transformController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  void _toggleZoom(TapDownDetails details) {
    if (_zoomActivo) {
      _transformController.value = Matrix4.identity();
    } else {
      final pos = details.localPosition;
      const escala = 2.5;
      final x = -pos.dx * (escala - 1);
      final y = -pos.dy * (escala - 1);
      _transformController.value = Matrix4.identity()
        ..translate(x, y)
        ..scale(escala);
    }
  }

  Future<void> _descargar() async {
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
        widget.titulo.isEmpty ? 'foto_allin_kawsay' : widget.titulo,
        'jpg');

    final resultado =
        await DescargaService.descargar(widget.url, nombre, 'image/jpeg');

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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onDoubleTapDown: _toggleZoom,
              onDoubleTap: () {},
              child: InteractiveViewer(
                transformationController: _transformController,
                minScale: 1.0,
                maxScale: 4.0,
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: widget.url,
                    fit: BoxFit.contain,
                    placeholder: (_, __) => const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.dorado),
                    ),
                    errorWidget: (_, __, ___) => const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.broken_image,
                              color: AppColors.dorado, size: 60),
                          SizedBox(height: 12),
                          Text('No se pudo cargar la imagen',
                              style: TextStyle(color: AppColors.dorado)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Barra superior
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: AppColors.dorado),
                      onPressed: () => Navigator.pop(context),
                    ),
                    if (widget.titulo.isNotEmpty)
                      Expanded(
                        child: Text(
                          widget.titulo,
                          style: const TextStyle(
                            color: AppColors.dorado,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    else
                      const Spacer(),
                    if (widget.puedeDescargar)
                      IconButton(
                        icon: const Icon(Icons.download,
                            color: AppColors.dorado),
                        tooltip: 'Descargar',
                        onPressed: _descargar,
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Hint para hacer zoom
          if (!_zoomActivo)
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Doble tap para zoom • Pellizcá para ampliar',
                    style: TextStyle(
                        color: AppColors.dorado, fontSize: 11),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}