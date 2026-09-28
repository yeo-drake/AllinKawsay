import 'package:cloud_firestore/cloud_firestore.dart';

class Evento {
  final String id;
  final String titulo;
  final String descripcion;
  final String lugar;
  final DateTime fecha;
  final String creadoPor;
  final String creadorNombre;

  Evento({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.lugar,
    required this.fecha,
    required this.creadoPor,
    required this.creadorNombre,
  });

  bool get esFuturo => fecha.isAfter(DateTime.now());

  factory Evento.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Evento(
      id: doc.id,
      titulo: d['titulo'] ?? '',
      descripcion: d['descripcion'] ?? '',
      lugar: d['lugar'] ?? '',
      fecha: (d['fecha'] as Timestamp?)?.toDate() ?? DateTime.now(),
      creadoPor: d['creadoPor'] ?? '',
      creadorNombre: d['creadorNombre'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'titulo': titulo,
        'descripcion': descripcion,
        'lugar': lugar,
        'fecha': Timestamp.fromDate(fecha),
        'creadoPor': creadoPor,
        'creadorNombre': creadorNombre,
      };
}