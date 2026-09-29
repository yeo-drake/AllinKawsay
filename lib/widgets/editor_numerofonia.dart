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