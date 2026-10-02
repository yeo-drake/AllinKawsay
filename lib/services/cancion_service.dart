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

  Future<void> incrementarReproduccion(String id) async {
    try {
      await _db.collection('canciones').doc(id).update({
        'reproducciones': FieldValue.increment(1),
      });
    } catch (_) {}
  }

  /// Cuenta cuántas canciones subió un usuario en particular
  Future<int> contarPorUsuario(String uid) async {
    try {
      final snap = await _db
          .collection('canciones')
          .where('creadoPor', isEqualTo: uid)
          .count()
          .get();
      return snap.count ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Suma total de reproducciones de las canciones subidas por un usuario
  Future<int> totalReproduccionesDeUsuario(String uid) async {
    try {
      final snap = await _db
          .collection('canciones')
          .where('creadoPor', isEqualTo: uid)
          .get();
      int total = 0;
      for (final doc in snap.docs) {
        final d = doc.data();
        final r = d['reproducciones'];
        if (r is int) total += r;
      }
      return total;
    } catch (_) {
      return 0;
    }
  }
}