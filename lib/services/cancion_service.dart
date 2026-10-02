import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cancion.dart';

class CancionService {
  final _db = FirebaseFirestore.instance;

  Stream<List<Cancion>> listar() {
    return _db
        .collection('canciones')
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Cancion.fromDoc).toList());
  }

  Future<String> agregar(Cancion c) async {
    final ref = await _db.collection('canciones').add(c.toMap());
    return ref.id;
  }

  Future<void> actualizar(String id, Map<String, dynamic> cambios) {
    return _db.collection('canciones').doc(id).update(cambios);
  }

  Future<void> eliminar(String id) {
    return _db.collection('canciones').doc(id).delete();
  }

  /// Incrementa en 1 el contador de reproducciones de una canción.
  Future<void> incrementarReproduccion(String id) async {
    try {
      await _db.collection('canciones').doc(id).update({
        'reproducciones': FieldValue.increment(1),
      });
    } catch (_) {
      // Silenciar errores (por si la canción no existe o falla la red)
    }
  }
}