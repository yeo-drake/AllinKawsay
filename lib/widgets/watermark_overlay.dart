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
    // SizedBox.expand obliga al Stack a ocupar TODO el espacio disponible.
    // Sin esto, cuando el child es un ListView, el Stack se expande
    // infinitamente y aparece el "espacio en blanco gigante".
    return SizedBox.expand(
      child: Stack(
        children: [
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
                    errorBuilder: (_, __, ___) =>
                        const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}