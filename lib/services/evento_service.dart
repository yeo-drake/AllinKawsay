import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/evento.dart';

class EventoService {
  final _db = FirebaseFirestore.instance;

  Stream<List<Evento>> listar() {
    return _db
        .collection('eventos')
        .orderBy('fecha', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map(Evento.fromDoc).toList());
  }

  Future<String> agregar(Evento e) async {
    final ref = await _db.collection('eventos').add(e.toMap());
    return ref.id;
  }

  Future<void> actualizar(String id, Map<String, dynamic> cambios) {
    return _db.collection('eventos').doc(id).update(cambios);
  }

  Future<void> eliminar(String id) {
    return _db.collection('eventos').doc(id).delete();
  }
}