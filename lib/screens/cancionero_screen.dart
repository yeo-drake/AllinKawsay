import 'package:flutter/material.dart';
import '../data/datos_ejemplo.dart';
import 'cancion_detalle_screen.dart';

class CancioneroScreen extends StatelessWidget {
  const CancioneroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cancionero'),
        backgroundColor: const Color(0xFF8B4513),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: cancionesEjemplo.length,
        itemBuilder: (context, i) {
          final c = cancionesEjemplo[i];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFD2691E),
              child: Text('${i + 1}',
                  style: const TextStyle(color: Colors.white)),
            ),
            title: Text(c.titulo,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${c.ritmo} · ${c.region}'),
            trailing: const Icon(Icons.chevron_right),
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
