import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  final String uid;
  final String nombre;
  final String email;
  final String rol;
  final String fotoUrl;
  final List<String> favoritos;
  final DateTime? fechaRegistro;

  Usuario({
    required this.uid,
    required this.nombre,
    required this.email,
    required this.rol,
    this.fotoUrl = '',
    this.favoritos = const [],
    this.fechaRegistro,
  });

  bool get esAdmin => rol == 'admin';
  bool get esMiembro => rol == 'miembro' || rol == 'admin';
  bool get esPublico => rol == 'publico';

  bool get puedeDescargar => esAdmin || rol == 'miembro';
  bool get puedeComentar => esAdmin || rol == 'miembro';
  bool get puedeSubir => esAdmin;

  String get rolNombre {
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

  factory Usuario.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Usuario(
      uid: doc.id,
      nombre: d['nombre'] ?? '',
      email: d['email'] ?? '',
      rol: d['rol'] ?? 'publico',
      fotoUrl: d['fotoUrl'] ?? '',
      favoritos: List<String>.from(d['favoritos'] ?? []),
      fechaRegistro: (d['fechaRegistro'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'email': email,
        'rol': rol,
        'fotoUrl': fotoUrl,
        'favoritos': favoritos,
        'fechaRegistro': fechaRegistro ?? FieldValue.serverTimestamp(),
      };
}