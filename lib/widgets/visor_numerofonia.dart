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
          _EstrofaVisor(estrofa: validas[i], escala: escala),
          if (i < validas.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _EstrofaVisor extends StatelessWidget {
  final EstrofaNumerofonia estrofa;
  final double escala;
  const _EstrofaVisor({required this.estrofa, required this.escala});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const etiquetaW = 22.0;
        final bisW = estrofa.bis ? 44.0 : 0.0;
        final disponible = constraints.maxWidth - etiquetaW - bisW;
        final cols = estrofa.columnas;
        final anchoCol = cols > 0 ? disponible / cols : 0.0;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.blanco,
            border: Border.all(color: AppColors.negro, width: 1.2),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Etiquetas
              SizedBox(
                width: etiquetaW,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _etiqueta('7'),
                    Container(height: 1.2, color: AppColors.negro),
                    _etiqueta('6'),
                  ],
                ),
              ),
              // Columnas
              for (int i = 0; i < cols; i++)
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
                      _celda(estrofa.fila7[i]),
                      Container(height: 1, color: AppColors.negro),
                      _celda(estrofa.fila6[i]),
                    ],
                  ),
                ),
              // BIS
              if (estrofa.bis)
                Container(
                  width: bisW,
                  decoration: const BoxDecoration(
                    color: AppColors.dorado,
                    border: Border(
                      left: BorderSide(color: AppColors.negro, width: 1.2),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'BIS',
                    style: TextStyle(
                      color: AppColors.negro,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _etiqueta(String t) {
    return Container(
      height: 26,
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
      height: 26,
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            contenido,
            style: const TextStyle(
              color: AppColors.negro,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ),
    );
  }
}