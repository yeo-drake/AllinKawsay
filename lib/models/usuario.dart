import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  final String uid;
  final String nombre;
  final String email;
  final String rol; // 'admin' | 'miembro'
  final DateTime? fechaRegistro;

  Usuario({
    required this.uid,
    required this.nombre,
    required this.email,
    required this.rol,
    this.fechaRegistro,
  });

  bool get esAdmin => rol == 'admin';

  factory Usuario.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Usuario(
      uid: doc.id,
      nombre: d['nombre'] ?? '',
      email: d['email'] ?? '',
      rol: d['rol'] ?? 'miembro',
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