/// Una "estrofa" es UNA tabla chica (2 filas: 7 y 6).
/// Ejemplo real:
///   Fila 7: 6 6 6 5 56665 6
///   Fila 6: 6 5 6 5 4434 _ 5 6
class EstrofaNumerofonia {
  List<String> fila7;
  List<String> fila6;
  bool bis;

  EstrofaNumerofonia({
    List<String>? fila7,
    List<String>? fila6,
    this.bis = false,
  })  : fila7 = fila7 ?? [],
        fila6 = fila6 ?? [];

  bool get vacia => fila7.isEmpty && fila6.isEmpty;

  EstrofaNumerofonia copy() => EstrofaNumerofonia(
        fila7: List.from(fila7),
        fila6: List.from(fila6),
        bis: bis,
      );

  Map<String, dynamic> toMap() => {
        'fila7': fila7,
        'fila6': fila6,
        'bis': bis,
      };

  factory EstrofaNumerofonia.fromMap(Map<String, dynamic> m) {
    return EstrofaNumerofonia(
      fila7: List<String>.from(m['fila7'] ?? []),
      fila6: List<String>.from(m['fila6'] ?? []),
      bis: m['bis'] ?? false,
    );
  }

  /// Parsea "6 6 6 5 56665 6" → ["6","6","6","5","56665","6"]
  /// Acepta `_` o `.` como celda vacía.
  static List<String> parseFila(String input) {
    final partes = input.trim().split(RegExp(r'\s+'));
    final out = <String>[];
    for (final p in partes) {
      if (p.isEmpty) continue;
      if (p == '_' || p == '.' || p == '·') {
        out.add('');
      } else {
        out.add(p);
      }
    }
    return out;
  }

  /// ["6","6","6"] → "6 6 6"
  static String stringifyFila(List<String> fila) {
    return fila.map((c) => c.isEmpty ? '_' : c).join(' ');
  }
}