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
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          focusNode: _focus,
          onChanged: _onChanged,
          style: const TextStyle(color: AppColors.dorado, fontSize: 16),
          cursorColor: AppColors.dorado,
          decoration: InputDecoration(
            hintText: 'Buscar en canciones, eventos, recuerdos...',
            hintStyle:
                TextStyle(color: AppColors.dorado.withOpacity(0.5)),
            border: InputBorder.none,
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear,
                        color: AppColors.dorado),
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
              child: CircularProgressIndicator(color: AppColors.granate))
          : WatermarkOverlay(child: _resultados()),
    );
  }

  Widget _resultados() {
    if (_query.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search,
                  size: 80,
                  color: AppColors.granate.withOpacity(0.3)),
              const SizedBox(height: 16),
              Text(
                'Escribe algo para buscar',
                style:
                    TextStyle(color: AppColors.negro.withOpacity(0.5)),
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
              Icon(Icons.search_off,
                  size: 80,
                  color: AppColors.granate.withOpacity(0.3)),
              const SizedBox(height: 16),
              Text(
                'Sin resultados para "$_query"',
                style:
                    TextStyle(color: AppColors.negro.withOpacity(0.5)),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      children: [
        if (canciones.isNotEmpty) ...[
          _titulo('Canciones (${canciones.length})'),
          ...canciones.map(_itemCancion),
        ],
        if (eventos.isNotEmpty) ...[
          _titulo('Eventos (${eventos.length})'),
          ...eventos.map(_itemEvento),
        ],
        if (recuerdos.isNotEmpty) ...[
          _titulo('Recuerdos (${recuerdos.length})'),
          ...recuerdos.map(_itemRecuerdo),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _titulo(String t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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

  Widget _itemCancion(Cancion c) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: AppColors.granate,
        child: Icon(Icons.library_music,
            color: AppColors.dorado, size: 20),
      ),
      title: Text(c.titulo,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: AppColors.negro)),
      subtitle: Text(
          '${c.ritmo}${c.autor.isNotEmpty ? ' · ${c.autor}' : ''}'),
      trailing:
          const Icon(Icons.chevron_right, color: AppColors.dorado),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => CancionDetalleScreen(cancion: c)),
      ),
    );
  }

  Widget _itemEvento(Evento e) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: AppColors.granate,
        child: Icon(Icons.event, color: AppColors.dorado, size: 20),
      ),
      title: Text(e.titulo,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: AppColors.negro)),
      subtitle: Text(
          '${e.fecha.day}/${e.fecha.month}/${e.fecha.year} · ${e.lugar}'),
    );
  }

  Widget _itemRecuerdo(Recuerdo r) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: AppColors.granate,
        child:
            Icon(Icons.photo_library, color: AppColors.dorado, size: 20),
      ),
      title: Text(r.titulo,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: AppColors.negro)),
      subtitle: Text('${r.fotos.length} foto(s)'),
    );
  }
}