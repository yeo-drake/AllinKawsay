import 'package:flutter/material.dart';
import '../theme/colors.dart';

class WatermarkOverlay extends StatelessWidget {
  final Widget child;
  final double opacity;
  final double size;
  const WatermarkOverlay({
    super.key,
    required this.child,
    this.opacity = 0.08,
    this.size = 280,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        IgnorePointer(
          child: Center(
            child: Opacity(
              opacity: opacity,
              child: ColorFiltered(
                // Convierte el logo a silueta dorada (las zonas blancas
                // se vuelven transparentes, las oscuras toman el color).
                colorFilter: ColorFilter.mode(
                  AppColors.dorado,
                  BlendMode.srcIn,
                ),
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