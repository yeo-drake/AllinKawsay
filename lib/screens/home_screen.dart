import 'package:flutter/material.dart';
import 'cancionero_screen.dart';
import 'eventos_screen.dart';
import 'recuerdos_screen.dart';
import 'historia_screen.dart';
import 'perfil_screen.dart';

class HomeScreen extends StatefulWidget {
  final String nombreUsuario;
  const HomeScreen({super.key, required this.nombreUsuario});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const CancioneroScreen(),
      const EventosScreen(),
      const RecuerdosScreen(),
      const HistoriaScreen(),
      PerfilScreen(nombreUsuario: widget.nombreUsuario),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.library_music), label: 'Cancionero'),
          NavigationDestination(icon: Icon(Icons.event), label: 'Eventos'),
          NavigationDestination(
              icon: Icon(Icons.photo_library), label: 'Recuerdos'),
          NavigationDestination(
              icon: Icon(Icons.history_edu), label: 'Historia'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
