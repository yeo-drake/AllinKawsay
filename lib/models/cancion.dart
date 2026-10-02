import 'package:cloud_firestore/cloud_firestore.dart';
import 'numerofonia.dart';

class Cancion {
  final String id;
  final String titulo;
  final String autor;
  final String tipo;
  final String ritmo;
  final String region;
  final String numerofonia;
  final List<EstrofaNumerofonia> estrofas;
  final String letra;
  final String imagenUrl;
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
    required this.estrofas,
    required this.letra,
    required this.imagenUrl,
    required this.audioUrl,
    required this.descripcion,
    required this.tags,
    required this.creadoPor,
    required this.creadorNombre,
    this.fechaCreacion,
  });

  bool get tieneNumerofonia => estrofas.any((e) => !e.vacia);
  bool get tieneNumerofoniaString => numerofonia.isNotEmpty;

  factory Cancion.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    // Compatibilidad: leer 'compases' o 'estrofas'
    final raw = d['estrofas'] ?? d['compases'] ?? d['numerofoniaEstructurada'];
    final lista = (raw as List?)
            ?.map((x) => EstrofaNumerofonia.fromMap(
                Map<String, dynamic>.from(x)))
            .toList() ??
        <EstrofaNumerofonia>[];
    return Cancion(
      id: doc.id,
      titulo: d['titulo'] ?? '',
      autor: d['autor'] ?? '',
      tipo: d['tipo'] ?? 'original',
      ritmo: d['ritmo'] ?? '',
      region: d['region'] ?? '',
      numerofonia: d['numerofonia'] ?? '',
      estrofas: lista,
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
        'estrofas': estrofas.map((e) => e.toMap()).toList(),
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