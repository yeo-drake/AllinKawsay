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

  Future<void> agregar(Recuerdo r) {
    return _db.collection('recuerdos').add(r.toMap());
  }

  Future<void> eliminar(String id) {
    return _db.collection('recuerdos').doc(id).delete();
  }
}