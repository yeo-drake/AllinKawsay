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
        // Calcular dimensiones naturales de la tabla
        final dims = _calcularDimensiones(validas);

        // Ancho disponible (si es infinito, usar el de la pantalla)
        final disponible = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;

        // Factor de escala: si la tabla es más ancha que el espacio,
        // se achica proporcionalmente. Si cabe, queda al tamaño natural.
        final factor =
            dims.ancho > disponible ? disponible / dims.ancho : 1.0;

        return SizedBox(
          width: dims.ancho * factor,
          height: dims.alto * factor,
          child: Transform.scale(
            scale: factor,
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: dims.ancho,
              height: dims.alto,
              child: _construirTablas(validas),
            ),
          ),
        );
      },
    );
  }

  Widget _construirTablas(List<EstrofaNumerofonia> validas) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < validas.length; i++) ...[
          _EstrofaTabla(estrofa: validas[i], escala: escala),
          if (i < validas.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }

  _Dimensiones _calcularDimensiones(List<EstrofaNumerofonia> validas) {
    double anchoMax = 0;
    double altoTotal = 0;

    for (final e in validas) {
      // Ancho: etiqueta + celdas + BIS
      double ancho = 22 * escala;
      for (int i = 0; i < e.columnas; i++) {
        final len7 = e.fila7[i].length;
        final len6 = e.fila6[i].length;
        final maxLen = len7 > len6 ? len7 : len6;
        final anchoCol = maxLen == 0
            ? 34 * escala
            : ((maxLen * 8.5) + 14.0).clamp(34.0, 130.0) * escala;
        ancho += anchoCol;
      }
      if (e.bis) ancho += 44 * escala;
      if (ancho > anchoMax) anchoMax = ancho;

      // Alto: 2 filas de 26 + borde divisorio 1.2
      altoTotal += (26 * 2 + 1.2) * escala + 8;
    }
    // Quitar el último separador
    if (altoTotal > 0) altoTotal -= 8;

    return _Dimensiones(ancho: anchoMax, alto: altoTotal);
  }
}

class _Dimensiones {
  final double ancho;
  final double alto;
  _Dimensiones({required this.ancho, required this.alto});
}

class _EstrofaTabla extends StatelessWidget {
  final EstrofaNumerofonia estrofa;
  final double escala;
  const _EstrofaTabla({required this.estrofa, required this.escala});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.blanco,
        border: Border.all(color: AppColors.negro, width: 1.2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 26 * escala,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _etiqueta('7'),
                for (int i = 0; i < estrofa.columnas; i++)
                  _celda(estrofa.fila7[i]),
                if (estrofa.bis) _bisBadge(),
              ],
            ),
          ),
          Container(height: 1.2, color: AppColors.negro),
          SizedBox(
            height: 26 * escala,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _etiqueta('6'),
                for (int i = 0; i < estrofa.columnas; i++)
                  _celda(estrofa.fila6[i]),
                if (estrofa.bis)
                  SizedBox(width: 44 * escala, height: 26 * escala),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _etiqueta(String t) {
    return Container(
      width: 22 * escala,
      height: 26 * escala,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: AppColors.negro, width: 1.2),
        ),
      ),
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
        ? 34.0 * escala
        : ((contenido.length * 8.5) + 14.0).clamp(34.0, 130.0) * escala;

    return Container(
      width: ancho,
      height: 26 * escala,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: AppColors.negro, width: 0.8),
        ),
      ),
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

  Widget _bisBadge() {
    return Container(
      width: 44 * escala,
      height: 52 * escala,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.dorado,
        border: Border(
          right: BorderSide(color: AppColors.negro, width: 1.2),
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
    );
  }
}