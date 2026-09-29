class LineaNumerofonia {
  List<String> fila7;
  List<String> fila6;

  LineaNumerofonia({
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

  LineaNumerofonia copy() => LineaNumerofonia(
        fila7: List.from(fila7),
        fila6: List.from(fila6),
      );

  Map<String, dynamic> toMap() => {
        'fila7': fila7,
        'fila6': fila6,
      };

  factory LineaNumerofonia.fromMap(Map<String, dynamic> m) =>
      LineaNumerofonia(
        fila7: List<String>.from(m['fila7'] ?? []),
        fila6: List<String>.from(m['fila6'] ?? []),
      );
}

class SeccionNumerofonia {
  String nombre;
  List<LineaNumerofonia> lineas;

  SeccionNumerofonia({
    required this.nombre,
    List<LineaNumerofonia>? lineas,
  }) : lineas = lineas ?? [LineaNumerofonia()];

  bool get vacia => lineas.every((l) => l.vacia);

  SeccionNumerofonia copy() => SeccionNumerofonia(
        nombre: nombre,
        lineas: lineas.map((l) => l.copy()).toList(),
      );

  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'lineas': lineas.map((l) => l.toMap()).toList(),
      };

  factory SeccionNumerofonia.fromMap(Map<String, dynamic> m) {
    final lineasList = (m['lineas'] as List?)
            ?.map((x) =>
                LineaNumerofonia.fromMap(Map<String, dynamic>.from(x)))
            .toList() ??
        <LineaNumerofonia>[];
    return SeccionNumerofonia(
      nombre: m['nombre']?.toString() ?? 'A',
      lineas: lineasList.isEmpty ? [LineaNumerofonia()] : lineasList,
    );
  }
}