import 'package:flutter/material.dart';
import '../models/cancion.dart';
import '../services/cancion_service.dart';
import '../services/usuario_service.dart';
import '../theme/colors.dart';
import '../widgets/watermark_overlay.dart';
import 'agregar_cancion_screen.dart';
import 'cancion_detalle_screen.dart';

enum _OrdenCancion { fecha, titulo, autor, reproducciones }

class CancioneroScreen extends StatefulWidget {
  const CancioneroScreen({super.key});

  @override
  State<CancioneroScreen> createState() => _CancioneroScreenState();
}

class _CancioneroScreenState extends State<CancioneroScreen> {
  final _service = CancionService();
  final _searchCtrl = TextEditingController();
  bool _esAdmin = false;
  String _query = '';
  String? _tagFiltro;
  _OrdenCancion _orden = _OrdenCancion.fecha;
  bool _ascendente = false;

  @override
  void initState() {
    super.initState();
    _chequearAdmin();
  }

  Future<void> _chequearAdmin() async {
    final a = await UsuarioService().soyAdmin();
    if (mounted) setState(() => _esAdmin = a);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _eliminar(Cancion c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar canción'),
        content: Text('¿Eliminar "${c.titulo}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok == true) await _service.eliminar(c.id);
  }

  void _editar(Cancion c) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AgregarCancionScreen(cancion: c),
      ),
    );
  }

  void _abrirMenuOrden() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.dorado,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Ordenar por',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _itemOrden('Fecha de subida', _OrdenCancion.fecha),
            _itemOrden('Título (A-Z)', _OrdenCancion.titulo),
            _itemOrden('Autor (A-Z)', _OrdenCancion.autor),
            _itemOrden(
                'Más reproducidas', _OrdenCancion.reproducciones),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _itemOrden(String label, _OrdenCancion valor) {
    final selected = _orden == valor;
    return ListTile(
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: AppColors.granate,
      ),
      title: Text(label),
      trailing: selected
          ? IconButton(
              icon: Icon(
                _ascendente
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                color: AppColors.granate,
              ),
              onPressed: () {
                setState(() => _ascendente = !_ascendente);
                Navigator.pop(context);
              },
            )
          : null,
      onTap: () {
        setState(() {
          _orden = valor;
          // Defaults razonables
          if (valor == _OrdenCancion.fecha ||
              valor == _OrdenCancion.reproducciones) {
            _ascendente = false;
          } else {
            _ascendente = true;
          }
        });
        Navigator.pop(context);
      },
    );
  }

  List<Cancion> _filtrar(List<Cancion> lista) {
    var r = lista;
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      r = r.where((c) =>
          c.titulo.toLowerCase().contains(q) ||
          c.autor.toLowerCase().contains(q) ||
          c.ritmo.toLowerCase().contains(q) ||
          c.tags.any((t) => t.toLowerCase().contains(q))).toList();
    }
    if (_tagFiltro != null) {
      r = r.where((c) => c.tags.contains(_tagFiltro)).toList();
    }
    r.sort((a, b) {
      int cmp;
      switch (_orden) {
        case _OrdenCancion.titulo:
          cmp = a.titulo.toLowerCase().compareTo(b.titulo.toLowerCase());
          break;
        case _OrdenCancion.autor:
          cmp = a.autor.toLowerCase().compareTo(b.autor.toLowerCase());
          break;
        case _OrdenCancion.reproducciones:
          cmp = a.reproducciones.compareTo(b.reproducciones);
          break;
        case _OrdenCancion.fecha:
        default:
          final fa = a.fechaCreacion ?? DateTime(2000);
          final fb = b.fechaCreacion ?? DateTime(2000);
          cmp = fa.compareTo(fb);
          break;
      }
      return _ascendente ? cmp : -cmp;
    });
    return r;
  }

  List<String> _todosLosTags(List<Cancion> lista) {
    final set = <String>{};
    for (final c in lista) {
      set.addAll(c.tags);
    }
    final l = set.toList()..sort();
    return l;
  }

  String _nombreOrden() {
    switch (_orden) {
      case _OrdenCancion.titulo:
        return 'Título';
      case _OrdenCancion.autor:
        return 'Autor';
      case _OrdenCancion.reproducciones:
        return 'Reproducciones';
      case _OrdenCancion.fecha:
      default:
        return 'Fecha';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CANCIONERO'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            tooltip: 'Ordenar',
            onPressed: _abrirMenuOrden,
          ),
        ],
      ),
      floatingActionButton: _esAdmin
          ? FloatingActionButton(
              backgroundColor: AppColors.granate,
              foregroundColor: AppColors.dorado,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AgregarCancionScreen()),
              ),
              child: const Icon(Icons.add),
            )
          : null,
      body: WatermarkOverlay(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Buscar por título, autor, ritmo...',
                  prefixIcon: const Icon(Icons.search,
                      color: AppColors.granate),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Row(
                children: [
                  Icon(Icons.sort, size: 14,
                      color: AppColors.negro.withOpacity(0.6)),
                  const SizedBox(width: 4),
                  Text(
                    'Ordenado por ${_nombreOrden()} ${_ascendente ? '↑' : '↓'}',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.negro.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Cancion>>(
                stream: _service.listar(),
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
                  final lista = snap.data ?? [];
                  if (lista.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.library_music,
                                size: 80,
                                color:
                                    AppColors.granate.withOpacity(0.3)),
                            const SizedBox(height: 16),
                            const Text('Aún no hay canciones',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.granate)),
                            const SizedBox(height: 8),
                            Text(
                              _esAdmin
                                  ? 'Toca el botón + para agregar la primera'
                                  : 'El admin aún no ha subido canciones',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color:
                                      AppColors.negro.withOpacity(0.6)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final tags = _todosLosTags(lista);
                  final filtradas = _filtrar(lista);

                  return Column(
                    children: [
                      if (tags.isNotEmpty)
                        SizedBox(
                          height: 40,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            children: [
                              if (_tagFiltro != null) ...[
                                ActionChip(
                                  avatar:
                                      const Icon(Icons.close, size: 16),
                                  label: const Text('Limpiar'),
                                  onPressed: () =>
                                      setState(() => _tagFiltro = null),
                                  backgroundColor:
                                      AppColors.granate.withOpacity(0.2),
                                ),
                                const SizedBox(width: 8),
                              ],
                              for (final t in tags)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(right: 8),
                                  child: FilterChip(
                                    label: Text(t),
                                    selected: _tagFiltro == t,
                                    selectedColor: AppColors.granate,
                                    labelStyle: TextStyle(
                                      color: _tagFiltro == t
                                          ? AppColors.dorado
                                          : AppColors.negro,
                                    ),
                                    onSelected: (sel) => setState(() =>
                                        _tagFiltro = sel ? t : null),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: filtradas.isEmpty
                            ? Center(
                                child: Text('Sin resultados',
                                    style: TextStyle(
                                        color: AppColors.negro
                                            .withOpacity(0.5))),
                              )
                            : ListView.builder(
                                itemCount: filtradas.length,
                                itemBuilder: (context, i) {
                                  final c = filtradas[i];
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          AppColors.granate,
                                      child: Text('${i + 1}',
                                          style: const TextStyle(
                                              color: AppColors.dorado)),
                                    ),
                                    title: Text(c.titulo,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.negro)),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${c.ritmo}${c.autor.isNotEmpty ? ' · ${c.autor}' : ''}',
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            const Icon(
                                                Icons.play_arrow,
                                                size: 12,
                                                color:
                                                    AppColors.granate),
                                            const SizedBox(width: 2),
                                            Text(
                                              '${c.reproducciones} reproducciones',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: AppColors.negro
                                                    .withOpacity(0.5),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    trailing: _esAdmin
                                        ? PopupMenuButton<String>(
                                            icon: const Icon(
                                                Icons.more_vert,
                                                color:
                                                    AppColors.granate),
                                            onSelected: (v) {
                                              if (v == 'editar') {
                                                _editar(c);
                                              } else if (v ==
                                                  'eliminar') {
                                                _eliminar(c);
                                              }
                                            },
                                            itemBuilder: (_) => const [
                                              PopupMenuItem(
                                                value: 'editar',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.edit,
                                                        size: 20),
                                                    SizedBox(width: 8),
                                                    Text('Editar'),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuItem(
                                                value: 'eliminar',
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                        Icons
                                                            .delete_outline,
                                                        size: 20),
                                                    SizedBox(width: 8),
                                                    Text('Eliminar'),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )
                                        : const Icon(
                                            Icons.chevron_right,
                                            color: AppColors.dorado),
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              CancionDetalleScreen(
                                                  cancion: c)),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}