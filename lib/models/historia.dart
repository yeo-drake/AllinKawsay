import 'package:cloud_firestore/cloud_firestore.dart';

class Historia {
  final String contenido;
  final String actualizadoPor;
  final DateTime? fechaActualizacion;

  Historia({
    required this.contenido,
    required this.actualizadoPor,
    this.fechaActualizacion,
  });

  factory Historia.fromDoc(DocumentSnapshot doc) {
    if (!doc.exists) {
      return Historia(contenido: '', actualizadoPor: '');
    }
    final d = doc.data() as Map<String, dynamic>;
    return Historia(
      contenido: d['contenido'] ?? '',
      actualizadoPor: d['actualizadoPor'] ?? '',
      fechaActualizacion: (d['fechaActualizacion'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'contenido': contenido,
        'actualizadoPor': actualizadoPor,
        'fechaActualizacion': FieldValue.serverTimestamp(),
      };
}