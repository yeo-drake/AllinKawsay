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
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: WatermarkOverlay(
          opacity: 0.04,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // === HEADER HERO ===
              _header(context),
              const SizedBox(height: 24),

              // === PRÓXIMO EVENTO ===
              _seccionTitulo(context, 'Próximo evento',
                  Icons.event_available),
              _proximoEvento(context),
              const SizedBox(height: 24),

              // === ÚLTIMAS CANCIONES ===
              _seccionTitulo(context, 'Últimas canciones',
                  Icons.library_music),
              _ultimasCanciones(context),
              const SizedBox(height: 24),

              // === ÚLTIMO RECUERDO ===
              _seccionTitulo(context, 'Último recuerdo',
                  Icons.photo_library),
              _ultimoRecuerdo(context),
              const SizedBox(height: 24),

              // === HISTORIA ===
              _seccionTitulo(context, 'Nuestra historia',
                  Icons.history_edu),
              _tarjetaHistoria(context, onSurface),
              const SizedBox(height: 24),

              // === REDES ===
              const Divider(),
              const SizedBox(height: 8),
              const SocialButtons(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0A0A0A),
                AppColors.granateOscuro,
                AppColors.granate,
              ],
              stops: [0.0, 0.6, 1.0],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Logo con halo
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.dorado.withOpacity(0.3),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/logo.png',
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.granate,
                      child: const Icon(Icons.music_note,
                          color: AppColors.dorado, size: 45),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              // Nombre grupo
              const Text(
                'ALLIN KAWSAY',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.dorado,
                  letterSpacing: 5,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Hola, $nombreUsuario',
                  style: TextStyle(
                    color: AppColors.dorado.withOpacity(0.9),
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Botón búsqueda
        Positioned(
          top: 8,
          right: 8,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const BusquedaGlobalScreen()),
              ),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.dorado.withOpacity(0.3)),
                ),
                child: const Icon(Icons.search,
                    color: AppColors.dorado, size: 22),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _seccionTitulo(
      BuildContext context, String texto, IconData icono) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.granate.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icono, color: AppColors.granate, size: 16),
          ),
          const SizedBox(width: 10),
          Text(
            texto,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.granate,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _proximoEvento(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
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
          return _emptyCard(context, Icons.event_busy,
              'Sin eventos próximos', onSurface);
        }
        final proximo = futuros.first;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.granate,
                  AppColors.granateOscuro,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.granate.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                // Fecha
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.dorado.withOpacity(0.4)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${proximo.fecha.day}',
                        style: const TextStyle(
                            color: AppColors.dorado,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            height: 1),
                      ),
                      Text(
                        _mes(proximo.fecha.month),
                        style: TextStyle(
                            color: AppColors.dorado.withOpacity(0.9),
                            fontSize: 10,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold),
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
                              fontSize: 17,
                              color: AppColors.dorado)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.access_time,
                              size: 12,
                              color:
                                  AppColors.dorado.withOpacity(0.8)),
                          const SizedBox(width: 4),
                          Text(_hora(proximo.fecha),
                              style: TextStyle(
                                  color:
                                      AppColors.dorado.withOpacity(0.9),
                                  fontSize: 12)),
                          if (proximo.lugar.isNotEmpty) ...[
                            const SizedBox(width: 12),
                            Icon(Icons.place,
                                size: 12,
                                color:
                                    AppColors.dorado.withOpacity(0.8)),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(proximo.lugar,
                                  style: TextStyle(
                                      color: AppColors.dorado
                                          .withOpacity(0.9),
                                      fontSize: 12),
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _ultimasCanciones(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
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
          return _emptyCard(context, Icons.library_music,
              'Sin canciones aún', onSurface);
        }
        final top3 = lista.take(3).toList();
        return Column(
          children: top3
              .map((c) => Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  CancionDetalleScreen(cancion: c)),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.cardColor(context),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AppColors.dorado
                                    .withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  gradient: AppColors.gradienteGranate,
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.music_note,
                                    color: AppColors.dorado, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(c.titulo,
                                        style: TextStyle(
                                            fontWeight:
                                                FontWeight.bold,
                                            color: onSurface,
                                            fontSize: 15)),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${c.ritmo}${c.autor.isNotEmpty ? ' · ${c.autor}' : ''}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: onSurface
                                              .withOpacity(0.55)),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right,
                                  color: AppColors.dorado
                                      .withOpacity(0.7),
                                  size: 22),
                            ],
                          ),
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
    final onSurface = Theme.of(context).colorScheme.onSurface;
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
          return _emptyCard(context, Icons.photo_library,
              'Sin recuerdos aún', onSurface);
        }
        final r = lista.first;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: AppColors.dorado.withOpacity(0.25)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (r.fotos.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: r.fotos.first,
                    memCacheWidth: 800,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      height: 180,
                      color: AppColors.grisClaro,
                      child: const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.granate),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      height: 180,
                      color: AppColors.grisClaro,
                      child: const Icon(Icons.broken_image,
                          color: AppColors.granate, size: 40),
                    ),
                  ),
                Container(
                  color: AppColors.cardColor(context),
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(r.titulo,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: onSurface)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.granate.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${r.fotos.length} 📸',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.granate),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _tarjetaHistoria(BuildContext context, Color onSurface) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HistoriaScreen()),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.dorado.withOpacity(0.15),
                  AppColors.granate.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: AppColors.dorado.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppColors.gradienteDorado,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.dorado.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.auto_stories,
                      color: AppColors.granate, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Conoce nuestra historia',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: onSurface,
                              fontSize: 15)),
                      const SizedBox(height: 2),
                      Text('Cómo empezó el grupo y sus logros',
                          style: TextStyle(
                              fontSize: 12,
                              color: onSurface.withOpacity(0.55))),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    color: AppColors.granate, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyCard(BuildContext context, IconData icono,
      String texto, Color onSurface) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardColor(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.dorado.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.granate.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icono,
                  color: AppColors.granate.withOpacity(0.4), size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                texto,
                style: TextStyle(
                    color: onSurface.withOpacity(0.5),
                    fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
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