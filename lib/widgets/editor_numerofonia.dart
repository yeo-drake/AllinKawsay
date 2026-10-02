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
        border: Border.all(color: AppColors.negro, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          const Center(
            child: Text(
              'NUMEROFONÍA',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.negro,
                fontSize: 16,
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
                    fontSize: 12,
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
                    fontSize: 12,
                    color: AppColors.negro,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Lista de estrofas
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
  void _agregarColumna() {
    setState(() => widget.estrofa.agregarColumna());
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Tabla
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.blanco,
                      border:
                          Border.all(color: AppColors.negro, width: 1.2),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Etiquetas 7 / 6
                        Column(
                          children: [
                            _etiqueta('7'),
                            Container(height: 1.2, color: AppColors.negro),
                            _etiqueta('6'),
                          ],
                        ),
                        // Columnas
                        for (int i = 0; i < e.columnas; i++)
                          _columna(e, i),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // Botón +
              InkWell(
                onTap: _agregarColumna,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.dorado.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: AppColors.granate, width: 1.5),
                  ),
                  child: const Icon(Icons.add,
                      color: AppColors.granate, size: 22),
                ),
              ),
              const SizedBox(width: 6),
              // BIS toggle
              InkWell(
                onTap: () {
                  setState(() => e.bis = !e.bis);
                  widget.onChanged();
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: e.bis
                        ? AppColors.granate
                        : AppColors.negro.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: e.bis
                          ? AppColors.dorado
                          : AppColors.negro.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    e.bis ? 'BIS ON' : 'BIS OFF',
                    style: TextStyle(
                      color: e.bis
                          ? AppColors.dorado
                          : AppColors.negro.withOpacity(0.5),
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _etiqueta(String t) {
    return Container(
      width: 28,
      height: 40,
      alignment: Alignment.center,
      child: Text(
        t,
        style: const TextStyle(
          color: AppColors.negro,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _columna(EstrofaNumerofonia e, int index) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(color: AppColors.negro, width: 1.2),
        ),
      ),
      child: Column(
        children: [
          _celdaEditable(
            valor: e.fila7[index],
            onChanged: (v) {
              e.fila7[index] = v;
              widget.onChanged();
            },
            onLongPress: () => _eliminarColumna(index),
          ),
          Container(height: 1.2, color: AppColors.negro),
          _celdaEditable(
            valor: e.fila6[index],
            onChanged: (v) {
              e.fila6[index] = v;
              widget.onChanged();
            },
            onLongPress: () => _eliminarColumna(index),
          ),
        ],
      ),
    );
  }

  Widget _celdaEditable({
    required String valor,
    required ValueChanged<String> onChanged,
    required VoidCallback onLongPress,
  }) {
    final controller = TextEditingController(text: valor);
    controller.selection = TextSelection.collapsed(
      offset: controller.text.length,
    );
    final ancho = valor.isEmpty
        ? 55.0
        : (valor.length * 11.0 + 24.0).clamp(55.0, 130.0);

    return GestureDetector(
      onLongPress: onLongPress,
      child: SizedBox(
        width: ancho,
        height: 40,
        child: TextField(
          controller: controller,
          textAlign: TextAlign.center,
          maxLength: 10,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.negro,
          ),
          decoration: const InputDecoration(
            counterText: '',
            isDense: true,
            contentPadding: EdgeInsets.zero,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            hintText: '',
          ),
          onChanged: (v) => onChanged(v.trim()),
        ),
      ),
    );
  }
}
