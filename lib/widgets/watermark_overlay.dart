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
      // StackFit.expand obliga a TODOS los hijos no-posicionados a
      // ocupar el mismo tamaño que el Stack. Esto evita que el
      // ListView se expanda indefinidamente.
      fit: StackFit.expand,
      children: [
        child,
        IgnorePointer(
          child: Center(
            child: Opacity(
              opacity: opacity,
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
      ],
    );
  }
}