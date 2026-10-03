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
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < validas.length; i++) ...[
          _TablaEstrofa(estrofa: validas[i], escala: escala),
          if (i < validas.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _TablaEstrofa extends StatelessWidget {
  final EstrofaNumerofonia estrofa;
  final double escala;
  const _TablaEstrofa({required this.estrofa, required this.escala});

  // Medidas base
  static const double _altoFila = 30.0;
  static const double _anchoChar = 9.0;
  static const double _paddingCelda = 8.0;
  static const double _anchoMinCelda = 24.0;
  static const double _anchoBis = 44.0;

  @override
  Widget build(BuildContext context) {
    final numCols = estrofa.fila7.length > estrofa.fila6.length
        ? estrofa.fila7.length
        : estrofa.fila6.length;
    if (numCols == 0) return const SizedBox.shrink();

    // Ancho de cada columna = basado en el contenido más largo entre las 2 filas
    final anchos = <double>[];
    for (int i = 0; i < numCols; i++) {
      final v7 = i < estrofa.fila7.length ? estrofa.fila7[i] : '';
      final v6 = i < estrofa.fila6.length ? estrofa.fila6[i] : '';
      final len = v7.length > v6.length ? v7.length : v6.length;
      final ancho = len <= 1
          ? _anchoMinCelda
          : (len * _anchoChar + _paddingCelda).clamp(
              _anchoMinCelda, 90.0);
      anchos.add(ancho * escala);
    }

    final altoFila = _altoFila * escala;
    final anchoBis = _anchoBis * escala;
    final tieneBis = estrofa.bis;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.blanco,
        border: Border.all(color: AppColors.negro, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Columnas de datos (2 filas apiladas)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Fila 7
              SizedBox(
                height: altoFila,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < numCols; i++)
                      _celda(
                        contenido: i < estrofa.fila7.length
                            ? estrofa.fila7[i]
                            : '',
                        ancho: anchos[i],
                        alto: altoFila,
                        esUltima:
                            i == numCols - 1 && !tieneBis,
                      ),
                  ],
                ),
              ),
              Container(height: 1, color: AppColors.negro),
              // Fila 6
              SizedBox(
                height: altoFila,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < numCols; i++)
                      _celda(
                        contenido: i < estrofa.fila6.length
                            ? estrofa.fila6[i]
                            : '',
                        ancho: anchos[i],
                        alto: altoFila,
                        esUltima:
                            i == numCols - 1 && !tieneBis,
                      ),
                  ],
                ),
              ),
            ],
          ),
          // BIS
          if (tieneBis)
            Container(
              width: anchoBis,
              height: altoFila * 2 + 1,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.dorado,
                border: Border(
                  left: BorderSide(color: AppColors.negro, width: 1),
                ),
              ),
              child: Text(
                'BIS',
                style: TextStyle(
                  color: AppColors.negro,
                  fontWeight: FontWeight.bold,
                  fontSize: 10 * escala,
                  letterSpacing: 0.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _celda({
    required String contenido,
    required double ancho,
    required double alto,
    required bool esUltima,
  }) {
    return Container(
      width: ancho,
      height: alto,
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
        style: TextStyle(
          color: AppColors.negro,
          fontWeight: FontWeight.w500,
          fontSize: 13 * escala,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}