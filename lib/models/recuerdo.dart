import 'package:cloud_firestore/cloud_firestore.dart';

class Recuerdo {
  final String id;
  final String titulo;
  final String descripcion;
  final List<String> fotos;
  final DateTime? fecha;
  final String creadoPor;
  final String creadorNombre;

  Recuerdo({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.fotos,
    this.fecha,
    required this.creadoPor,
    required this.creadorNombre,
  });

  factory Recuerdo.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Recuerdo(
      id: doc.id,
      titulo: d['titulo'] ?? '',
      descripcion: d['descripcion'] ?? '',
      fotos: List<String>.from(d['fotos'] ?? []),
      fecha: (d['fecha'] as Timestamp?)?.toDate(),
      creadoPor: d['creadoPor'] ?? '',
      creadorNombre: d['creadorNombre'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'titulo': titulo,
        'descripcion': descripcion,
        'fotos': fotos,
        'fecha': FieldValue.serverTimestamp(),
        'creadoPor': creadoPor,
        'creadorNombre': creadorNombre,
      };
}