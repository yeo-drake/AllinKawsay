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
          // Header
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
            'Escribí cada celda separada por espacio. Usá "_" para vacío.',
            style: TextStyle(
                fontSize: 11,
                color: AppColors.negro.withOpacity(0.55),
                height: 1.4),
          ),
          const SizedBox(height: 4),
          Text(
            'Ejemplo:  6 6 6 5 56665 6',
            style: TextStyle(
                fontSize: 10.5,
                color: AppColors.negro.withOpacity(0.45),
                fontStyle: FontStyle.italic,
                fontFamily: 'monospace'),
          ),
          const SizedBox(height: 12),

          // Lista de estrofas
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
  late TextEditingController _ctrl7;
  late TextEditingController _ctrl6;

  @override
  void initState() {
    super.initState();
    _ctrl7 = TextEditingController(
        text: EstrofaNumerofonia.stringifyFila(widget.estrofa.fila7));
    _ctrl6 = TextEditingController(
        text: EstrofaNumerofonia.stringifyFila(widget.estrofa.fila6));
  }

  @override
  void dispose() {
    _ctrl7.dispose();
    _ctrl6.dispose();
    super.dispose();
  }

  void _onFila7(String v) {
    widget.estrofa.fila7 = EstrofaNumerofonia.parseFila(v);
    widget.onChanged();
  }

  void _onFila6(String v) {
    widget.estrofa.fila6 = EstrofaNumerofonia.parseFila(v);
    widget.onChanged();
  }

  void _toggleBis() {
    setState(() => widget.estrofa.bis = !widget.estrofa.bis);
    widget.onChanged();
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
          // Header del bloque
          Row(
            children: [
              Text('Estrofa ${widget.numero}',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.granate,
                      letterSpacing: 0.5)),
              const Spacer(),
              if (widget.puedeEliminar)
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
          ),
          const SizedBox(height: 8),

          // Fila 7
          Row(
            children: [
              Container(
                width: 34,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: AppColors.gradienteGranate,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('7',
                    style: TextStyle(
                        color: AppColors.dorado,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _ctrl7,
                  onChanged: _onFila7,
                  style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: '6 6 6 5 56665 6',
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
                      borderSide: BorderSide(
                          color:
                              AppColors.negro.withOpacity(0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                          color: AppColors.dorado, width: 2),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Fila 6
          Row(
            children: [
              Container(
                width: 34,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: AppColors.gradienteGranate,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('6',
                    style: TextStyle(
                        color: AppColors.dorado,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _ctrl6,
                  onChanged: _onFila6,
                  style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: '6 5 6 5 4434 _ 5 6',
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
                      borderSide: BorderSide(
                          color:
                              AppColors.negro.withOpacity(0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                          color: AppColors.dorado, width: 2),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // BIS toggle
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _toggleBis,
                  icon: Icon(
                    widget.estrofa.bis
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    size: 16,
                  ),
                  label: Text(
                    widget.estrofa.bis
                        ? 'CON BIS'
                        : 'SIN BIS',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 10),
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
              ),
            ],
          ),

          // Preview
          if (!widget.estrofa.vacia) ...[
            const SizedBox(height: 10),
            const Text('Vista previa:',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.granate,
                    letterSpacing: 1)),
            const SizedBox(height: 6),
            _preview(widget.estrofa),
          ],
        ],
      ),
    );
  }

  Widget _preview(EstrofaNumerofonia e) {
    final numCols = e.fila7.length > e.fila6.length
        ? e.fila7.length
        : e.fila6.length;
    if (numCols == 0) return const SizedBox.shrink();

    final anchos = <double>[];
    for (int i = 0; i < numCols; i++) {
      final v7 = i < e.fila7.length ? e.fila7[i] : '';
      final v6 = i < e.fila6.length ? e.fila6[i] : '';
      final len = v7.length > v6.length ? v7.length : v6.length;
      final ancho = len <= 1
          ? 22.0
          : (len * 8.0 + 8.0).clamp(22.0, 80.0);
      anchos.add(ancho);
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.blanco,
        border: Border.all(color: AppColors.negro, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 26,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < numCols; i++)
                      _pCelda(
                          i < e.fila7.length ? e.fila7[i] : '',
                          anchos[i],
                          i == numCols - 1 && !e.bis),
                  ],
                ),
              ),
              Container(height: 1, color: AppColors.negro),
              SizedBox(
                height: 26,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < numCols; i++)
                      _pCelda(
                          i < e.fila6.length ? e.fila6[i] : '',
                          anchos[i],
                          i == numCols - 1 && !e.bis),
                  ],
                ),
              ),
            ],
          ),
          if (e.bis)
            Container(
              width: 40,
              height: 53,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.dorado,
                border: Border(
                    left:
                        BorderSide(color: AppColors.negro, width: 1)),
              ),
              child: const Text('BIS',
                  style: TextStyle(
                      color: AppColors.negro,
                      fontWeight: FontWeight.bold,
                      fontSize: 9,
                      letterSpacing: 0.5)),
            ),
        ],
      ),
    );
  }

  Widget _pCelda(String contenido, double ancho, bool esUltima) {
    return Container(
      width: ancho,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: esUltima
            ? null
            : const Border(
                right: BorderSide(color: AppColors.negro, width: 1),
              ),
      ),
      child: Text(
        contenido,
        style: const TextStyle(
            color: AppColors.negro,
            fontWeight: FontWeight.w500,
            fontSize: 11,
            fontFamily: 'monospace'),
      ),
    );
  }
}