import 'package:flutter/material.dart';

class WatermarkOverlay extends StatelessWidget {
  final Widget child;
  final double opacity;
  final double size;
  const WatermarkOverlay({
    super.key,
    required this.child,
    this.opacity = 0.06,
    this.size = 280,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fondo: logo en el centro con opacidad baja
        Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: opacity,
              child: Center(
                child: Image.asset(
                  'assets/logo.png',
                  width: size,
                  height: size,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ),
        // Contenido encima (toma el tamaño del padre)
        child,
      ],
    );
  }
}