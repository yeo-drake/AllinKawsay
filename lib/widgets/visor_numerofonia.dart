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
        final anchoPantalla = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;

        // Altura total de todas las estrofas + separaciones
        const altoFila = 36.0; // alto de cada fila 7 y 6
        const separacion = 12.0;
        final altoTotal = validas.length * (altoFila * 2 + separacion) -
            separacion;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int i = 0; i < validas.length; i++) ...[
              _TablaAjustada(
                estrofa: validas[i],
                anchoDisponible: anchoPantalla,
                altoFila: altoFila * escala,
              ),
              if (i < validas.length - 1)
                SizedBox(height: separacion * escala),
            ],
          ],
        );
      },
    );
  }
}

class _TablaAjustada extends StatelessWidget {
  final EstrofaNumerofonia estrofa;
  final double anchoDisponible;
  final double altoFila;
  const _TablaAjustada({
    required this.estrofa,
    required this.anchoDisponible,
    required this.altoFila,
  });

  @override
  Widget build(BuildContext context) {
    // Ancho de la columna de etiquetas (7 y 6)
    final anchoEtiqueta = 28.0;

    // Ancho del bloque BIS al final
    final anchoBis = estrofa.bis ? 48.0 : 0.0;

    // Espacio restante para las columnas de números
    final espacioColumnas = anchoDisponible - anchoEtiqueta - anchoBis;

    // Ancho por columna (todas iguales)
    final numColumnas = estrofa.columnas;
    final anchoColumna =
        numColumnas > 0 ? espacioColumnas / numColumnas : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.blanco,
        border: Border.all(color: AppColors.negro, width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fila 7
          SizedBox(
            height: altoFila,
            child: Row(
              children: [
                _etiqueta('7', anchoEtiqueta),
                for (int i = 0; i < numColumnas; i++)
                  _celda(
                    contenido: estrofa.fila7[i],
                    ancho: anchoColumna,
                    esUltima: i == numColumnas - 1 && !estrofa.bis,
                  ),
                if (estrofa.bis)
                  _badgeBis(ancho: anchoBis, alto: altoFila * 2 + 1.5),
              ],
            ),
          ),
          Container(height: 1.5, color: AppColors.negro),
          // Fila 6
          SizedBox(
            height: altoFila,
            child: Row(
              children: [
                _etiqueta('6', anchoEtiqueta),
                for (int i = 0; i < numColumnas; i++)
                  _celda(
                    contenido: estrofa.fila6[i],
                    ancho: anchoColumna,
                    esUltima: i == numColumnas - 1 && !estrofa.bis,
                  ),
                if (estrofa.bis)
                  SizedBox(width: anchoBis, height: altoFila),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _etiqueta(String texto, double ancho) {
    return Container(
      width: ancho,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: AppColors.negro, width: 1.5),
        ),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: AppColors.negro,
          fontWeight: FontWeight.bold,
          fontSize: altoFila * 0.38,
        ),
      ),
    );
  }

  Widget _celda({
    required String contenido,
    required double ancho,
    required bool esUltima,
  }) {
    return Container(
      width: ancho,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: esUltima
            ? null
            : const Border(
                right: BorderSide(color: AppColors.negro, width: 1),
              ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            contenido,
            style: TextStyle(
              color: AppColors.negro,
              fontWeight: FontWeight.bold,
              fontSize: altoFila * 0.42,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ),
    );
  }

  Widget _badgeBis({required double ancho, required double alto}) {
    return Container(
      width: ancho,
      height: alto,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.dorado,
        border: Border(
          left: BorderSide(color: AppColors.negro, width: 1.5),
        ),
      ),
      child: Text(
        'BIS',
        style: TextStyle(
          color: AppColors.negro,
          fontWeight: FontWeight.bold,
          fontSize: altoFila * 0.32,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}