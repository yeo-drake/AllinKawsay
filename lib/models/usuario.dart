import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  final String uid;
  final String nombre;
  final String email;
  final String rol;
  final String fotoUrl;
  final bool baneado;
  final List<String> favoritos;
  final Map<String, String> notasPorCancion;
  final Map<String, String> notasPorEvento;
  final Map<String, String> notasPorRecuerdo;
  final DateTime? fechaRegistro;

  Usuario({
    required this.uid,
    required this.nombre,
    required this.email,
    required this.rol,
    this.fotoUrl = '',
    this.baneado = false,
    this.favoritos = const [],
    this.notasPorCancion = const {},
    this.notasPorEvento = const {},
    this.notasPorRecuerdo = const {},
    this.fechaRegistro,
  });

  bool get esAdmin => rol == 'admin';
  bool get esMiembro => rol == 'miembro' || rol == 'admin';
  bool get esPublico => rol == 'publico';

  bool get puedeDescargar => !baneado && (esAdmin || rol == 'miembro');
  bool get puedeComentar => !baneado && (esAdmin || rol == 'miembro');
  bool get puedeSubir => !baneado && esAdmin;

  String get rolNombre {
    if (baneado) return 'SUSPENDIDO';
    switch (rol) {
      case 'admin':
        return 'ADMINISTRADOR';
      case 'miembro':
        return 'MIEMBRO OFICIAL';
      default:
        return 'PÚBLICO';
    }
  }

  bool esFavorito(String cancionId) => favoritos.contains(cancionId);

  String notaDe(String cancionId) => notasPorCancion[cancionId] ?? '';
  String notaEvento(String eventoId) => notasPorEvento[eventoId] ?? '';
  String notaRecuerdo(String recuerdoId) =>
      notasPorRecuerdo[recuerdoId] ?? '';

  static Map<String, String> _parseMap(dynamic raw) {
    final out = <String, String>{};
    if (raw is Map) {
      raw.forEach((k, v) {
        out[k.toString()] = v.toString();
      });
    }
    return out;
  }

  factory Usuario.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Usuario(
      uid: doc.id,
      nombre: d['nombre'] ?? '',
      email: d['email'] ?? '',
      rol: d['rol'] ?? 'publico',
      fotoUrl: d['fotoUrl'] ?? '',
      baneado: d['baneado'] == true,
      favoritos: List<String>.from(d['favoritos'] ?? []),
      notasPorCancion: _parseMap(d['notasPorCancion']),
      notasPorEvento: _parseMap(d['notasPorEvento']),
      notasPorRecuerdo: _parseMap(d['notasPorRecuerdo']),
      fechaRegistro: (d['fechaRegistro'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'email': email,
        'rol': rol,
        'fotoUrl': fotoUrl,
        'baneado': baneado,
        'favoritos': favoritos,
        'notasPorCancion': notasPorCancion,
        'notasPorEvento': notasPorEvento,
        'notasPorRecuerdo': notasPorRecuerdo,
        'fechaRegistro': fechaRegistro ?? FieldValue.serverTimestamp(),
      };
}