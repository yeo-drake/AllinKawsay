import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/historia.dart';

class HistoriaService {
  final _db = FirebaseFirestore.instance;

  static const _docId = 'principal';

  Stream<Historia> stream() {
    return _db
        .collection('historia')
        .doc(_docId)
        .snapshots()
        .map(Historia.fromDoc);
  }

  Future<Historia> obtener() async {
    final doc =
        await _db.collection('historia').doc(_docId).get();
    return Historia.fromDoc(doc);
  }

  Future<void> guardar(Historia h) {
    return _db
        .collection('historia')
        .doc(_docId)
        .set(h.toMap(), SetOptions(merge: true));
  }
}