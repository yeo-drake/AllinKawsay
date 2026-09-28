import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/usuario.dart';

class UsuarioService {
  final _db = FirebaseFirestore.instance;

  Stream<Usuario?> miUsuario() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
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

  Future<bool> soyAdmin() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;
    final u = await obtener(uid);
    return u?.esAdmin ?? false;
  }

  /// Lista todos los usuarios (solo para admin)
  Stream<List<Usuario>> listar() {
    return _db
        .collection('usuarios')
        .orderBy('fechaRegistro', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Usuario.fromDoc).toList());
  }

  /// Cambia el rol de un usuario
  Future<void> cambiarRol(String uid, String nuevoRol) {
    return _db.collection('usuarios').doc(uid).update({'rol': nuevoRol});
  }
}