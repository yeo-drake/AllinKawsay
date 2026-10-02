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

    return LayoutBuilder(
      builder: (context, constraints) {
        // Medida natural de las celdas
        const cellW = 26.0;
        const etiquetaW = 20.0;

        // Ancho máximo natural (sin escalar)
        double anchoMax = 0;
        for (final e in validas) {
          double ancho = etiquetaW;
          for (int i = 0; i < e.columnas; i++) {
            final v7 = e.fila7[i];
            final v6 = e.fila6[i];
            final len = v7.length > v6.length ? v7.length : v6.length;
            ancho += len == 0 ? cellW : (len * 8.5 + 10.0);
          }
          if (e.bis) ancho += 40;
          if (ancho > anchoMax) anchoMax = ancho;
        }

        final disponible = constraints.maxWidth;
        final factor = (disponible / anchoMax).clamp(0.0, 1.0);

        return Transform.scale(
          scale: factor,
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: anchoMax,
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
          ),
        );
      },
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
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _etiqueta('7'),
              Container(height: 1, color: AppColors.negro),
              _etiqueta('6'),
            ],
          ),
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