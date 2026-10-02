import 'package:cloud_firestore/cloud_firestore.dart';

class Categoria {
  final String id;
  final String nombre;
  final String emoji; // Un emoji o símbolo para mostrar
  final int orden;

  Categoria({
    required this.id,
    required this.nombre,
    this.emoji = '📁',
    this.orden = 0,
  });

  factory Categoria.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Categoria(
      id: doc.id,
      nombre: d['nombre'] ?? '',
      emoji: d['emoji'] ?? '📁',
      orden: (d['orden'] is int) ? d['orden'] : 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'emoji': emoji,
        'orden': orden,
      };
}