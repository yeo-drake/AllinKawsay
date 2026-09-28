import 'package:cloud_firestore/cloud_firestore.dart';

class Comentario {
  final String id;
  final String texto;
  final String autorUid;
  final String autorNombre;
  final DateTime? fecha;

  Comentario({
    required this.id,
    required this.texto,
    required this.autorUid,
    required this.autorNombre,
    this.fecha,
  });

  factory Comentario.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Comentario(
      id: doc.id,
      texto: d['texto'] ?? '',
      autorUid: d['autorUid'] ?? '',
      autorNombre: d['autorNombre'] ?? 'Anónimo',
      fecha: (d['fecha'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'texto': texto,
        'autorUid': autorUid,
        'autorNombre': autorNombre,
        'fecha': FieldValue.serverTimestamp(),
      };
}