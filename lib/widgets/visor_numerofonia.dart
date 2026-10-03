import 'package:flutter/material.dart';
import '../models/numerofonia.dart';
import '../theme/colors.dart';
import '../screens/numerofonia_fullscreen_screen.dart';

class VisorNumerofonia extends StatelessWidget {
  final List<EstrofaNumerofonia> estrofas;
  final double escala;
  final bool mostrarBotonExpandir;
  const VisorNumerofonia({
    super.key,
    required this.estrofas,
    this.escala = 1.0,
    this.mostrarBotonExpandir = true,
  });

  @override
  Widget build(BuildContext context) {
    final validas = estrofas.where((e) => !e.vacia).toList();
    if (validas.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header con botón expandir
        if (mostrarBotonExpandir)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.grid_on,
                    size: 14, color: AppColors.dorado),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Numerofonía',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.granate,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NumerofoniaFullscreenScreen(
                          estrofas: estrofas,
                        ),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.granate.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.granate.withOpacity(0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.zoom_out_map,
                              size: 14, color: AppColors.granate),
                          SizedBox(width: 4),
                          Text(
                            'Pantalla completa',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.granate,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        // Tablas
        for (int i = 0; i < validas.length; i++) ...[
          _TablaEstrofa(estrofa: validas[i], escala: escala),
          if (i < validas.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _TablaEstrofa extends StatelessWidget {
  final EstrofaNumerofonia estrofa;
  final double escala;
  const _TablaEstrofa({required this.estrofa, required this.escala});

  static const double _altoFila = 32.0;
  static const double _anchoEtiqueta = 24.0;
  static const double _anchoBis = 40.0;
  static const double _paddingCelda = 6.0;
  static const double _anchoCaracter = 8.5;

  @override
  Widget build(BuildContext context) {
    final numCols = estrofa.fila7.length > estrofa.fila6.length
        ? estrofa.fila7.length
        : estrofa.fila6.length;
    if (numCols == 0) return const SizedBox.shrink();

    // Calcular ancho de cada columna = max(fila7[i], fila6[i])
    final anchos = <double>[];
    for (int i = 0; i < numCols; i++) {
      final len7 = i < estrofa.fila7.length ? estrofa.fila7[i].length : 0;
      final len6 = i < estrofa.fila6.length ? estrofa.fila6[i].length : 0;
      final maxLen = len7 > len6 ? len7 : len6;
      // Ancho mínimo para un número + padding justo
      final ancho = maxLen == 0
          ? 20.0
          : (maxLen * _anchoCaracter + _paddingCelda * 2)
              .clamp(20.0, 80.0);
      anchos.add(ancho * escala);
    }

    final anchoEtiqueta = _anchoEtiqueta * escala;
    final anchoBis = _anchoBis * escala;
    final altoFila = _altoFila * escala;
    final tieneBis = estrofa.bis;

    final anchoNatural = anchoEtiqueta +
        anchos.fold<double>(0, (a, b) => a + b) +
        (tieneBis ? anchoBis : 0);

    // Auto-fit suave (mínimo 0.85 para que no se vea mal)
    return LayoutBuilder(
      builder: (context, constraints) {
        final anchoDisponible = constraints.maxWidth;
        final factor = anchoNatural > anchoDisponible
            ? (anchoDisponible / anchoNatural).clamp(0.7, 1.0)
            : 1.0;

        return SizedBox(
          width: anchoNatural * factor,
          child: Transform.scale(
            scale: factor,
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: anchoNatural,
              height: altoFila * 2 + 1.5,
              child: _tabla(
                anchos: anchos,
                anchoEtiqueta: anchoEtiqueta,
                anchoBis: anchoBis,
                altoFila: altoFila,
                numCols: numCols,
                tieneBis: tieneBis,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _tabla({
    required List<double> anchos,
    required double anchoEtiqueta,
    required double anchoBis,
    required double altoFila,
    required int numCols,
    required bool tieneBis,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.blanco,
        border: Border.all(color: AppColors.negro, width: 1.2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: altoFila,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _etiqueta('7', anchoEtiqueta, altoFila),
                for (int i = 0; i < numCols; i++)
                  _celda(
                    contenido:
                        i < estrofa.fila7.length ? estrofa.fila7[i] : '',
                    ancho: anchos[i],
                    alto: altoFila,
                    esUltima: i == numCols - 1 && !tieneBis,
                  ),
                if (tieneBis)
                  _celdaBis(anchoBis, altoFila * 2 + 1.2),
              ],
            ),
          ),
          Container(height: 1.2, color: AppColors.negro),
          SizedBox(
            height: altoFila,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _etiqueta('6', anchoEtiqueta, altoFila),
                for (int i = 0; i < numCols; i++)
                  _celda(
                    contenido:
                        i < estrofa.fila6.length ? estrofa.fila6[i] : '',
                    ancho: anchos[i],
                    alto: altoFila,
                    esUltima: i == numCols - 1 && !tieneBis,
                  ),
                if (tieneBis)
                  SizedBox(width: anchoBis, height: altoFila),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _etiqueta(String t, double ancho, double alto) {
    return Container(
      width: ancho,
      height: alto,
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
          fontSize: 13 * escala,
        ),
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
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.negro,
          fontWeight: FontWeight.bold,
          fontSize: 13 * escala,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  Widget _celdaBis(double ancho, double alto) {
    return Container(
      width: ancho,
      height: alto,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.dorado,
        border: Border(
          left: BorderSide(color: AppColors.negro, width: 1.2),
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