/// Una línea de compás: par de filas (7 arriba, 6 abajo).
/// fila7 y fila6 SIEMPRE tienen la misma longitud (una celda por columna).
class LineaNumerofonia {
  List<String> fila7;
  List<String> fila6;

  LineaNumerofonia({
    List<String>? fila7,
    List<String>? fila6,
  })  : fila7 = fila7 ?? [],
        fila6 = fila6 ?? [];

  int get columnas => fila7.length;

  bool get vacia => fila7.every((c) => c.isEmpty);

  /// Inserta una columna (celda vacía en 7 y 6) en la posición [pos].
  void insertarColumna(int pos) {
    final p = pos.clamp(0, fila7.length);
    fila7.insert(p, '');
    fila6.insert(p, '');
  }

  /// Elimina la columna en [index].
  void eliminarColumna(int index) {
    if (index < 0 || index >= fila7.length) return;
    fila7.removeAt(index);
    if (index < fila6.length) fila6.removeAt(index);
  }

  LineaNumerofonia copy() => LineaNumerofonia(
        fila7: List.from(fila7),
        fila6: List.from(fila6),
      );

  Map<String, dynamic> toMap() => {
        'fila7': fila7,
        'fila6': fila6,
      };

  factory LineaNumerofonia.fromMap(Map<String, dynamic> m) {
    final f7 = List<String>.from(m['fila7'] ?? []);
    final f6 = List<String>.from(m['fila6'] ?? []);
    // Normalizar: que ambas filas tengan el mismo largo
    final max = f7.length > f6.length ? f7.length : f6.length;
    while (f7.length < max) f7.add('');
    while (f6.length < max) f6.add('');
    return LineaNumerofonia(fila7: f7, fila6: f6);
  }
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