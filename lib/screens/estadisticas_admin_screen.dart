import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/watermark_overlay.dart';

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
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(title: const Text('ESTADÍSTICAS DEL GRUPO')),
      body: WatermarkOverlay(
        opacity: 0.04,
        child: FutureBuilder<_Stats>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.granate));
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
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                // === TARJETAS PRINCIPALES ===
                _seccion(onSurface, Icons.insights, 'RESUMEN'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                        child: _statCard(
                            Icons.library_music,
                            '${s.totalCanciones}',
                            'Canciones',
                            onSurface)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _statCard(Icons.people,
                            '${s.totalUsuarios}', 'Usuarios', onSurface)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                        child: _statCard(
                            Icons.play_arrow,
                            '${s.totalReproducciones}',
                            'Reproducciones',
                            onSurface)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _statCard(Icons.event,
                            '${s.totalEventos}', 'Eventos', onSurface)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                        child: _statCard(
                            Icons.photo_library,
                            '${s.totalRecuerdos}',
                            'Recuerdos',
                            onSurface)),
                    const Expanded(child: SizedBox()),
                  ],
                ),

                const SizedBox(height: 24),

                // === USUARIOS POR ROL ===
                _seccion(onSurface, Icons.badge_outlined,
                    'USUARIOS POR ROL'),
                const SizedBox(height: 10),
                _card(
                  context,
                  onSurface,
                  s.usuariosPorRol.entries.map((e) {
                    return _filaTexto(
                        onSurface, _rolLabel(e.key), '${e.value}');
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // === TOP CANCIONES ===
                _seccion(onSurface, Icons.local_fire_department_outlined,
                    'TOP 5 MÁS REPRODUCIDAS'),
                const SizedBox(height: 10),
                if (s.topCanciones.isEmpty ||
                    s.topCanciones.every((e) => e.value == 0))
                  _card(
                    context,
                    onSurface,
                    [
                      Text('Aún no hay reproducciones',
                          style: TextStyle(
                              color: onSurface.withOpacity(0.5),
                              fontStyle: FontStyle.italic,
                              fontSize: 13)),
                    ],
                  )
                else
                  _card(
                    context,
                    onSurface,
                    List.generate(s.topCanciones.length, (i) {
                      final entry = s.topCanciones[i];
                      return _filaTop(onSurface, i, entry.key, entry.value);
                    }),
                  ),

                const SizedBox(height: 20),

                // === CANCIONES POR RITMO ===
                _seccion(onSurface, Icons.graphic_eq,
                    'CANCIONES POR RITMO'),
                const SizedBox(height: 10),
                if (s.ritmos.isEmpty)
                  _card(
                    context,
                    onSurface,
                    [
                      Text('Sin datos',
                          style: TextStyle(
                              color: onSurface.withOpacity(0.5),
                              fontStyle: FontStyle.italic,
                              fontSize: 13)),
                    ],
                  )
                else
                  _card(
                    context,
                    onSurface,
                    s.ritmos.map((e) {
                      return _filaTexto(onSurface, e.key, '${e.value}');
                    }).toList(),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _seccion(Color onSurface, IconData icono, String titulo) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: AppColors.granate.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icono, size: 13, color: AppColors.granate),
          ),
          const SizedBox(width: 10),
          Text(titulo,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.granate,
                  letterSpacing: 2)),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, Color onSurface, List<Widget> hijos) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.dorado.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: hijos,
      ),
    );
  }

  Widget _filaTexto(Color onSurface, String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: 13, color: onSurface.withOpacity(0.85))),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.granate.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(valor,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.granate)),
          ),
        ],
      ),
    );
  }

  Widget _filaTop(
      Color onSurface, int index, String titulo, int valor) {
    final medallas = ['🥇', '🥈', '🥉', '4️⃣', '5️⃣'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.granate.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(medallas[index],
                style: const TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(titulo,
                style: TextStyle(
                    fontSize: 13,
                    color: onSurface.withOpacity(0.85),
                    fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.granate.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('$valor',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.granate)),
          ),
        ],
      ),
    );
  }

  Widget _statCard(
      IconData icono, String valor, String label, Color onSurface) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.granate.withOpacity(0.1),
            AppColors.dorado.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.dorado.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: AppColors.gradienteGranate,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.granate.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child:
                Icon(icono, color: AppColors.dorado, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.granate,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: onSurface.withOpacity(0.55),
              letterSpacing: 0.5,
            ),
          ),
        ],
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
}