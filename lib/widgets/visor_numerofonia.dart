import 'package:flutter/material.dart';
import '../models/numerofonia.dart';
import '../theme/colors.dart';

class VisorNumerofonia extends StatelessWidget {
  final List<EstrofaNumerofonia> estrofas;
  final double escala;
  const VisorNumerofonia({
    super.key,
    required this.estrofas,
    this.escala = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final validas = estrofas.where((e) => !e.vacia).toList();
    if (validas.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < validas.length; i++) ...[
          _estrofa(validas[i]),
          if (i < validas.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _estrofa(EstrofaNumerofonia e) {
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
            // Etiquetas 7 / 6
            Column(
              children: [
                _etiqueta('7'),
                Container(height: 1.2, color: AppColors.negro),
                _etiqueta('6'),
              ],
            ),
            // Celdas
            for (int i = 0; i < e.columnas; i++)
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: AppColors.negro, width: 1),
                  ),
                ),
                child: Column(
                  children: [
                    _celda(e.fila7[i]),
                    Container(height: 1, color: AppColors.negro),
                    _celda(e.fila6[i]),
                  ],
                ),
              ),
            // BIS badge
            if (e.bis)
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 8 * escala, vertical: 4 * escala),
                decoration: BoxDecoration(
                  color: AppColors.dorado,
                  border: const Border(
                    left: BorderSide(color: AppColors.negro, width: 1.2),
                  ),
                ),
                child: Text(
                  'BIS',
                  style: TextStyle(
                    color: AppColors.negro,
                    fontWeight: FontWeight.bold,
                    fontSize: 13 * escala,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _etiqueta(String t) {
    return Container(
      width: 26 * escala,
      height: 30 * escala,
      alignment: Alignment.center,
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
    final ancho = contenido.isEmpty
        ? 44.0 * escala
        : (contenido.length * 10.0 + 22.0) * escala;

    return Container(
      width: ancho,
      height: 30 * escala,
      alignment: Alignment.center,
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