import 'dart:async';
import 'package:flutter/material.dart';
import '../models/cancion.dart';
import '../models/evento.dart';
import '../models/recuerdo.dart';
import '../services/cancion_service.dart';
import '../services/evento_service.dart';
import '../services/recuerdo_service.dart';
import '../theme/colors.dart';
import '../widgets/watermark_overlay.dart';
import 'cancion_detalle_screen.dart';

class BusquedaGlobalScreen extends StatefulWidget {
  const BusquedaGlobalScreen({super.key});

  @override
  State<BusquedaGlobalScreen> createState() => _BusquedaGlobalScreenState();
}

class _BusquedaGlobalScreenState extends State<BusquedaGlobalScreen> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  String _query = '';
  Timer? _debounce;

  List<Cancion> _canciones = [];
  List<Evento> _eventos = [];
  List<Recuerdo> _recuerdos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focus.requestFocus();
    });
  }

  Future<void> _cargar() async {
    try {
      final canciones = await CancionService().listar().first;
      final eventos = await EventoService().listar().first;
      final recuerdos = await RecuerdoService().listar().first;
      if (mounted) {
        setState(() {
          _canciones = canciones;
          _eventos = eventos;
          _recuerdos = recuerdos;
          _cargando = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _query = v.trim().toLowerCase());
    });
  }

  List<Cancion> get _cancionesFiltradas {
    if (_query.isEmpty) return [];
    return _canciones
        .where((c) =>
            c.titulo.toLowerCase().contains(_query) ||
            c.autor.toLowerCase().contains(_query) ||
            c.ritmo.toLowerCase().contains(_query) ||
            c.letra.toLowerCase().contains(_query) ||
            c.tags.any((t) => t.toLowerCase().contains(_query)))
        .toList();
  }

  List<Evento> get _eventosFiltrados {
    if (_query.isEmpty) return [];
    return _eventos
        .where((e) =>
            e.titulo.toLowerCase().contains(_query) ||
            e.descripcion.toLowerCase().contains(_query) ||
            e.lugar.toLowerCase().contains(_query))
        .toList();
  }

  List<Recuerdo> get _recuerdosFiltrados {
    if (_query.isEmpty) return [];
    return _recuerdos
        .where((r) =>
            r.titulo.toLowerCase().contains(_query) ||
            r.descripcion.toLowerCase().contains(_query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          focusNode: _focus,
          onChanged: _onChanged,
          style: const TextStyle(
              color: AppColors.dorado,
              fontSize: 15,
              letterSpacing: 0.3),
          cursorColor: AppColors.dorado,
          decoration: InputDecoration(
            filled: false,
            hintText: 'Canciones, eventos, recuerdos...',
            hintStyle: TextStyle(
                color: AppColors.dorado.withOpacity(0.45),
                fontSize: 13),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear,
                        color: AppColors.dorado, size: 20),
                    onPressed: () {
                      _ctrl.clear();
                      setState(() => _query = '');
                    },
                  )
                : null,
          ),
        ),
      ),
      body: _cargando
          ? const Center(
              child:
                  CircularProgressIndicator(color: AppColors.granate))
          : WatermarkOverlay(
              opacity: 0.04,
              child: _resultados(onSurface)),
    );
  }

  Widget _resultados(Color onSurface) {
    if (_query.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.granate.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.search,
                    size: 48, color: AppColors.granate.withOpacity(0.4)),
              ),
              const SizedBox(height: 20),
              Text(
                'Escribe algo para buscar',
                style: TextStyle(
                    color: onSurface.withOpacity(0.5),
                    fontSize: 14,
                    letterSpacing: 0.3),
              ),
              const SizedBox(height: 6),
              Text(
                'Busca en canciones, eventos y recuerdos',
                style: TextStyle(
                    color: onSurface.withOpacity(0.35),
                    fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    final canciones = _cancionesFiltradas;
    final eventos = _eventosFiltrados;
    final recuerdos = _recuerdosFiltrados;
    final total = canciones.length + eventos.length + recuerdos.length;

    if (total == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.granate.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.search_off,
                    size: 48, color: AppColors.granate.withOpacity(0.4)),
              ),
              const SizedBox(height: 20),
              Text(
                'Sin resultados para "$_query"',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: onSurface.withOpacity(0.5),
                    fontSize: 14,
                    fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (canciones.isNotEmpty) ...[
          _tituloSeccion('Canciones', canciones.length),
          ...canciones.map((c) => _itemCancion(c, onSurface)),
          const SizedBox(height: 12),
        ],
        if (eventos.isNotEmpty) ...[
          _tituloSeccion('Eventos', eventos.length),
          ...eventos.map((e) => _itemEvento(e, onSurface)),
          const SizedBox(height: 12),
        ],
        if (recuerdos.isNotEmpty) ...[
          _tituloSeccion('Recuerdos', recuerdos.length),
          ...recuerdos.map((r) => _itemRecuerdo(r, onSurface)),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _tituloSeccion(String texto, int cantidad) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.granate,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            texto.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.granate,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.granate.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$cantidad',
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.granate)),
          ),
        ],
      ),
    );
  }

  Widget _itemCancion(Cancion c, Color onSurface) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => CancionDetalleScreen(cancion: c)),
          ),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardColor(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.dorado.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: AppColors.gradienteGranate,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.music_note,
                      color: AppColors.dorado, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.titulo,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: onSurface,
                              fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 3),
                      Text(
                        '${c.ritmo}${c.autor.isNotEmpty ? ' · ${c.autor}' : ''}',
                        style: TextStyle(
                            fontSize: 12,
                            color: onSurface.withOpacity(0.55)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right,
                    color: AppColors.dorado.withOpacity(0.6),
                    size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _itemEvento(Evento e, Color onSurface) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.dorado.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: AppColors.gradienteGranate,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.event,
                  color: AppColors.dorado, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.titulo,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: onSurface,
                          fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(
                    '${e.fecha.day}/${e.fecha.month}/${e.fecha.year} · ${e.lugar}',
                    style: TextStyle(
                        fontSize: 12,
                        color: onSurface.withOpacity(0.55)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemRecuerdo(Recuerdo r, Color onSurface) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.dorado.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: AppColors.gradienteGranate,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.photo_library,
                  color: AppColors.dorado, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.titulo,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: onSurface,
                          fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(
                    '${r.fotos.length} foto(s)',
                    style: TextStyle(
                        fontSize: 12,
                        color: onSurface.withOpacity(0.55)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}