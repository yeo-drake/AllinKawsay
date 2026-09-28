import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get usuarioActual => _auth.currentUser;
  Stream<User?> get cambiosUsuario => _auth.authStateChanges();

  Future<User?> registrar(
      String email, String password, String nombre) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user?.updateDisplayName(nombre);
    await cred.user?.reload();

    await _db.collection('usuarios').doc(cred.user!.uid).set({
      'nombre': nombre,
      'email': email,
      'rol': 'publico',
      'fechaRegistro': FieldValue.serverTimestamp(),
    });

    return _auth.currentUser;
  }

  Future<User?> login(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  Future<void> logout() => _auth.signOut();
}