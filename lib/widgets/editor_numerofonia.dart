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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColors.dorado.withOpacity(0.5), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.grid_on, size: 14, color: AppColors.granate),
              SizedBox(width: 8),
              Text('NUMEROFONÍA',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.granate,
                      letterSpacing: 2)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Escribí los números. Usá "/" para pasar a hilera 7 y "\\" para volver a hilera 6.',
            style: TextStyle(
                fontSize: 11,
                color: AppColors.negro.withOpacity(0.6),
                height: 1.4),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.grisClaro,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ejemplo:',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.granate.withOpacity(0.7))),
                const SizedBox(height: 4),
                const Text(
                  '4 4 3 4 / 5 5 6 5 \\ 3 3 2 3',
                  style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: AppColors.negro),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          for (int i = 0; i < _estrofas.length; i++)
            _BloqueEditor(
              key: ValueKey('bloque_$i'),
              estrofa: _estrofas[i],
              numero: i + 1,
              puedeEliminar: _estrofas.length > 1,
              onDelete: () => _eliminarEstrofa(i),
              onChanged: _notificar,
            ),

          const SizedBox(height: 4),
          OutlinedButton.icon(
            onPressed: _agregarEstrofa,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('AGREGAR ESTROFA',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              foregroundColor: AppColors.granate,
              side: BorderSide(
                  color: AppColors.granate.withOpacity(0.5)),
            ),
          ),
        ],
      ),
    );
  }
}

class _BloqueEditor extends StatefulWidget {
  final EstrofaNumerofonia estrofa;
  final int numero;
  final bool puedeEliminar;
  final VoidCallback onDelete;
  final VoidCallback onChanged;

  const _BloqueEditor({
    super.key,
    required this.estrofa,
    required this.numero,
    required this.puedeEliminar,
    required this.onDelete,
    required this.onChanged,
  });

  @override
  State<_BloqueEditor> createState() => _BloqueEditorState();
}

class _BloqueEditorState extends State<_BloqueEditor> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.estrofa.texto);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    widget.estrofa.texto = v;
    widget.onChanged();
  }

  void _toggleBis() {
    setState(() => widget.estrofa.bis = !widget.estrofa.bis);
    widget.onChanged();
  }

  /// Botón rápido para insertar "/" o "\" en la posición del cursor.
  void _insertarDireccion(String dir) {
    final sel = _ctrl.selection;
    final texto = _ctrl.text;
    int inicio = sel.start >= 0 ? sel.start : texto.length;
    int fin = sel.end >= 0 ? sel.end : texto.length;
    if (inicio > texto.length) inicio = texto.length;
    if (fin > texto.length) fin = texto.length;

    // Asegurar espacio antes
    final antes = texto.substring(0, inicio);
    final despues = texto.substring(fin);
    final prefijo = (antes.isEmpty || antes.endsWith(' ')) ? '' : ' ';
    final sufijo = (despues.isEmpty || despues.startsWith(' ')) ? ' ' : ' ';

    final nuevo = antes + prefijo + dir + sufijo + despues;
    _ctrl.text = nuevo;
    _ctrl.selection = TextSelection.collapsed(
        offset: (antes + prefijo + dir + sufijo).length);
    _onChanged(nuevo);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.grisClaro,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.negro.withOpacity(0.15), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('Estrofa ${widget.numero}',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.granate,
                      letterSpacing: 0.5)),
              const Spacer(),
              // Botones de dirección
              _botonDir('/', () => _insertarDireccion('/')),
              const SizedBox(width: 6),
              _botonDir('\\', () => _insertarDireccion('\\')),
              if (widget.puedeEliminar) ...[
                const SizedBox(width: 6),
                InkWell(
                  onTap: widget.onDelete,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    child: Icon(Icons.close,
                        size: 16,
                        color: AppColors.granate.withOpacity(0.7)),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),

          // Campo de texto
          TextField(
            controller: _ctrl,
            onChanged: _onChanged,
            maxLines: null,
            minLines: 2,
            style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.6),
            decoration: InputDecoration(
              isDense: true,
              hintText: '4 4 3 4 / 5 5 6 5 \\ 3 3 2 3',
              hintStyle: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: AppColors.negro.withOpacity(0.3)),
              filled: true,
              fillColor: AppColors.blanco,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    BorderSide(color: AppColors.negro.withOpacity(0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                    color: AppColors.dorado, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // BIS
          OutlinedButton.icon(
            onPressed: _toggleBis,
            icon: Icon(
              widget.estrofa.bis
                  ? Icons.check_circle
                  : Icons.circle_outlined,
              size: 16,
            ),
            label: Text(
              widget.estrofa.bis ? 'CON BIS' : 'SIN BIS',
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10),
              foregroundColor: widget.estrofa.bis
                  ? AppColors.dorado
                  : AppColors.granate,
              backgroundColor: widget.estrofa.bis
                  ? AppColors.granate
                  : Colors.transparent,
              side: BorderSide(
                color: widget.estrofa.bis
                    ? AppColors.dorado
                    : AppColors.granate,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _botonDir(String dir, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: AppColors.gradienteGranate,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          dir,
          style: const TextStyle(
            color: AppColors.dorado,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}