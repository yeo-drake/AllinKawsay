import 'dart:async';
import 'package:flutter/material.dart';
import '../models/numerofonia.dart';
import '../theme/colors.dart';

class EditorNumerofonia extends StatefulWidget {
  final List<EstrofaNumerofonia> inicial;
  final String autor;
  final String ritmo;
  final ValueChanged<List<EstrofaNumerofonia>> onChanged;

  const EditorNumerofonia({
    super.key,
    required this.inicial,
    required this.autor,
    required this.ritmo,
    required this.onChanged,
  });

  @override
  State<EditorNumerofonia> createState() => _EditorNumerofoniaState();
}

class _EditorNumerofoniaState extends State<EditorNumerofonia> {
  late List<EstrofaNumerofonia> _estrofas;

  @override
  void initState() {
    super.initState();
    _estrofas = widget.inicial.map((e) => e.copy()).toList();
    if (_estrofas.isEmpty) {
      _estrofas.add(EstrofaNumerofonia());
    }
  }

  void _notificar() => widget.onChanged(_estrofas);

  void _agregarEstrofa() {
    setState(() => _estrofas.add(EstrofaNumerofonia()));
    _notificar();
  }

  void _eliminarEstrofa(int i) {
    if (_estrofas.length == 1) return;
    setState(() => _estrofas.removeAt(i));
    _notificar();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dorado, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: Text(
              'NUMEROFONÍA',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.granate,
                fontSize: 15,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Autor: ${widget.autor.isEmpty ? '—' : widget.autor}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.negro,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Ritmo: ${widget.ritmo.isEmpty ? '—' : widget.ritmo}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.negro,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),
          for (int i = 0; i < _estrofas.length; i++)
            _EstrofaEditor(
              key: ValueKey('estrofa_$i'),
              estrofa: _estrofas[i],
              numero: i + 1,
              puedeEliminar: _estrofas.length > 1,
              onDelete: () => _eliminarEstrofa(i),
              onChanged: _notificar,
            ),
          const SizedBox(height: 4),
          OutlinedButton.icon(
            onPressed: _agregarEstrofa,
            icon: const Icon(Icons.add),
            label: const Text('AÑADIR ESTROFA'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              foregroundColor: AppColors.granate,
              side: const BorderSide(color: AppColors.granate, width: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _EstrofaEditor extends StatefulWidget {
  final EstrofaNumerofonia estrofa;
  final int numero;
  final bool puedeEliminar;
  final VoidCallback onDelete;
  final VoidCallback onChanged;

  const _EstrofaEditor({
    super.key,
    required this.estrofa,
    required this.numero,
    required this.puedeEliminar,
    required this.onDelete,
    required this.onChanged,
  });

  @override
  State<_EstrofaEditor> createState() => _EstrofaEditorState();
}

class _EstrofaEditorState extends State<_EstrofaEditor> {
  static const double cellW = 64.0;
  static const double cellH = 42.0;
  static const double labelW = 26.0;

  void _agregarColumna() {
    setState(() => widget.estrofa.agregarColumna());
    widget.onChanged();
  }

  void _toggleBis() {
    setState(() => widget.estrofa.bis = !widget.estrofa.bis);
    widget.onChanged();
  }

  void _eliminarColumna(int index) async {
    if (widget.estrofa.columnas <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe quedar al menos una columna')),
      );
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar columna'),
        content: Text('¿Eliminar la columna ${index + 1}?'),
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
    if (ok == true) {
      setState(() => widget.estrofa.eliminarColumna(index));
      widget.onChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.estrofa;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.grisClaro,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: AppColors.negro.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Estrofa ${widget.numero}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppColors.granate,
                ),
              ),
              const Spacer(),
              if (widget.puedeEliminar)
                TextButton.icon(
                  onPressed: widget.onDelete,
                  icon: const Icon(Icons.close, size: 14),
                  label: const Text('Quitar',
                      style: TextStyle(fontSize: 11)),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.granate,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    minimumSize: const Size(0, 28),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.blanco,
                border: Border.all(color: AppColors.negro, width: 1.2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: cellH,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _label('7'),
                        for (int i = 0; i < e.columnas; i++)
                          _celda(e.fila7, i),
                      ],
                    ),
                  ),
                  Container(height: 1.2, color: AppColors.negro),
                  SizedBox(
                    height: cellH,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _label('6'),
                        for (int i = 0; i < e.columnas; i++)
                          _celda(e.fila6, i),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _agregarColumna,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Columna',
                      style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    minimumSize: const Size(0, 36),
                    foregroundColor: AppColors.granate,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _toggleBis,
                  icon: Icon(
                    e.bis ? Icons.check_circle : Icons.circle_outlined,
                    size: 16,
                  ),
                  label: Text(
                    e.bis ? 'BIS ON' : 'BIS OFF',
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    minimumSize: const Size(0, 36),
                    foregroundColor:
                        e.bis ? AppColors.dorado : AppColors.granate,
                    backgroundColor:
                        e.bis ? AppColors.granate : Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _label(String t) {
    return Container(
      width: labelW,
      height: cellH,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: AppColors.negro, width: 1.2),
        ),
      ),
      child: Text(
        t,
        style: const TextStyle(
          color: AppColors.negro,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _celda(List<String> fila, int index) {
    return Container(
      width: cellW,
      height: cellH,
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: AppColors.negro, width: 0.8),
        ),
      ),
      child: _CeldaEditable(
        key: ValueKey('celda_${widget.numero}_${fila.hashCode}_$index'),
        valorInicial: index < fila.length ? fila[index] : '',
        onChanged: (v) {
          if (index < fila.length) {
            fila[index] = v;
            widget.onChanged();
          }
        },
        onLongPress: () => _eliminarColumna(index),
      ),
    );
  }
}

class _CeldaEditable extends StatefulWidget {
  final String valorInicial;
  final ValueChanged<String> onChanged;
  final VoidCallback onLongPress;

  const _CeldaEditable({
    super.key,
    required this.valorInicial,
    required this.onChanged,
    required this.onLongPress,
  });

  @override
  State<_CeldaEditable> createState() => _CeldaEditableState();
}

class _CeldaEditableState extends State<_CeldaEditable> {
  late TextEditingController _ctrl;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.valorInicial);
  }

  @override
  void didUpdateWidget(covariant _CeldaEditable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.valorInicial != oldWidget.valorInicial &&
        _ctrl.text != widget.valorInicial) {
      _ctrl.text = widget.valorInicial;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      widget.onChanged(v.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: widget.onLongPress,
      child: Center(
        child: TextField(
          controller: _ctrl,
          textAlign: TextAlign.center,
          maxLength: 15,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.negro,
          ),
          decoration: const InputDecoration(
            counterText: '',
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 2),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            hintText: '',
          ),
          onChanged: _onChanged,
        ),
      ),
    );
  }
}