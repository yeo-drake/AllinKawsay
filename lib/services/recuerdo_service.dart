import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recuerdo.dart';

class RecuerdoService {
  final _db = FirebaseFirestore.instance;

  Stream<List<Recuerdo>> listar() {
    return _db
        .collection('recuerdos')
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Recuerdo.fromDoc).toList());
  }

  Future<String> agregar(Recuerdo r) async {
    final ref = await _db.collection('recuerdos').add(r.toMap());
    return ref.id;
  }

  Future<void> actualizar(String id, Map<String, dynamic> cambios) {
    return _db.collection('recuerdos').doc(id).update(cambios);
  }

  Future<void> eliminar(String id) {
    return _db.collection('recuerdos').doc(id).delete();
  }
}