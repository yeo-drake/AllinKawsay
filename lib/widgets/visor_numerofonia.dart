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
    if (validas.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final s in validas) ...[
          _seccion(s),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _seccion(SeccionNumerofonia s) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.blanco,
        border: Border.all(color: AppColors.negro, width: 1.5),
      ),
      padding: const EdgeInsets.all(6 * 1.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'SECCIÓN ${s.nombre}',
            style: TextStyle(
              color: AppColors.granate,
              fontWeight: FontWeight.bold,
              fontSize: 10 * escala,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          for (int i = 0; i < s.lineas.length; i++) ...[
            _linea(s.lineas[i]),
            if (i < s.lineas.length - 1) const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }

  Widget _linea(LineaNumerofonia l) {
    if (l.vacia) return const SizedBox.shrink();
    final cols = l.columnas;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.negro, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _etiqueta('7'),
                for (int i = 0; i < cols; i++)
                  _celda(
                    i < l.fila7.length ? l.fila7[i] : '',
                    esUltima: i == cols - 1,
                  ),
              ],
            ),
            Row(
              children: [
                _etiqueta('6'),
                for (int i = 0; i < cols; i++)
                  _celda(
                    i < l.fila6.length ? l.fila6[i] : '',
                    esUltima: i == cols - 1,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _etiqueta(String t) {
    return Container(
      width: 22 * escala,
      padding: EdgeInsets.symmetric(vertical: 3 * escala),
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.blanco,
        border: Border(
          right: BorderSide(color: AppColors.negro, width: 1),
        ),
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

  Widget _celda(String contenido, {required bool esUltima}) {
    return Container(
      constraints: BoxConstraints(minWidth: 20 * escala),
      padding: EdgeInsets.symmetric(
        horizontal: 4 * escala,
        vertical: 3 * escala,
      ),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.blanco,
        border: esUltima
            ? null
            : const Border(
                right: BorderSide(color: AppColors.negro, width: 0.8),
              ),
      ),
      child: Text(
        contenido.isEmpty ? '' : contenido,
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