import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/numerofonia.dart';
import '../theme/colors.dart';
import '../widgets/visor_numerofonia.dart';

class NumerofoniaFullscreenScreen extends StatefulWidget {
  final List<EstrofaNumerofonia> estrofas;
  const NumerofoniaFullscreenScreen({
    super.key,
    required this.estrofas,
  });

  @override
  State<NumerofoniaFullscreenScreen> createState() =>
      _NumerofoniaFullscreenScreenState();
}

class _NumerofoniaFullscreenScreenState
    extends State<NumerofoniaFullscreenScreen> {
  final _transformController = TransformationController();
  bool _zoomActivo = false;
  bool _bloquearRotacion = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
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

  void _resetZoom() {
    _transformController.value = Matrix4.identity();
  }

  void _toggleRotacion() {
    setState(() => _bloquearRotacion = !_bloquearRotacion);
    if (_bloquearRotacion) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.negro,
      body: Stack(
        children: [
          // Visor con zoom
          Positioned.fill(
            child: InteractiveViewer(
              transformationController: _transformController,
              minScale: 0.5,
              maxScale: 5.0,
              boundaryMargin: const EdgeInsets.all(80),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: VisorNumerofonia(
                    estrofas: widget.estrofas,
                    escala: 1.3,
                    mostrarBotonExpandir: false,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
                      tooltip: 'Cerrar',
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'NUMEROFONÍA',
                      style: TextStyle(
                        color: AppColors.dorado,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const Spacer(),
                    // Zoom reset
                    if (_zoomActivo)
                      IconButton(
                        icon: const Icon(Icons.center_focus_strong,
                            color: AppColors.dorado),
                        tooltip: 'Centrar',
                        onPressed: _resetZoom,
                      ),
                    // Bloquear rotación
                    IconButton(
                      icon: Icon(
                        _bloquearRotacion
                            ? Icons.screen_lock_rotation
                            : Icons.screen_rotation,
                        color: AppColors.dorado,
                      ),
                      tooltip: _bloquearRotacion
                          ? 'Permitir rotación'
                          : 'Bloquear rotación',
                      onPressed: _toggleRotacion,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Hint de zoom
          if (!_zoomActivo)
            Positioned(
              bottom: 16,
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
                    'Pellizcá para zoom • Doble tap para acercar',
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