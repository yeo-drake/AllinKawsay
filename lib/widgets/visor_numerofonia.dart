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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.blanco,
        border: Border.all(color: AppColors.negro, width: 1.2),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
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