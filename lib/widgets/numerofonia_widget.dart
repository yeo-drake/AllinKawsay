import 'package:flutter/material.dart';
import '../theme/colors.dart';

class NumerofoniaWidget extends StatelessWidget {
  final String numerofonia;
  const NumerofoniaWidget({super.key, required this.numerofonia});

  // 6 colores derivados de la paleta oficial
  static const _colores = {
    '1': AppColors.granate,
    '2': AppColors.granateOscuro,
    '3': AppColors.dorado,
    '4': AppColors.doradoClaro,
    '5': AppColors.negro,
    '6': Color(0xFF8B0000),
    '7': Color(0xFFA67C00),
  };

  @override
  Widget build(BuildContext context) {
    final tokens = numerofonia.split(RegExp(r'\s+'));
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Numerofonía',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.granate)),
          const SizedBox(height: 4),
          Text('Cada número = una nota. Este es un método para leer '
              'sin necesidad de partitura.',
              style: TextStyle(color: AppColors.negro.withOpacity(0.6))),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tokens.map((t) {
              if (t == '|') {
                return Container(
                  width: 2,
                  height: 60,
                  color: AppColors.dorado,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                );
              }
              if (t == '-' || t.isEmpty) {
                return Container(
                  width: 40,
                  height: 60,
                  alignment: Alignment.center,
                  child: const Text('—',
                      style:
                          TextStyle(fontSize: 24, color: AppColors.negro)),
                );
              }
              final color = _colores[t.substring(0, 1)] ?? AppColors.negro;
              final textoBlanco = color != AppColors.dorado &&
                  color != AppColors.doradoClaro;
              return Container(
                width: 48,
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.dorado.withOpacity(0.5), width: 1),
                ),
                child: Text(
                  t,
                  style: TextStyle(
                    color: textoBlanco ? AppColors.dorado : AppColors.negro,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
