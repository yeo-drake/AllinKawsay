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

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < validas.length; i++) ...[
              _TablaEstrofa(
                estrofa: validas[i],
                anchoMaximo: anchoPantalla,
                escala: escala,
              ),
              if (i < validas.length - 1) const SizedBox(height: 10),
            ],
          ],
        );
      },
    );
  }
}

class _TablaEstrofa extends StatelessWidget {
  final EstrofaNumerofonia estrofa;
  final double anchoMaximo;
  final double escala;
  const _TablaEstrofa({
    required this.estrofa,
    required this.anchoMaximo,
    required this.escala,
  });

  static const double _altoFila = 32.0;
  static const double _anchoEtiqueta = 24.0;
  static const double _anchoBis = 40.0;
  static const double _anchoMinimoCol = 26.0;

  @override
  Widget build(BuildContext context) {
    // Número total de columnas = máximo entre fila7 y fila6
    final numCols = estrofa.fila7.length > estrofa.fila6.length
        ? estrofa.fila7.length
        : estrofa.fila6.length;

    if (numCols == 0) return const SizedBox.shrink();

    final tieneBis = estrofa.bis;

    // Calcular ancho de cada columna = el máximo entre fila7[i] y fila6[i]
    final anchos = <double>[];
    for (int i = 0; i < numCols; i++) {
      final len7 = i < estrofa.fila7.length ? estrofa.fila7[i].length : 0;
      final len6 = i < estrofa.fila6.length ? estrofa.fila6[i].length : 0;
      final maxLen = len7 > len6 ? len7 : len6;
      // Ancho en píxeles: mínimo 26 + 9 por carácter
      final ancho = maxLen <= 1
          ? _anchoMinimoCol
          : _anchoMinimoCol + (maxLen - 1) * 9.0;
      anchos.add(ancho);
    }

    final anchoTablaBase = _anchoEtiqueta +
        anchos.fold<double>(0, (a, b) => a + b) +
        (tieneBis ? _anchoBis : 0);

    // Factor de escala si la tabla es más ancha que la pantalla
    final factor =
        anchoTablaBase > anchoMaximo ? anchoMaximo / anchoTablaBase : 1.0;

    final altoTotal = _altoFila * 2 + 1.5;

    return SizedBox(
      width: anchoTablaBase * factor,
      height: altoTotal * factor,
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: anchoTablaBase,
          height: altoTotal,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.blanco,
              border: Border.all(color: AppColors.negro, width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // === Fila 7 ===
                SizedBox(
                  height: _altoFila,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _celdaEtiqueta('7'),
                      for (int i = 0; i < numCols; i++)
                        _celda(
                          contenido: i < estrofa.fila7.length
                              ? estrofa.fila7[i]
                              : '',
                          ancho: anchos[i],
                          esUltima: i == numCols - 1 && !tieneBis,
                        ),
                      if (tieneBis)
                        _celdaBis(alto: _altoFila * 2 + 1.5),
                    ],
                  ),
                ),
                // === Divisor ===
                Container(height: 1.5, color: AppColors.negro),
                // === Fila 6 ===
                SizedBox(
                  height: _altoFila,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _celdaEtiqueta('6'),
                      for (int i = 0; i < numCols; i++)
                        _celda(
                          contenido: i < estrofa.fila6.length
                              ? estrofa.fila6[i]
                              : '',
                          ancho: anchos[i],
                          esUltima: i == numCols - 1 && !tieneBis,
                        ),
                      if (tieneBis)
                        SizedBox(width: _anchoBis, height: _altoFila),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _celdaEtiqueta(String t) {
    return Container(
      width: _anchoEtiqueta,
      height: _altoFila,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: AppColors.negro, width: 1.5),
        ),
      ),
      child: Text(
        t,
        style: const TextStyle(
          color: AppColors.negro,
          fontWeight: FontWeight.bold,
          fontSize: 14,
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
      height: _altoFila,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: esUltima
            ? null
            : const Border(
                right: BorderSide(color: AppColors.negro, width: 1),
              ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Text(
          contenido,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.negro,
            fontWeight: FontWeight.bold,
            fontSize: 13,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }

  Widget _celdaBis({required double alto}) {
    return Container(
      width: _anchoBis,
      height: alto,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.dorado,
        border: Border(
          left: BorderSide(color: AppColors.negro, width: 1.5),
        ),
      ),
      child: const Text(
        'BIS',
        style: TextStyle(
          color: AppColors.negro,
          fontWeight: FontWeight.bold,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}