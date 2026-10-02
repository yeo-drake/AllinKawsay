import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cancion.dart';
import 'actividad_service.dart';

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
    ActividadService.registrar(
      'crear_cancion',
      'Subió la canción "${c.titulo}"',
    );
    return ref.id;
  }

  Future<void> actualizar(String id, Map<String, dynamic> cambios) async {
    await _db.collection('canciones').doc(id).update(cambios);
    final titulo = cambios['titulo'] ?? id;
    ActividadService.registrar(
      'editar_cancion',
      'Editó la canción "$titulo"',
    );
  }

  Future<void> eliminar(String id) async {
    // Intentar leer el título antes de borrar
    String titulo = id;
    try {
      final doc = await _db.collection('canciones').doc(id).get();
      if (doc.exists) {
        titulo = (doc.data()?['titulo'] ?? id).toString();
      }
    } catch (_) {}

    await _db.collection('canciones').doc(id).delete();
    ActividadService.registrar(
      'eliminar_cancion',
      'Eliminó la canción "$titulo"',
    );
  }

  Future<void> incrementarReproduccion(String id) async {
    try {
      await _db.collection('canciones').doc(id).update({
        'reproducciones': FieldValue.increment(1),
      });
    } catch (_) {}
  }

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

  Future<int> totalReproduccionesDeUsuario(String uid) async {
    try {
      final snap = await _db
          .collection('canciones')
          .where('creadoPor', isEqualTo: uid)
          .get();
      int total = 0;
      for (final doc in snap.docs) {
        final r = doc.data()['reproducciones'];
        if (r is int) total += r;
      }
      return total;
    } catch (_) {
      return 0;
    }
  }
}