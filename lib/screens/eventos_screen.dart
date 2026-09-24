import 'package:flutter/material.dart';

class EventosScreen extends StatelessWidget {
  const EventosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Próximos eventos'),
        backgroundColor: const Color(0xFF8B4513),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _evento('Ensayo general', 'Viernes 20:00', 'Local del grupo',
              Icons.music_note),
          _evento('Fiesta patronal', 'Sábado 15:00', 'Plaza principal',
              Icons.celebration),
          _evento('Viaje a festival', 'Próximo mes', 'Por confirmar',
              Icons.directions_bus),
        ],
      ),
    );
  }

  Widget _evento(
      String titulo, String fecha, String lugar, IconData icono) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFD2691E),
          child: Icon(icono, color: Colors.white),
        ),
        title:
            Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$fecha · $lugar'),
      ),
    );
  }
}
