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

  void _notificar() {
    widget.onChanged(_secciones);
  }

  void _agregarSeccion() {
    const letras = ['A', 'B', 'C', 'D', 'E', 'F'];
    final siguiente = letras[_secciones.length % letras.length];
    setState(() {
      _secciones.add(SeccionNumerofonia(nombre: siguiente));
    });
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
          'Toca una celda para escribir. Usa "+ Columna" para agregar un compás.',
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
          const SizedBox(height: 6),
          for (int i = 0; i < s.lineas.length; i++)
            _LineaEditor(
              key: ValueKey('linea_${s.nombre}_$i'),
              linea: s.lineas[i],
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
            label: const Text('Agregar línea (compás)',
                style: TextStyle(fontSize: 13)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ],
      ),
    );
  }
}

class _LineaEditor extends StatefulWidget {
  final LineaNumerofonia linea;
  final bool puedeEliminar;
  final VoidCallback onDelete;
  final VoidCallback onChanged;

  const _LineaEditor({
    super.key,
    required this.linea,
    required this.puedeEliminar,
    required this.onDelete,
    required this.onChanged,
  });

  @override
  State<_LineaEditor> createState() => _LineaEditorState();
}

class _LineaEditorState extends State<_LineaEditor> {
  void _agregarColumna() {
    setState(() {
      widget.linea.fila7.add('');
      widget.linea.fila6.add('');
    });
    widget.onChanged();
  }

  void _quitarColumna() {
    if (widget.linea.columnas == 0) return;
    setState(() {
      if (widget.linea.fila7.isNotEmpty) widget.linea.fila7.removeLast();
      if (widget.linea.fila6.isNotEmpty) widget.linea.fila6.removeLast();
    });
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.linea;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.grisClaro,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Tabla editable
          Container(
            decoration: BoxDecoration(
              color: AppColors.blanco,
              border: Border.all(color: AppColors.negro, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _filaEditable(l.fila7, '7'),
                _filaEditable(l.fila6, '6'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Botones
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _agregarColumna,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Columna',
                      style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    minimumSize: const Size(0, 34),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _quitarColumna,
                  icon: const Icon(Icons.remove, size: 16),
                  label: const Text('Columna',
                      style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    minimumSize: const Size(0, 34),
                    foregroundColor: AppColors.granate,
                  ),
                ),
              ),
              if (widget.puedeEliminar) ...[
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.close,
                      color: AppColors.granate, size: 20),
                  onPressed: widget.onDelete,
                  tooltip: 'Quitar línea',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _filaEditable(List<String> fila, String etiqueta) {
    final cols = widget.linea.columnas;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Etiqueta 7 / 6
          Container(
            width: 26,
            padding: const EdgeInsets.symmetric(vertical: 6),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(color: AppColors.negro, width: 1),
              ),
            ),
            child: Text(
              etiqueta,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.negro,
              ),
            ),
          ),
          // Celdas
          for (int i = 0; i < cols; i++)
            _celdaEditable(fila, i, esUltima: i == cols - 1),
        ],
      ),
    );
  }

  Widget _celdaEditable(List<String> fila, int index,
      {required bool esUltima}) {
    final valor = index < fila.length ? fila[index] : '';
    final controller = TextEditingController(text: valor);
    controller.selection = TextSelection.collapsed(
      offset: controller.text.length,
    );

    return Container(
      constraints: const BoxConstraints(minWidth: 40),
      decoration: BoxDecoration(
        border: esUltima
            ? null
            : const Border(
                right: BorderSide(color: AppColors.negro, width: 0.8),
              ),
      ),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        maxLength: 6,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
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
        onChanged: (v) {
          if (index >= fila.length) return;
          fila[index] = v.trim();
          widget.onChanged();
        },
      ),
    );
  }
}