/// Una estrofa = una línea de numerofonía con números y direcciones.
/// Formato: "4 4 3 4 / 5 5 6 5 \ 3 3 2 3"
///   - Empieza en hilera 6
///   - "/" = los siguientes van en hilera 7
///   - "\" = los siguientes vuelven a hilera 6
class EstrofaNumerofonia {
  String texto;
  bool bis;

  EstrofaNumerofonia({
    this.texto = '',
    this.bis = false,
  });

  bool get vacia => texto.trim().isEmpty;

  EstrofaNumerofonia copy() => EstrofaNumerofonia(
        texto: texto,
        bis: bis,
      );

  Map<String, dynamic> toMap() => {
        'texto': texto,
        'bis': bis,
      };

  factory EstrofaNumerofonia.fromMap(Map<String, dynamic> m) {
    // Compatibilidad con formato viejo (fila7/fila6)
    if (m['fila7'] != null || m['fila6'] != null) {
      final f7 = List<String>.from(m['fila7'] ?? []);
      final f6 = List<String>.from(m['fila6'] ?? []);
      final sb = StringBuffer();
      for (int i = 0; i < f6.length; i++) {
        sb.write('${f6[i]} ');
      }
      if (f7.isNotEmpty) {
        sb.write('/ ');
        for (int i = 0; i < f7.length; i++) {
          sb.write('${f7[i]} ');
        }
      }
      return EstrofaNumerofonia(
        texto: sb.toString().trim(),
        bis: m['bis'] ?? false,
      );
    }
    return EstrofaNumerofonia(
      texto: m['texto'] ?? '',
      bis: m['bis'] ?? false,
    );
  }
}