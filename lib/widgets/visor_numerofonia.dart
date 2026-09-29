import 'package:flutter/material.dart';
import '../models/numerofonia.dart';
import '../theme/colors.dart';

class VisorNumerofonia extends StatelessWidget {
  final List<SeccionNumerofonia> secciones;
  final double escala;
  const VisorNumerofonia({
    super.key,
    required this.secciones,
    this.escala = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final validas = secciones.where((s) => !s.vacia).toList();
    if (validas.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final s in validas) ...[
          _seccion(s),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _seccion(SeccionNumerofonia s) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.negro,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dorado, width: 1.5),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.granate,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'SECCIÓN ${s.nombre}',
                  style: TextStyle(
                    color: AppColors.dorado,
                    fontWeight: FontWeight.bold,
                    fontSize: 12 * escala,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const Spacer(),
              if (s.conBis)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.dorado,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.repeat,
                          size: 14 * escala, color: AppColors.negro),
                      const SizedBox(width: 4),
                      Text(
                        'BIS',
                        style: TextStyle(
                          color: AppColors.negro,
                          fontWeight: FontWeight.bold,
                          fontSize: 12 * escala,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          // Tabla
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _tabla(s),
          ),
        ],
      ),
    );
  }

  Widget _tabla(SeccionNumerofonia s) {
    final cols = s.columnas;
    final cellW = 38.0 * escala;
    final cellH = 34.0 * escala;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Etiqueta "7"
        Column(
          children: [
            _etiqueta('7', cellW, cellH),
            const SizedBox(height: 2),
            _etiqueta('6', cellW, cellH),
          ],
        ),
        const SizedBox(width: 6),
        // Celdas
        for (int i = 0; i < cols; i++) ...[
          Column(
            children: [
              _celda(
                i < s.fila7.length ? s.fila7[i] : '',
                cellW,
                cellH,
              ),
              const SizedBox(height: 2),
              _celda(
                i < s.fila6.length ? s.fila6[i] : '',
                cellW,
                cellH,
              ),
            ],
          ),
          const SizedBox(width: 2),
        ],
      ],
    );
  }

  Widget _etiqueta(String texto, double w, double h) {
    return Container(
      width: w,
      height: h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.granate,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: AppColors.dorado,
          fontWeight: FontWeight.bold,
          fontSize: 16 * escala,
        ),
      ),
    );
  }

  Widget _celda(String contenido, double w, double h) {
    final vacia = contenido.isEmpty;
    return Container(
      width: w,
      height: h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: vacia ? AppColors.negro : Colors.black,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: vacia
              ? AppColors.dorado.withOpacity(0.3)
              : AppColors.dorado,
          width: 1,
        ),
      ),
      child: Text(
        contenido,
        style: TextStyle(
          color: AppColors.dorado,
          fontWeight: FontWeight.bold,
          fontSize: 14 * escala,
        ),
      ),
    );
  }
}