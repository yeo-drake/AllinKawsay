import 'package:flutter/material.dart';
import '../data/datos_ejemplo.dart';
import '../theme/colors.dart';
import 'cancion_detalle_screen.dart';

class CancioneroScreen extends StatelessWidget {
  const CancioneroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CANCIONERO')),
      body: ListView.builder(
        itemCount: cancionesEjemplo.length,
        itemBuilder: (context, i) {
          final c = cancionesEjemplo[i];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.granate,
              child: Text('${i + 1}',
                  style: const TextStyle(color: AppColors.dorado)),
            ),
            title: Text(c.titulo,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.negro)),
            subtitle: Text('${c.ritmo} · ${c.region}'),
            trailing: const Icon(Icons.chevron_right,
                color: AppColors.dorado),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => CancionDetalleScreen(cancion: c)),
            ),
          );
        },
      ),
    );
  }
}