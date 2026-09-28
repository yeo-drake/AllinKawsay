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

  Future<void> agregar(Evento e) {
    return _db.collection('eventos').add(e.toMap());
  }

  Future<void> eliminar(String id) {
    return _db.collection('eventos').doc(id).delete();
  }
}