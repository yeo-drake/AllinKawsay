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
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.topLeft,
            child: _estrofa(validas[i]),
          ),
          if (i < validas.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _estrofa(EstrofaNumerofonia e) {
    // Calcular un ancho único de columna basado en el contenido más largo
    double anchoCol = 22.0;
    for (int i = 0; i < e.columnas; i++) {
      final len7 = e.fila7[i].length;
      final len6 = e.fila6[i].length;
      final maxLen = len7 > len6 ? len7 : len6;
      final ancho = maxLen == 0 ? 22.0 : (maxLen * 8.5 + 8.0);
      if (ancho > anchoCol) anchoCol = ancho;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.blanco,
        border: Border.all(color: AppColors.negro, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Etiquetas 7 / 6
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _etiqueta('7'),
              Container(height: 1.2, color: AppColors.negro),
              _etiqueta('6'),
            ],
          ),
          // Columnas
          for (int i = 0; i < e.columnas; i++)
            Container(
              width: anchoCol,
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: AppColors.negro, width: 1),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _celda(e.fila7[i]),
                  Container(height: 1, color: AppColors.negro),
                  _celda(e.fila6[i]),
                ],
              ),
            ),
          // BIS (integrado como otra columna)
          if (e.bis)
            Container(
              decoration: const BoxDecoration(
                color: AppColors.dorado,
                border: Border(
                  left: BorderSide(color: AppColors.negro, width: 1.2),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 6),
              alignment: Alignment.center,
              child: const Text(
                'BIS',
                style: TextStyle(
                  color: AppColors.negro,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 1,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _etiqueta(String t) {
    return Container(
      width: 20,
      height: 24,
      alignment: Alignment.center,
      child: Text(
        t,
        style: const TextStyle(
          color: AppColors.negro,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _celda(String contenido) {
    return Container(
      height: 24,
      alignment: Alignment.center,
      child: Text(
        contenido,
        style: const TextStyle(
          color: AppColors.negro,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}