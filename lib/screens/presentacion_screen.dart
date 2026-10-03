import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/cancion.dart';
import '../theme/colors.dart';
import '../widgets/visor_numerofonia.dart';

class PresentacionScreen extends StatefulWidget {
  final Cancion cancion;
  const PresentacionScreen({super.key, required this.cancion});

  @override
  State<PresentacionScreen> createState() => _PresentacionScreenState();
}

class _PresentacionScreenState extends State<PresentacionScreen> {
  final _transformController = TransformationController();
  bool _zoomActivo = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
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

  @override
  Widget build(BuildContext context) {
    final c = widget.cancion;
    return Scaffold(
      backgroundColor: AppColors.negro,
      body: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              transformationController: _transformController,
              minScale: 0.8,
              maxScale: 4.0,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 80, 20, 40),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      c.titulo.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.dorado,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        letterSpacing: 3,
                        height: 1.2,
                      ),
                    ),
                    if (c.autor.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        c.autor,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.dorado.withOpacity(0.7),
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),

                    // Numerofonía
                    if (c.tieneNumerofonia)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.blanco,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: VisorNumerofonia(
                            estrofas: c.estrofas,
                            escala: 1.3,
                          ),
                        ),
                      )
                    else if (c.tieneNumerofoniaString)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.negro,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.dorado, width: 1.5),
                        ),
                        child: Text(
                          c.numerofonia,
                          style: const TextStyle(
                            color: AppColors.dorado,
                            fontSize: 20,
                            height: 1.6,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),

                    // Letra
                    if (c.letra.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      const Text(
                        '— LETRA —',
                        style: TextStyle(
                          color: AppColors.dorado,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.negro,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: AppColors.dorado
                                  .withOpacity(0.35)),
                        ),
                        child: Text(
                          c.letra,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.doradoClaro,
                            fontSize: 18,
                            height: 1.9,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                  ],
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
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.75),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: AppColors.dorado),
                      tooltip: 'Salir',
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'MODO PRESENTACIÓN',
                      style: TextStyle(
                        color: AppColors.dorado,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const Spacer(),
                    if (_zoomActivo)
                      IconButton(
                        icon: const Icon(Icons.center_focus_strong,
                            color: AppColors.dorado),
                        tooltip: 'Centrar',
                        onPressed: _resetZoom,
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Hint
          if (!_zoomActivo)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.dorado.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.touch_app,
                          size: 14,
                          color: AppColors.dorado.withOpacity(0.7)),
                      const SizedBox(width: 6),
                      Text(
                        'Pellizcá para zoom • Girá el celu',
                        style: TextStyle(
                            color: AppColors.dorado.withOpacity(0.9),
                            fontSize: 11,
                            letterSpacing: 0.3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}