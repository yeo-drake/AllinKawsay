import 'package:cloud_firestore/cloud_firestore.dart';
import 'numerofonia.dart';

class Cancion {
  final String id;
  final String titulo;
  final String autor;
  final String tipo;
  final String ritmo;
  final String region;
  final String numerofonia; // legacy (compatibilidad)
  final List<SeccionNumerofonia> numerofoniaEstructurada; // nuevo
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
    required this.numerofoniaEstructurada,
    required this.letra,
    required this.imagenUrl,
    required this.audioUrl,
    required this.descripcion,
    required this.tags,
    required this.creadoPor,
    required this.creadorNombre,
    this.fechaCreacion,
  });

  bool get tieneNumerofoniaTabla =>
      numerofoniaEstructurada.any((s) => !s.vacia);
  bool get tieneNumerofoniaString => numerofonia.isNotEmpty;

  factory Cancion.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final estruc = (d['numerofoniaEstructurada'] as List?)
            ?.map((x) => SeccionNumerofonia.fromMap(
                Map<String, dynamic>.from(x)))
            .toList() ??
        <SeccionNumerofonia>[];
    return Cancion(
      id: doc.id,
      titulo: d['titulo'] ?? '',
      autor: d['autor'] ?? '',
      tipo: d['tipo'] ?? 'original',
      ritmo: d['ritmo'] ?? '',
      region: d['region'] ?? '',
      numerofonia: d['numerofonia'] ?? '',
      numerofoniaEstructurada: estruc,
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
        'numerofoniaEstructurada':
            numerofoniaEstructurada.map((s) => s.toMap()).toList(),
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