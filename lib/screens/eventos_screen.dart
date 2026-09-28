import 'package:flutter/material.dart';
import '../theme/colors.dart';

class EventosScreen extends StatelessWidget {
  const EventosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PRÓXIMOS EVENTOS')),
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
          backgroundColor: AppColors.granate,
          child: Icon(icono, color: AppColors.dorado),
        ),
        title: Text(titulo,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.negro)),
        subtitle: Text('$fecha · $lugar'),
      ),
    );
  }
}