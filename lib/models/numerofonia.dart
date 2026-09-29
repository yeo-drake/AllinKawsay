class SeccionNumerofonia {
  String nombre;
  bool conBis;
  List<String> fila7;
  List<String> fila6;

  SeccionNumerofonia({
    required this.nombre,
    this.conBis = true,
    List<String>? fila7,
    List<String>? fila6,
  })  : fila7 = fila7 ?? [],
        fila6 = fila6 ?? [];

  int get columnas {
    final l7 = fila7.length;
    final l6 = fila6.length;
    return l7 > l6 ? l7 : l6;
  }

  bool get vacia => fila7.isEmpty && fila6.isEmpty;

  SeccionNumerofonia copy() => SeccionNumerofonia(
        nombre: nombre,
        conBis: conBis,
        fila7: List.from(fila7),
        fila6: List.from(fila6),
      );

  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'conBis': conBis,
        'fila7': fila7,
        'fila6': fila6,
      };

  factory SeccionNumerofonia.fromMap(Map<String, dynamic> m) =>
      SeccionNumerofonia(
        nombre: m['nombre']?.toString() ?? 'A',
        conBis: m['conBis'] ?? true,
        fila7: List<String>.from(m['fila7'] ?? []),
        fila6: List<String>.from(m['fila6'] ?? []),
      );

  /// Parsea un string tipo "4 3 3 _ _ 5 6" en lista de celdas
  static List<String> parseFila(String input) {
    final partes = input.trim().split(RegExp(r'\s+'));
    final resultado = <String>[];
    for (final p in partes) {
      if (p.isEmpty) continue;
      if (p == '_' || p == '.' || p == '-' || p == '·') {
        resultado.add('');
      } else {
        resultado.add(p);
      }
    }
    return resultado;
  }

  /// Convierte lista de celdas en string para editar
  static String stringifyFila(List<String> fila) {
    return fila.map((c) => c.isEmpty ? '_' : c).join(' ');
  }
}