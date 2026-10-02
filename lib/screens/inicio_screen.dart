import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/cancion.dart';
import '../models/evento.dart';
import '../models/recuerdo.dart';
import '../services/cancion_service.dart';
import '../services/evento_service.dart';
import '../services/recuerdo_service.dart';
import '../theme/colors.dart';
import '../widgets/social_buttons.dart';
import '../widgets/watermark_overlay.dart';
import 'busqueda_global_screen.dart';
import 'cancion_detalle_screen.dart';
import 'historia_screen.dart';

class InicioScreen extends StatelessWidget {
  final String nombreUsuario;
  const InicioScreen({super.key, required this.nombreUsuario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blanco,
      body: SafeArea(
        child: WatermarkOverlay(
          opacity: 0.05,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // === HEADER CON BÚSQUEDA ===
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.negro, AppColors.granate],
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.negro.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/logo.png',
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: AppColors.granate,
                                child: const Icon(Icons.music_note,
                                    color: AppColors.dorado, size: 50),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'ALLIN KAWSAY',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.dorado,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Hola, $nombreUsuario',
                          style: TextStyle(
                            color: AppColors.dorado.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.search,
                          color: AppColors.dorado, size: 28),
                      tooltip: 'Buscar',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BusquedaGlobalScreen(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _titulo('Próximo evento'),
              _proximoEvento(context),

              const SizedBox(height: 20),

              _titulo('Últimas canciones'),
              _ultimasCanciones(context),

              const SizedBox(height: 20),

              _titulo('Último recuerdo'),
              _ultimoRecuerdo(context),

              const SizedBox(height: 20),

              _titulo('Nuestra historia'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.granate,
                      child: Icon(Icons.history_edu,
                          color: AppColors.dorado),
                    ),
                    title: const Text('Conoce nuestra historia',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.negro)),
                    subtitle:
                        const Text('Cómo empezó el grupo y sus logros'),
                    trailing: const Icon(Icons.chevron_right,
                        color: AppColors.dorado),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const HistoriaScreen()),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Divider(),
              const SocialButtons(),
              const Divider(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

Widget _titulo(String texto) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
    child: Text(
      texto,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.granate,
      ),
    ),
  );
}

Widget _proximoEvento(BuildContext context) {
  return StreamBuilder<List<Evento>>(
    stream: EventoService().listar(),
    builder: (context, snap) {
      if (snap.connectionState == ConnectionState.waiting) {
        return const Padding(
          padding: EdgeInsets.all(24),
          child: Center(
              child: CircularProgressIndicator(
                  color: AppColors.granate)),
        );
      }
      final eventos = snap.data ?? [];
      final futuros = eventos
          .where((e) => e.fecha.isAfter(DateTime.now()))
          .toList();
      if (futuros.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.event_busy,
                      color: AppColors.granate.withOpacity(0.4),
                      size: 40),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Sin eventos próximos',
                      style: TextStyle(
                          color: AppColors.negro.withOpacity(0.5)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      final proximo = futuros.first;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.granate,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${proximo.fecha.day}',
                        style: const TextStyle(
                            color: AppColors.dorado,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _mes(proximo.fecha.month),
                        style: const TextStyle(
                            color: AppColors.dorado, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(proximo.titulo,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.negro)),
                      const SizedBox(height: 4),
                      Text(
                        '${_hora(proximo.fecha)}${proximo.lugar.isNotEmpty ? ' · ${proximo.lugar}' : ''}',
                        style: TextStyle(
                            color: AppColors.negro.withOpacity(0.6),
                            fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

  Widget _ultimasCanciones(BuildContext context) {
    return StreamBuilder<List<Cancion>>(
      stream: CancionService().listar(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
                child: CircularProgressIndicator(
                    color: AppColors.granate)),
          );
        }
        final lista = snap.data ?? [];
        if (lista.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.library_music,
                        color: AppColors.granate.withOpacity(0.4),
                        size: 40),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Sin canciones aún',
                        style: TextStyle(
                            color: AppColors.negro.withOpacity(0.5)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        final top3 = lista.take(3).toList();
        return Column(
          children: top3
              .map((c) => Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    child: Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.granate,
                          child: const Icon(Icons.music_note,
                              color: AppColors.dorado, size: 20),
                        ),
                        title: Text(c.titulo,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.negro)),
                        subtitle: Text(
                            '${c.ritmo}${c.autor.isNotEmpty ? ' · ${c.autor}' : ''}'),
                        trailing: const Icon(Icons.chevron_right,
                            color: AppColors.dorado),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  CancionDetalleScreen(cancion: c)),
                        ),
                      ),
                    ),
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _ultimoRecuerdo(BuildContext context) {
    return StreamBuilder<List<Recuerdo>>(
      stream: RecuerdoService().listar(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
                child: CircularProgressIndicator(
                    color: AppColors.granate)),
          );
        }
        final lista = snap.data ?? [];
        if (lista.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.photo_library,
                        color: AppColors.granate.withOpacity(0.4),
                        size: 40),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Sin recuerdos aún',
                        style: TextStyle(
                            color: AppColors.negro.withOpacity(0.5)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        final r = lista.first;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (r.fotos.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: r.fotos.first,
                    memCacheWidth: 800,
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      height: 160,
                      color: AppColors.grisClaro,
                      child: const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.granate),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      height: 160,
                      color: AppColors.grisClaro,
                      child: const Icon(Icons.broken_image,
                          color: AppColors.granate, size: 40),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(r.titulo,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.negro)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _mes(int m) {
    const meses = [
      '', 'ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN',
      'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC'
    ];
    return meses[m];
  }

  String _hora(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}