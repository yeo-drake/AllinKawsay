import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../theme/colors.dart';

class EstadisticasAdminScreen extends StatefulWidget {
  const EstadisticasAdminScreen({super.key});

  @override
  State<EstadisticasAdminScreen> createState() =>
      _EstadisticasAdminScreenState();
}

class _Stats {
  final int totalCanciones;
  final int totalUsuarios;
  final int totalReproducciones;
  final int totalEventos;
  final int totalRecuerdos;
  final List<MapEntry<String, int>> topCanciones;
  final List<MapEntry<String, int>> ritmos;
  final Map<String, int> usuariosPorRol;

  _Stats({
    required this.totalCanciones,
    required this.totalUsuarios,
    required this.totalReproducciones,
    required this.totalEventos,
    required this.totalRecuerdos,
    required this.topCanciones,
    required this.ritmos,
    required this.usuariosPorRol,
  });
}

class _EstadisticasAdminScreenState extends State<EstadisticasAdminScreen> {
  late Future<_Stats> _future;

  @override
  void initState() {
    super.initState();
    _future = _cargar();
  }

  Future<_Stats> _cargar() async {
    final db = FirebaseFirestore.instance;

    final cancionesSnap = await db.collection('canciones').get();
    final usuariosSnap = await db.collection('usuarios').get();
    final eventosSnap = await db.collection('eventos').get();
    final recuerdosSnap = await db.collection('recuerdos').get();

    int totalReproducciones = 0;
    final Map<String, int> cancionesPorTitulo = {};
    final Map<String, int> ritmos = {};
    final Map<String, int> usuariosPorRol = {};

    for (final doc in cancionesSnap.docs) {
      final d = doc.data();
      final rep = d['reproducciones'];
      final r = (rep is int) ? rep : 0;
      totalReproducciones += r;

      final titulo = (d['titulo'] ?? 'Sin título').toString();
      cancionesPorTitulo[titulo] = r;

      final ritmo = (d['ritmo'] ?? '').toString().trim();
      final key = ritmo.isEmpty ? 'Sin ritmo' : ritmo;
      ritmos[key] = (ritmos[key] ?? 0) + 1;
    }

    for (final doc in usuariosSnap.docs) {
      final rol = (doc.data()['rol'] ?? 'publico').toString();
      usuariosPorRol[rol] = (usuariosPorRol[rol] ?? 0) + 1;
    }

    final topCancionesList = cancionesPorTitulo.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final ritmosList = ritmos.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return _Stats(
      totalCanciones: cancionesSnap.docs.length,
      totalUsuarios: usuariosSnap.docs.length,
      totalReproducciones: totalReproducciones,
      totalEventos: eventosSnap.docs.length,
      totalRecuerdos: recuerdosSnap.docs.length,
      topCanciones: topCancionesList.take(5).toList(),
      ritmos: ritmosList,
      usuariosPorRol: usuariosPorRol,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ESTADÍSTICAS DEL GRUPO')),
      body: FutureBuilder<_Stats>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                    CircularProgressIndicator(color: AppColors.granate));
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Error: ${snap.error}',
                    textAlign: TextAlign.center),
              ),
            );
          }
          final s = snap.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // === TARJETAS PRINCIPALES ===
              Row(
                children: [
                  Expanded(
                      child: _card(
                          Icons.library_music,
                          '${s.totalCanciones}',
                          'Canciones')),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _card(
                          Icons.people, '${s.totalUsuarios}', 'Usuarios')),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: _card(
                          Icons.play_arrow,
                          '${s.totalReproducciones}',
                          'Reproducciones')),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _card(Icons.event, '${s.totalEventos}',
                          'Eventos')),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: _card(Icons.photo_library,
                          '${s.totalRecuerdos}', 'Recuerdos')),
                  const SizedBox(width: 10),
                  const Expanded(child: SizedBox()),
                ],
              ),

              const SizedBox(height: 24),

              // === USUARIOS POR ROL ===
              _titulo('Usuarios por rol'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: s.usuariosPorRol.entries.map((e) {
                      return _filaTexto(
                        _rolLabel(e.key),
                        '${e.value}',
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // === TOP CANCIONES ===
              _titulo('Top 5 canciones más reproducidas'),
              if (s.topCanciones.isEmpty ||
                  s.topCanciones.every((e) => e.value == 0))
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Aún no hay reproducciones',
                        style: TextStyle(
                            color: AppColors.negro.withOpacity(0.5))),
                  ),
                )
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: List.generate(s.topCanciones.length, (i) {
                        final entry = s.topCanciones[i];
                        return _filaTexto(
                          '${i + 1}. ${entry.key}',
                          '${entry.value}',
                        );
                      }),
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // === CANCIONES POR RITMO ===
              _titulo('Canciones por ritmo'),
              if (s.ritmos.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Sin datos',
                        style: TextStyle(
                            color: AppColors.negro.withOpacity(0.5))),
                  ),
                )
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: s.ritmos.map((e) {
                        return _filaTexto(e.key, '${e.value}');
                      }).toList(),
                    ),
                  ),
                ),

              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  String _rolLabel(String rol) {
    switch (rol) {
      case 'admin':
        return 'Administradores';
      case 'miembro':
        return 'Miembros oficiales';
      case 'publico':
        return 'Público';
      default:
        return rol;
    }
  }

  Widget _titulo(String t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        t,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.granate,
        ),
      ),
    );
  }

  Widget _filaTexto(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.negro),
            ),
          ),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.granate,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(IconData icono, String valor, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.dorado.withOpacity(0.5), width: 1),
      ),
      child: Column(
        children: [
          Icon(icono, color: AppColors.granate, size: 26),
          const SizedBox(height: 8),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.granate,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.negro.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}