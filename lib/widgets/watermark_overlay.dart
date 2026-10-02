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
        // El child va PRIMERO (define el tamaño del Stack)
        child,
        // Logo encima, ocupando todo el Stack
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
      ],
    );
  }
}