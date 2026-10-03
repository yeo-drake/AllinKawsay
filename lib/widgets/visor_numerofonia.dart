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
          if (i < validas.length - 1) SizedBox(height: 14 * escala),
        ],
      ],
    );
  }
}

/// Un "segmento" = conjunto de números entre 2 direcciones.
class _Segmento {
  final List<String> numeros;
  final int hilera; // 6 o 7
  _Segmento({required this.numeros, required this.hilera});
}

class _EstrofaVisor extends StatelessWidget {
  final EstrofaNumerofonia estrofa;
  final double escala;
  const _EstrofaVisor({required this.estrofa, required this.escala});

  /// Parsea el texto en segmentos + guarda las direcciones entre ellos.
  /// Devuelve una lista donde cada item es Segmento o String ("/", "\").
  List<dynamic> _parsear(String texto) {
    final tokens = texto.trim().split(RegExp(r'\s+'));
    final items = <dynamic>[];
    List<String> bufferNumeros = [];
    int hileraActual = 6;

    void cerrarSegmento() {
      if (bufferNumeros.isNotEmpty) {
        items.add(_Segmento(
          numeros: List.from(bufferNumeros),
          hilera: hileraActual,
        ));
        bufferNumeros.clear();
      }
    }

    for (final t in tokens) {
      if (t == '/' || t == '\\') {
        cerrarSegmento();
        items.add(t);
        hileraActual = (t == '/') ? 7 : 6;
      } else {
        bufferNumeros.add(t);
      }
    }
    cerrarSegmento();
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final items = _parsear(estrofa.texto);
    if (items.isEmpty) return const SizedBox.shrink();

    final altoFila = 34.0 * escala;
    final altoTotal = altoFila * 2 + 8 * escala; // 2 filas + separador

    final children = <Widget>[];
    for (final item in items) {
      if (item is _Segmento) {
        children.add(_cajitasSegmento(item, altoFila, altoTotal));
      } else if (item is String) {
        children.add(_diagonal(item, altoFila, altoTotal));
      }
    }

    // BIS al final
    if (estrofa.bis) {
      children.add(_bis(altoTotal));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }

  Widget _cajitasSegmento(_Segmento seg, double altoFila, double altoTotal) {
    return SizedBox(
      height: altoTotal,
      child: Align(
        alignment: seg.hilera == 7
            ? Alignment.topCenter
            : Alignment.bottomCenter,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final n in seg.numeros)
              Container(
                margin: EdgeInsets.symmetric(horizontal: 2 * escala),
                padding: EdgeInsets.symmetric(
                    horizontal: 8 * escala, vertical: 6 * escala),
                constraints: BoxConstraints(
                  minWidth: 26 * escala,
                  minHeight: altoFila,
                ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.blanco,
                  borderRadius: BorderRadius.circular(6 * escala),
                  border: Border.all(
                      color: AppColors.negro, width: 1.2),
                ),
                child: Text(
                  n,
                  style: TextStyle(
                    color: AppColors.negro,
                    fontWeight: FontWeight.bold,
                    fontSize: 14 * escala,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _diagonal(String dir, double altoFila, double altoTotal) {
    return SizedBox(
      width: 26 * escala,
      height: altoTotal,
      child: Center(
        child: Text(
          dir == '/' ? '/' : '\\',
          style: TextStyle(
            color: AppColors.granate,
            fontWeight: FontWeight.bold,
            fontSize: 32 * escala,
            height: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _bis(double altoTotal) {
    return Container(
      margin: EdgeInsets.only(left: 10 * escala),
      padding: EdgeInsets.symmetric(
          horizontal: 10 * escala, vertical: 8 * escala),
      decoration: BoxDecoration(
        color: AppColors.dorado,
        borderRadius: BorderRadius.circular(6 * escala),
        border: Border.all(color: AppColors.negro, width: 1.2),
      ),
      child: Text(
        'BIS',
        style: TextStyle(
          color: AppColors.negro,
          fontWeight: FontWeight.bold,
          fontSize: 11 * escala,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}