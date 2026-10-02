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

    // FittedBox escala el contenido hacia abajo si no entra.
    // Si entra, se muestra a tamaño natural.
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.topLeft,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < validas.length; i++) ...[
            _estrofa(validas[i]),
            if (i < validas.length - 1) SizedBox(height: 6 * escala),
          ],
        ],
      ),
    );
  }

  Widget _estrofa(EstrofaNumerofonia e) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.blanco,
        border: Border.all(color: AppColors.negro, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Etiquetas 7 / 6
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _etiqueta('7'),
              Container(height: 1, color: AppColors.negro),
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
                mainAxisSize: MainAxisSize.min,
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
                  horizontal: 6 * escala, vertical: 3 * escala),
              decoration: BoxDecoration(
                color: AppColors.dorado,
                border: const Border(
                  left: BorderSide(color: AppColors.negro, width: 1),
                ),
              ),
              child: Text(
                'BIS',
                style: TextStyle(
                  color: AppColors.negro,
                  fontWeight: FontWeight.bold,
                  fontSize: 11 * escala,
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
      width: 20 * escala,
      height: 26 * escala,
      alignment: Alignment.center,
      child: Text(
        t,
        style: TextStyle(
          color: AppColors.negro,
          fontWeight: FontWeight.bold,
          fontSize: 12 * escala,
        ),
      ),
    );
  }

  Widget _celda(String contenido) {
    final ancho = contenido.isEmpty
        ? 24.0 * escala
        : (contenido.length * 8.5 + 10.0) * escala;

    return Container(
      width: ancho,
      height: 26 * escala,
      alignment: Alignment.center,
      child: Text(
        contenido,
        style: TextStyle(
          color: AppColors.negro,
          fontWeight: FontWeight.bold,
          fontSize: 12 * escala,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}