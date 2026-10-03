import 'package:flutter/material.dart';
import '../models/cancion.dart';
import '../models/categoria.dart';
import '../models/usuario.dart';
import '../services/cancion_service.dart';
import '../services/categoria_service.dart';
import '../services/player_service.dart';
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
  String? _categoriaFiltro;
  bool _soloFavoritos = false;
  _OrdenCancion _orden = _OrdenCancion.titulo;
  bool _ascendente = true;

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
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
            const SizedBox(height: 16),
            const Text('Ordenar por',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5)),
            const SizedBox(height: 12),
            _itemOrden('Título (A-Z)', _OrdenCancion.titulo),
            _itemOrden('Autor (A-Z)', _OrdenCancion.autor),
            _itemOrden('Más reproducidas', _OrdenCancion.reproducciones),
            _itemOrden('Fecha de subida', _OrdenCancion.fecha),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _itemOrden(String label, _OrdenCancion valor) {
    final selected = _orden == valor;
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.granate
              : AppColors.granate.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_off,
          color: selected ? AppColors.dorado : AppColors.granate,
          size: 20,
        ),
      ),
      title: Text(label,
          style: TextStyle(
              fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
      trailing: selected
          ? IconButton(
              icon: Icon(
                _ascendente
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
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

  List<Cancion> _filtrar(List<Cancion> lista, List<String> favoritos) {
    var r = lista;
    if (_soloFavoritos) {
      r = r.where((c) => favoritos.contains(c.id)).toList();
    }
    if (_categoriaFiltro != null && _categoriaFiltro!.isNotEmpty) {
      r = r.where((c) => c.categoriaId == _categoriaFiltro).toList();
    }
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
  final onSurface = Theme.of(context).colorScheme.onSurface;
  return Scaffold(
    appBar: AppBar(
      title: const Text('CANCIONERO'),
      actions: [
        IconButton(
          icon: const Icon(Icons.sort),
          tooltip: 'Ordenar',
          onPressed: _abrirMenuOrden,
        ),
        const SizedBox(width: 4),
      ],
    ),
    floatingActionButton: _esAdmin
        ? FloatingActionButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const AgregarCancionScreen()),
            ),
            child: const Icon(Icons.add, size: 26),
          )
        : null,
    body: WatermarkOverlay(
      opacity: 0.04,
      child: StreamBuilder<Usuario?>(
        stream: UsuarioService().miUsuario(),
        builder: (context, userSnap) {
          final favs = userSnap.data?.favoritos ?? <String>[];
          return ValueListenableBuilder<EstadoPlayer>(
            valueListenable: PlayerService().estado,
            builder: (context, estado, _) {
              return Column(
                children: [
                  // === BUSCADOR ===
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(
                        hintText: 'Buscar canción, autor, ritmo...',
                        prefixIcon: const Icon(Icons.search,
                            color: AppColors.granate, size: 22),
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear,
                                    size: 20),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() => _query = '');
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                  // === INFO ORDEN ===
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.granate.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.sort,
                              size: 11, color: AppColors.granate),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Ordenado por ${_nombreOrden()} ${_ascendente ? '↑' : '↓'}',
                          style: TextStyle(
                            fontSize: 11,
                            color: onSurface.withOpacity(0.55),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<List<Cancion>>(
                      stream: _service.listar(),
                      builder: (context, snap) {
                        if (snap.connectionState ==
                            ConnectionState.waiting) {
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
                          return _emptyState(onSurface);
                        }

                        final tags = _todosLosTags(lista);
                        final filtradas = _filtrar(lista, favs);
                        final hayFavs = favs.isNotEmpty;

                        return Column(
                          children: [
                            StreamBuilder<List<Categoria>>(
                              stream: CategoriaService().listar(),
                              builder: (context, catSnap) {
                                final cats = catSnap.data ?? [];
                                return Column(
                                  children: [
                                    if (cats.isNotEmpty)
                                      SizedBox(
                                        height: 38,
                                        child: ListView(
                                          scrollDirection:
                                              Axis.horizontal,
                                          padding: const EdgeInsets
                                              .symmetric(
                                              horizontal: 16),
                                          children: [
                                            for (final cat in cats)
                                              Padding(
                                                padding:
                                                    const EdgeInsets
                                                        .only(right: 8),
                                                child: FilterChip(
                                                  label: Text(
                                                      '${cat.emoji} ${cat.nombre}'),
                                                  selected:
                                                      _categoriaFiltro ==
                                                          cat.id,
                                                  selectedColor:
                                                      AppColors
                                                          .granate,
                                                  labelStyle:
                                                      TextStyle(
                                                    color: _categoriaFiltro ==
                                                            cat.id
                                                        ? AppColors
                                                            .dorado
                                                        : onSurface,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w600,
                                                  ),
                                                  onSelected: (sel) =>
                                                      setState(() =>
                                                          _categoriaFiltro =
                                                              sel
                                                                  ? cat.id
                                                                  : null),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    SizedBox(
                                      height: 38,
                                      child: ListView(
                                        scrollDirection:
                                            Axis.horizontal,
                                        padding: const EdgeInsets
                                            .symmetric(horizontal: 16),
                                        children: [
                                          FilterChip(
                                            avatar: Icon(
                                              _soloFavoritos
                                                  ? Icons.favorite
                                                  : Icons
                                                      .favorite_border,
                                              size: 16,
                                              color: _soloFavoritos
                                                  ? AppColors.granate
                                                  : onSurface
                                                      .withOpacity(0.5),
                                            ),
                                            label:
                                                const Text('Favoritos'),
                                            selected: _soloFavoritos,
                                            selectedColor: AppColors
                                                .dorado
                                                .withOpacity(0.4),
                                            labelStyle: TextStyle(
                                              fontSize: 12,
                                              fontWeight:
                                                  FontWeight.w600,
                                              color: onSurface,
                                            ),
                                            onSelected: (sel) =>
                                                setState(() =>
                                                    _soloFavoritos =
                                                        sel),
                                          ),
                                          const SizedBox(width: 8),
                                          if (_tagFiltro != null) ...[
                                            ActionChip(
                                              avatar: const Icon(
                                                  Icons.close,
                                                  size: 16),
                                              label:
                                                  const Text('Limpiar'),
                                              onPressed: () =>
                                                  setState(() =>
                                                      _tagFiltro =
                                                          null),
                                              backgroundColor:
                                                  AppColors.granate
                                                      .withOpacity(0.2),
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                          for (final t in tags)
                                            Padding(
                                              padding:
                                                  const EdgeInsets
                                                      .only(right: 8),
                                              child: FilterChip(
                                                label: Text(t),
                                                selected:
                                                    _tagFiltro == t,
                                                selectedColor:
                                                    AppColors.granate,
                                                labelStyle: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight:
                                                      FontWeight.w600,
                                                  color:
                                                      _tagFiltro == t
                                                          ? AppColors
                                                              .dorado
                                                          : onSurface,
                                                ),
                                                onSelected: (sel) =>
                                                    setState(() =>
                                                        _tagFiltro =
                                                            sel
                                                                ? t
                                                                : null),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                );
                              },
                            ),
                            Expanded(
                              child: filtradas.isEmpty
                                  ? Center(
                                      child: Text(
                                        _soloFavoritos && !hayFavs
                                            ? 'Aún no marcaste favoritos'
                                            : 'Sin resultados',
                                        style: TextStyle(
                                            color: onSurface
                                                .withOpacity(0.5),
                                            fontStyle:
                                                FontStyle.italic),
                                      ),
                                    )
                                  : ListView.builder(
                                      padding: const EdgeInsets
                                          .fromLTRB(16, 4, 16, 100),
                                      itemCount: filtradas.length,
                                      itemBuilder: (context, i) {
                                        return _tarjetaCancion(
                                          context,
                                          filtradas[i],
                                          i,
                                          favs,
                                          estado,
                                          onSurface,
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
              );
            },
          );
        },
      ),
    ),
  );
}

  Widget _tarjetaCancion(
    BuildContext context,
    Cancion c,
    int index,
    List<String> favs,
    EstadoPlayer estado,
    Color onSurface,
  ) {
    final esFav = favs.contains(c.id);
    final sonando = estado.cancionId == c.id;
    final reproduciendo = sonando && estado.playing;
    final cargando = sonando && estado.cargando;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => CancionDetalleScreen(cancion: c)),
          ),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardColor(context),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: sonando
                    ? AppColors.dorado.withOpacity(0.6)
                    : AppColors.dorado.withOpacity(0.2),
                width: sonando ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Botón play
                GestureDetector(
                  onTap: () => PlayerService().toggle(c),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: reproduciendo
                          ? AppColors.gradienteDorado
                          : AppColors.gradienteGranate,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: (reproduciendo
                                  ? AppColors.dorado
                                  : AppColors.granate)
                              .withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: cargando
                        ? const Padding(
                            padding: EdgeInsets.all(14),
                            child: CircularProgressIndicator(
                              color: AppColors.dorado,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Icon(
                            reproduciendo
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: reproduciendo
                                ? AppColors.granate
                                : AppColors.dorado,
                            size: 30,
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.titulo,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: onSurface,
                          fontSize: 15,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${c.ritmo}${c.autor.isNotEmpty ? ' · ${c.autor}' : ''}',
                        style: TextStyle(
                          fontSize: 12,
                          color: onSurface.withOpacity(0.55),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.granate.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.play_arrow,
                                    size: 10,
                                    color: AppColors.granate),
                                const SizedBox(width: 2),
                                Text(
                                  '${c.reproducciones}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.granate,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (c.tieneCategoria)
                            Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Icon(Icons.folder_outlined,
                                  size: 12,
                                  color: onSurface.withOpacity(0.35)),
                            ),
                          if (c.tieneNumerofonia)
                            Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Icon(Icons.grid_on,
                                  size: 12,
                                  color: onSurface.withOpacity(0.35)),
                            ),
                          if (c.audioUrl.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Icon(Icons.audiotrack,
                                  size: 12,
                                  color: onSurface.withOpacity(0.35)),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Favorito
                IconButton(
                  icon: Icon(
                    esFav ? Icons.favorite : Icons.favorite_border,
                    color: esFav
                        ? AppColors.granate
                        : onSurface.withOpacity(0.3),
                    size: 22,
                  ),
                  onPressed: () =>
                      UsuarioService().toggleFavorito(c.id),
                ),
                // Menú admin
                if (_esAdmin)
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert,
                        color: onSurface.withOpacity(0.5), size: 22),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    onSelected: (v) {
                      if (v == 'editar') {
                        _editar(c);
                      } else if (v == 'eliminar') {
                        _eliminar(c);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'editar',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 10),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'eliminar',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline,
                                size: 20, color: Colors.red),
                            SizedBox(width: 10),
                            Text('Eliminar',
                                style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState(Color onSurface) {
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
              child: Icon(Icons.library_music,
                  size: 48,
                  color: AppColors.granate.withOpacity(0.4)),
            ),
            const SizedBox(height: 20),
            const Text('Aún no hay canciones',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.granate,
                    letterSpacing: 0.5)),
            const SizedBox(height: 8),
            Text(
              _esAdmin
                  ? 'Toca el botón + para agregar la primera'
                  : 'El admin aún no ha subido canciones',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: onSurface.withOpacity(0.55),
                  fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}