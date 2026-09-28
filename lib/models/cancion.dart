import 'package:cloud_firestore/cloud_firestore.dart';

class Cancion {
  final String id;
  final String titulo;
  final String compositor;
  final String ritmo;
  final String region;
  final String numerofonia;
  final String audioUrl;
  final String pdfUrl;
  final String descripcion;
  final String creadoPor;
  final String creadorNombre;
  final DateTime? fechaCreacion;

  Cancion({
    required this.id,
    required this.titulo,
    required this.compositor,
    required this.ritmo,
    required this.region,
    required this.numerofonia,
    required this.audioUrl,
    required this.pdfUrl,
    required this.descripcion,
    required this.creadoPor,
    required this.creadorNombre,
    this.fechaCreacion,
  });

  factory Cancion.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Cancion(
      id: doc.id,
      titulo: d['titulo'] ?? '',
      compositor: d['compositor'] ?? '',
      ritmo: d['ritmo'] ?? '',
      region: d['region'] ?? '',
      numerofonia: d['numerofonia'] ?? '',
      audioUrl: d['audioUrl'] ?? '',
      pdfUrl: d['pdfUrl'] ?? '',
      descripcion: d['descripcion'] ?? '',
      creadoPor: d['creadoPor'] ?? '',
      creadorNombre: d['creadorNombre'] ?? '',
      fechaCreacion: (d['fechaCreacion'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'titulo': titulo,
        'compositor': compositor,
        'ritmo': ritmo,
        'region': region,
        'numerofonia': numerofonia,
        'audioUrl': audioUrl,
        'pdfUrl': pdfUrl,
        'descripcion': descripcion,
        'creadoPor': creadoPor,
        'creadorNombre': creadorNombre,
        'fechaCreacion': FieldValue.serverTimestamp(),
      };
}