import 'package:cloud_firestore/cloud_firestore.dart';

class Cancion {
  final String id;
  final String titulo;
  final String autor;
  final String tipo; // 'original' | 'adaptacion'
  final String ritmo;
  final String region;
  final String numerofonia;
  final String letra;
  final String imagenUrl; // imagen de la partitura
  final String audioUrl;
  final String descripcion;
  final List<String> tags;
  final String creadoPor;
  final String creadorNombre;
  final DateTime? fechaCreacion;

  Cancion({
    required this.id,
    required this.titulo,
    required this.autor,
    required this.tipo,
    required this.ritmo,
    required this.region,
    required this.numerofonia,
    required this.letra,
    required this.imagenUrl,
    required this.audioUrl,
    required this.descripcion,
    required this.tags,
    required this.creadoPor,
    required this.creadorNombre,
    this.fechaCreacion,
  });

  factory Cancion.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Cancion(
      id: doc.id,
      titulo: d['titulo'] ?? '',
      autor: d['autor'] ?? '',
      tipo: d['tipo'] ?? 'original',
      ritmo: d['ritmo'] ?? '',
      region: d['region'] ?? '',
      numerofonia: d['numerofonia'] ?? '',
      letra: d['letra'] ?? '',
      imagenUrl: d['imagenUrl'] ?? '',
      audioUrl: d['audioUrl'] ?? '',
      descripcion: d['descripcion'] ?? '',
      tags: List<String>.from(d['tags'] ?? []),
      creadoPor: d['creadoPor'] ?? '',
      creadorNombre: d['creadorNombre'] ?? '',
      fechaCreacion: (d['fechaCreacion'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'titulo': titulo,
        'autor': autor,
        'tipo': tipo,
        'ritmo': ritmo,
        'region': region,
        'numerofonia': numerofonia,
        'letra': letra,
        'imagenUrl': imagenUrl,
        'audioUrl': audioUrl,
        'descripcion': descripcion,
        'tags': tags,
        'creadoPor': creadoPor,
        'creadorNombre': creadorNombre,
        'fechaCreacion': FieldValue.serverTimestamp(),
      };
}