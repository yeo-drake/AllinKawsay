import 'package:flutter/material.dart';
import '../models/numerofonia.dart';
import '../theme/colors.dart';

class VisorNumerofonia extends StatelessWidget {
  final List<SeccionNumerofonia> secciones;
  final double escala;
  const VisorNumerofonia({
    super.key,
    required this.secciones,
    this.escala = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final validas = secciones.where((s) => !s.vacia).toList();
    if (validas.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final s in validas) ...[
          _seccion(s),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _seccion(SeccionNumerofonia s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SECCIÓN ${s.nombre}',
          style: TextStyle(
            color: AppColors.granate,
            fontWeight: FontWeight.bold,
            fontSize: 11 * escala,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        for (int i = 0; i < s.lineas.length; i++) ...[
          if (!s.lineas[i].vacia) _linea(s.lineas[i]),
          if (i < s.lineas.length - 1) const SizedBox(height: 6),
        ],
      ],
    );
  }

  Widget _linea(LineaNumerofonia l) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.blanco,
          border: Border.all(color: AppColors.negro, width: 1.2),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Etiquetas 7 / 6
            Column(
              children: [
                _etiqueta('7'),
                Container(height: 1.2, color: AppColors.negro),
                _etiqueta('6'),
              ],
            ),
            // Celdas
            for (int i = 0; i < l.columnas; i++)
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                        color: AppColors.negro,
                        width: i == 0 ? 0 : 0.8),
                  ),
                ),
                child: Column(
                  children: [
                    _celda(l.fila7[i]),
                    Container(height: 1, color: AppColors.negro),
                    _celda(l.fila6[i]),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _etiqueta(String t) {
    return Container(
      width: 24 * escala,
      height: 30 * escala,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.blanco,
      ),
      child: Text(
        t,
        style: TextStyle(
          color: AppColors.negro,
          fontWeight: FontWeight.bold,
          fontSize: 13 * escala,
        ),
      ),
    );
  }

  Widget _celda(String contenido) {
    return Container(
      constraints: BoxConstraints(
        minWidth: 42 * escala,
        minHeight: 30 * escala,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 6 * escala,
        vertical: 4 * escala,
      ),
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: AppColors.blanco),
      child: Text(
        contenido,
        style: TextStyle(
          color: AppColors.negro,
          fontWeight: FontWeight.bold,
          fontSize: 13 * escala,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}