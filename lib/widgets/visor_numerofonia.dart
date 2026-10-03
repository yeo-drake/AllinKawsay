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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _EstrofaVisor(
              estrofa: validas[i],
              escala: escala,
            ),
          ),
          if (i < validas.length - 1) SizedBox(height: 18 * escala),
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
    final alto = 28.0 * escala;
    final anchoSlot = 30.0 * escala;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (final e in estrofa.eventos)
          SizedBox(
            width: anchoSlot,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Arriba (hilera 7)
                SizedBox(
                  height: alto,
                  child: e.tipo == TipoEvento.nota7
                      ? Center(child: _textoNota(e.valor))
                      : const SizedBox.shrink(),
                ),
                // Medio (dirección)
                SizedBox(
                  height: alto,
                  child: e.tipo == TipoEvento.direccion
                      ? Center(child: _textoDir(e.valor))
                      : const SizedBox.shrink(),
                ),
                // Abajo (hilera 6)
                SizedBox(
                  height: alto,
                  child: e.tipo == TipoEvento.nota6
                      ? Center(child: _textoNota(e.valor))
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        if (estrofa.bis)
          Padding(
            padding: EdgeInsets.only(left: 14 * escala),
            child: Text(
              'BIS',
              style: TextStyle(
                color: AppColors.granate,
                fontWeight: FontWeight.bold,
                fontSize: 13 * escala,
                letterSpacing: 1,
              ),
            ),
          ),
      ],
    );
  }

  Widget _textoNota(String valor) {
    return Text(
      valor,
      style: TextStyle(
        color: AppColors.negro,
        fontWeight: FontWeight.bold,
        fontSize: 16 * escala,
        fontFamily: 'monospace',
        height: 1.0,
      ),
    );
  }

  Widget _textoDir(String valor) {
    return Text(
      valor,
      style: TextStyle(
        color: AppColors.granate,
        fontWeight: FontWeight.w300,
        fontSize: 24 * escala,
        height: 1.0,
      ),
    );
  }
}