import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comentario.dart';

class ComentarioService {
  final _db = FirebaseFirestore.instance;

  Stream<List<Comentario>> listar(String cancionId) {
    return _db
        .collection('canciones')
        .doc(cancionId)
        .collection('comentarios')
        .orderBy('fecha', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map(Comentario.fromDoc).toList());
  }

  Future<void> agregar(String cancionId, Comentario c) {
    return _db
        .collection('canciones')
        .doc(cancionId)
        .collection('comentarios')
        .add(c.toMap());
  }

  Future<void> eliminar(String cancionId, String comentarioId) {
    return _db
        .collection('canciones')
        .doc(cancionId)
        .collection('comentarios')
        .doc(comentarioId)
        .delete();
  }
}