import 'package:flutter/material.dart';

class NumerofoniaWidget extends StatelessWidget {
  final String numerofonia;
  const NumerofoniaWidget({super.key, required this.numerofonia});

  static const _colores = {
    '1': Color(0xFFE53935),
    '2': Color(0xFFFB8C00),
    '3': Color(0xFFFDD835),
    '4': Color(0xFF43A047),
    '5': Color(0xFF1E88E5),
    '6': Color(0xFF8E24AA),
    '7': Color(0xFF6D4C41),
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
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Cada número = una nota.',
              style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tokens.map((t) {
              if (t == '|') {
                return Container(width: 2, height: 60, color: Colors.grey[400]);
              }
              if (t == '-' || t.isEmpty) {
                return Container(
                  width: 40,
                  height: 60,
                  alignment: Alignment.center,
                  child: const Text('—',
                      style: TextStyle(fontSize: 24, color: Colors.grey)),
                );
              }
              final color = _colores[t.substring(0, 1)] ?? Colors.grey;
              return Container(
                width: 48,
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  t,
                  style: const TextStyle(
                    color: Colors.white,
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
