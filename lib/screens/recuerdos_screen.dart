import 'package:flutter/material.dart';
import '../theme/colors.dart';

class RecuerdosScreen extends StatelessWidget {
  const RecuerdosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RECUERDOS')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(8),
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        children: List.generate(6, (i) {
          return Container(
            decoration: BoxDecoration(
              color: Color.lerp(
                  AppColors.granate, AppColors.dorado, i / 6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.photo,
                      color: AppColors.blanco, size: 40),
                  const SizedBox(height: 8),
                  Text('Viaje ${i + 1}',
                      style: const TextStyle(color: AppColors.blanco)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}