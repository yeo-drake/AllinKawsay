import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/usuario.dart';

class UsuarioService {
  final _db = FirebaseFirestore.instance;

  String? miUid() => FirebaseAuth.instance.currentUser?.uid;

  Stream<Usuario?> miUsuario() {
    final uid = miUid();
    if (uid == null) return Stream.value(null);
    return _db
        .collection('usuarios')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? Usuario.fromDoc(doc) : null);
  }

  Future<Usuario?> obtener(String uid) async {
    final doc = await _db.collection('usuarios').doc(uid).get();
    return doc.exists ? Usuario.fromDoc(doc) : null;
  }

  Future<Usuario?> miUsuarioActual() async {
    final uid = miUid();
    if (uid == null) return null;
    return obtener(uid);
  }

  Future<bool> soyAdmin() async {
    final u = await miUsuarioActual();
    return u?.esAdmin ?? false;
  }

  Stream<List<Usuario>> listar() {
    return _db
        .collection('usuarios')
        .orderBy('fechaRegistro', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Usuario.fromDoc).toList());
  }

  Future<void> cambiarRol(String uid, String nuevoRol) {
    return _db.collection('usuarios').doc(uid).update({'rol': nuevoRol});
  }
}