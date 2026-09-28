import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  final String uid;
  final String nombre;
  final String email;
  final String rol; // 'admin' | 'miembro' | 'publico'
  final DateTime? fechaRegistro;

  Usuario({
    required this.uid,
    required this.nombre,
    required this.email,
    required this.rol,
    this.fechaRegistro,
  });

  bool get esAdmin => rol == 'admin';
  bool get esMiembro => rol == 'miembro' || rol == 'admin';
  bool get esPublico => rol == 'publico';

  /// Puede descargar archivos (imágenes, audios)
  bool get puedeDescargar => esAdmin || rol == 'miembro';

  /// Puede comentar
  bool get puedeComentar => esAdmin || rol == 'miembro';

  /// Puede subir contenido (canciones, eventos, recuerdos, historia)
  bool get puedeSubir => esAdmin;

  /// Nombre del rol para mostrar
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

  factory Usuario.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Usuario(
      uid: doc.id,
      nombre: d['nombre'] ?? '',
      email: d['email'] ?? '',
      rol: d['rol'] ?? 'publico',
      fechaRegistro: (d['fechaRegistro'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'email': email,
        'rol': rol,
        'fechaRegistro': fechaRegistro ?? FieldValue.serverTimestamp(),
      };
}