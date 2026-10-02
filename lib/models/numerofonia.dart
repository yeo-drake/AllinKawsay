class EstrofaNumerofonia {
  List<String> fila7;
  List<String> fila6;
  bool bis;

  EstrofaNumerofonia({
    List<String>? fila7,
    List<String>? fila6,
    this.bis = false,
  })  : fila7 = (fila7 == null || fila7.isEmpty) ? [''] : fila7,
        fila6 = (fila6 == null || fila6.isEmpty) ? [''] : fila6 {
    final max = this.fila7.length > this.fila6.length
        ? this.fila7.length
        : this.fila6.length;
    while (this.fila7.length < max) this.fila7.add('');
    while (this.fila6.length < max) this.fila6.add('');
  }

  int get columnas => fila7.length;
  bool get vacia => fila7.every((c) => c.isEmpty);

  void agregarColumna() {
    fila7.add('');
    fila6.add('');
  }

  void eliminarColumna(int index) {
    if (fila7.length <= 1) return;
    if (index < 0 || index >= fila7.length) return;
    fila7.removeAt(index);
    fila6.removeAt(index);
  }

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
}