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
            _itemOrden('Título (A-Z)', _OrdenCancion.titulo),
            _itemOrden('Autor (A-Z)', _OrdenCancion.autor),
            _itemOrden('Más reproducidas', _OrdenCancion.reproducciones),
            _itemOrden('Fecha de subida', _OrdenCancion.fecha),
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