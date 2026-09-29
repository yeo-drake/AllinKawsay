import 'package:flutter/material.dart';
import '../models/numerofonia.dart';
import '../theme/colors.dart';

class EditorNumerofonia extends StatefulWidget {
  final List<SeccionNumerofonia> inicial;
  final ValueChanged<List<SeccionNumerofonia>> onChanged;

  const EditorNumerofonia({
    super.key,
    required this.inicial,
    required this.onChanged,
  });

  @override
  State<EditorNumerofonia> createState() => _EditorNumerofoniaState();
}

class _EditorNumerofoniaState extends State<EditorNumerofonia> {
  late List<SeccionNumerofonia> _secciones;

  @override
  void initState() {
    super.initState();
    _secciones = widget.inicial.map((s) => s.copy()).toList();
    if (_secciones.isEmpty) {
      _secciones.add(SeccionNumerofonia(nombre: 'A'));
    }
  }

  void _notificar() => widget.onChanged(_secciones);

  void _agregarSeccion() {
    const letras = ['A', 'B', 'C', 'D', 'E', 'F'];
    final siguiente = letras[_secciones.length % letras.length];
    setState(() => _secciones.add(SeccionNumerofonia(nombre: siguiente)));
    _notificar();
  }

  void _eliminarSeccion(int i) {
    if (_secciones.length == 1) return;
    setState(() => _secciones.removeAt(i));
    _notificar();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Numerofonía',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.granate,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Toca una celda para escribir. Usa + para agregar una columna nueva.',
          style: TextStyle(
            color: AppColors.negro.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        for (int i = 0; i < _secciones.length; i++)
          _SeccionEditor(
            key: ValueKey('sec_${_secciones[i].nombre}_$i'),
            seccion: _secciones[i],
            puedeEliminar: _secciones.length > 1,
            onDelete: () => _eliminarSeccion(i),
            onChanged: _notificar,
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _agregarSeccion,
          icon: const Icon(Icons.add),
          label: const Text('Agregar sección'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }
}


class _SeccionEditor extends StatefulWidget {
  final SeccionNumerofonia seccion;
  final bool puedeEliminar;
  final VoidCallback onDelete;
  final VoidCallback onChanged;

  const _SeccionEditor({
    super.key,
    required this.seccion,
    required this.puedeEliminar,
    required this.onDelete,
    required this.onChanged,
  });

  @override
  State<_SeccionEditor> createState() => _SeccionEditorState();
}

class _SeccionEditorState extends State<_SeccionEditor> {
  @override
  Widget build(BuildContext context) {
    final s = widget.seccion;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.dorado.withOpacity(0.4), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.granate,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'SECCIÓN ${s.nombre}',
                  style: const TextStyle(
                    color: AppColors.dorado,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const Spacer(),
              if (widget.puedeEliminar)
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: AppColors.granate, size: 20),
                  onPressed: widget.onDelete,
                ),
            ],
          ),
          const SizedBox(height: 8),
          for (int i = 0; i < s.lineas.length; i++)
            _LineaEditor(
              key: ValueKey('linea_${s.nombre}_$i'),
              linea: s.lineas[i],
              numeroLinea: i + 1,
              puedeEliminar: s.lineas.length > 1,
              onDelete: () {
                setState(() => s.lineas.removeAt(i));
                widget.onChanged();
              },
              onChanged: widget.onChanged,
            ),
          const SizedBox(height: 4),
          OutlinedButton.icon(
            onPressed: () {
              setState(() => s.lineas.add(LineaNumerofonia()));
              widget.onChanged();
            },
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Agregar otra línea de compás',
                style: TextStyle(fontSize: 13)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}

class _LineaEditor extends StatefulWidget {
  final LineaNumerofonia linea;
  final int numeroLinea;
  final bool puedeEliminar;
  final VoidCallback onDelete;
  final VoidCallback onChanged;

  const _LineaEditor({
    super.key,
    required this.linea,
    required this.numeroLinea,
    required this.puedeEliminar,
    required this.onDelete,
    required this.onChanged,
  });

  @override
  State<_LineaEditor> createState() => _LineaEditorState();
}

class _LineaEditorState extends State<_LineaEditor> {
  void _insertarColumna(int pos) {
    setState(() => widget.linea.insertarColumna(pos));
    widget.onChanged();
  }

  void _eliminarColumna(int index) async {
    if (widget.linea.columnas <= 1) {
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
      setState(() => widget.linea.eliminarColumna(index));
      widget.onChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.linea;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.grisClaro,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Línea ${widget.numeroLinea}',
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
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Quitar',
                      style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.granate,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 32),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          _tablaEditable(l),
        ],
      ),
    );
  }

  Widget _tablaEditable(LineaNumerofonia l) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.blanco,
          border: Border.all(color: AppColors.negro, width: 1.2),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Etiquetas
            Column(
              children: [
                _etiqueta('7'),
                Container(height: 1.2, color: AppColors.negro),
                _etiqueta('6'),
              ],
            ),
            // Columnas + botones "+" intercalados
            for (int i = 0; i < l.columnas; i++) ...[
              _columnaCeldas(l, i),
              _botonInsertar(i + 1),
            ],
          ],
        ),
      ),
    );
  }

  Widget _etiqueta(String t) {
    return Container(
      width: 26,
      height: 34,
      alignment: Alignment.center,
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

  Widget _columnaCeldas(LineaNumerofonia l, int index) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(color: AppColors.negro, width: 1),
        ),
      ),
      child: Column(
        children: [
          _celdaEditable(
            valor: l.fila7[index],
            onChanged: (v) {
              l.fila7[index] = v;
              widget.onChanged();
            },
            onLongPress: () => _eliminarColumna(index),
          ),
          Container(height: 1, color: AppColors.negro),
          _celdaEditable(
            valor: l.fila6[index],
            onChanged: (v) {
              l.fila6[index] = v;
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

    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        constraints: const BoxConstraints(minWidth: 48),
        height: 34,
        child: TextField(
          controller: controller,
          textAlign: TextAlign.center,
          maxLength: 8,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.negro,
          ),
          decoration: const InputDecoration(
            counterText: '',
            isDense: true,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            border: InputBorder.none,
            hintText: '',
          ),
          onChanged: (v) => onChanged(v.trim()),
        ),
      ),
    );
  }

  Widget _botonInsertar(int pos) {
    return SizedBox(
      width: 26,
      child: Center(
        child: InkWell(
          onTap: () => _insertarColumna(pos),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: AppColors.dorado.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.granate, width: 1),
            ),
            child: const Icon(Icons.add,
                size: 14, color: AppColors.granate),
          ),
        ),
      ),
    );
  }
}