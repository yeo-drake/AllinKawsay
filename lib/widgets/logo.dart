import 'package:flutter/material.dart';
import '../theme/colors.dart';

class SikuriLogo extends StatelessWidget {
  final double size;
  const SikuriLogo({super.key, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.granate,
        border: Border.all(color: AppColors.dorado, width: size * 0.045),
        boxShadow: [
          BoxShadow(
            color: AppColors.negro.withOpacity(0.3),
            blurRadius: size * 0.1,
            offset: Offset(0, size * 0.05),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(size * 0.2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final h in [0.45, 0.65, 0.85, 0.65, 0.85, 0.55])
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: size * 0.012),
                  child: Container(
                    height: size * 0.6 * h,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.doradoClaro, AppColors.dorado],
                      ),
                      borderRadius: BorderRadius.circular(size * 0.04),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
