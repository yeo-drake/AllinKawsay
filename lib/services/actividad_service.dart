import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Actividad {
  final String id;
  final String accion;
  final String detalle;
  final String autorUid;
  final String autorNombre;
  final DateTime? fecha;

  Actividad({
    required this.id,
    required this.accion,
    required this.detalle,
    required this.autorUid,
    required this.autorNombre,
    this.fecha,
  });

  factory Actividad.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Actividad(
      id: doc.id,
      accion: d['accion'] ?? '',
      detalle: d['detalle'] ?? '',
      autorUid: d['autorUid'] ?? '',
      autorNombre: d['autorNombre'] ?? 'Anónimo',
      fecha: (d['fecha'] as Timestamp?)?.toDate(),
    );
  }
}

class ActividadService {
  static final _db = FirebaseFirestore.instance;

  /// Registra una acción en el historial.
  /// Se llama desde los otros servicios después de cada operación.
  static Future<void> registrar(String accion, String detalle) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      await _db.collection('actividad').add({
        'accion': accion,
        'detalle': detalle,
        'autorUid': user.uid,
        'autorNombre': user.displayName ?? user.email ?? 'Anónimo',
        'fecha': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Silenciar: la actividad es secundaria, no debe romper la app
    }
  }

  Stream<List<Actividad>> listar({int limite = 200}) {
    return _db
        .collection('actividad')
        .orderBy('fecha', descending: true)
        .limit(limite)
        .snapshots()
        .map((snap) => snap.docs.map(Actividad.fromDoc).toList());
  }
}