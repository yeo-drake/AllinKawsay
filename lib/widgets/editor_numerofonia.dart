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
          'Escribe con espacios. Ej: 4 3 3 _ _ 5 6  (_ = vacío)',
          style: TextStyle(
            color: AppColors.negro.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        for (int i = 0; i < _secciones.length; i++)
          _SeccionEditor(
            key: ValueKey('sec_$i'),
            seccion: _secciones[i],
            numero: i + 1,
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
  final int numero;
  final bool puedeEliminar;
  final VoidCallback onDelete;
  final VoidCallback onChanged;

  const _SeccionEditor({
    super.key,
    required this.seccion,
    required this.numero,
    required this.puedeEliminar,
    required this.onDelete,
    required this.onChanged,
  });

  @override
  State<_SeccionEditor> createState() => _SeccionEditorState();
}

class _SeccionEditorState extends State<_SeccionEditor> {
  late TextEditingController _ctrl7;
  late TextEditingController _ctrl6;

  @override
  void initState() {
    super.initState();
    _ctrl7 = TextEditingController(
      text: SeccionNumerofonia.stringifyFila(widget.seccion.fila7),
    );
    _ctrl6 = TextEditingController(
      text: SeccionNumerofonia.stringifyFila(widget.seccion.fila6),
    );
    _ctrl7.addListener(_onTextChanged);
    _ctrl6.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    widget.seccion.fila7 =
        SeccionNumerofonia.parseFila(_ctrl7.text);
    widget.seccion.fila6 =
        SeccionNumerofonia.parseFila(_ctrl6.text);
    setState(() {});
    widget.onChanged();
  }

  @override
  void dispose() {
    _ctrl7.dispose();
    _ctrl6.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.seccion;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.dorado.withOpacity(0.4), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
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
              // BIS
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: s.conBis,
                    activeColor: AppColors.granate,
                    checkColor: AppColors.dorado,
                    onChanged: (v) {
                      setState(() => s.conBis = v ?? false);
                      widget.onChanged();
                    },
                  ),
                  const Text('BIS',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
              if (widget.puedeEliminar)
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: AppColors.granate, size: 20),
                  onPressed: widget.onDelete,
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Caña 7
          Row(
            children: [
              Container(
                width: 42,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.granate,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('7',
                    style: TextStyle(
                      color: AppColors.dorado,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    )),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _ctrl7,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: '_ _ 5 4 4 4 5 _ _',
                    hintStyle: TextStyle(
                      color: AppColors.negro.withOpacity(0.3),
                      fontFamily: 'monospace',
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Caña 6
          Row(
            children: [
              Container(
                width: 42,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.granate,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('6',
                    style: TextStyle(
                      color: AppColors.dorado,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    )),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _ctrl6,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: '4 3 3 3 4 _ _ 6 5 6',
                    hintStyle: TextStyle(
                      color: AppColors.negro.withOpacity(0.3),
                      fontFamily: 'monospace',
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Preview
          if (!s.vacia) ...[
            const Text('Vista previa:',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.granate)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.negro,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Column(
                      children: [
                        _celdaPreview('7', true),
                        const SizedBox(height: 2),
                        _celdaPreview('6', true),
                      ],
                    ),
                    const SizedBox(width: 6),
                    for (int i = 0; i < s.columnas; i++) ...[
                      Column(
                        children: [
                          _celdaPreview(
                            i < s.fila7.length ? s.fila7[i] : '',
                            false,
                          ),
                          const SizedBox(height: 2),
                          _celdaPreview(
                            i < s.fila6.length ? s.fila6[i] : '',
                            false,
                          ),
                        ],
                      ),
                      const SizedBox(width: 2),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _celdaPreview(String c, bool etiqueta) {
    final vacia = c.isEmpty;
    return Container(
      width: 32,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: etiqueta ? AppColors.granate : AppColors.negro,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: etiqueta
              ? AppColors.dorado
              : (vacia
                  ? AppColors.dorado.withOpacity(0.25)
                  : AppColors.dorado),
          width: 1,
        ),
      ),
      child: Text(
        c,
        style: TextStyle(
          color: AppColors.dorado,
          fontWeight: FontWeight.bold,
          fontSize: etiqueta ? 14 : 12,
        ),
      ),
    );
  }
}