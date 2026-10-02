import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/usuario.dart';
import 'actividad_service.dart';

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

  Future<void> cambiarRol(String uid, String nuevoRol) async {
    await _db.collection('usuarios').doc(uid).update({'rol': nuevoRol});
    String nombre = uid;
    try {
      final doc = await _db.collection('usuarios').doc(uid).get();
      if (doc.exists) {
        nombre = (doc.data()?['nombre'] ?? uid).toString();
      }
    } catch (_) {}
    ActividadService.registrar(
      'cambiar_rol',
      'Cambió el rol de "$nombre" a ${nuevoRol.toUpperCase()}',
    );
  }

  Future<void> actualizarFotoPerfil(String uid, String fotoUrl) {
    return _db.collection('usuarios').doc(uid).update({'fotoUrl': fotoUrl});
  }

  Future<void> actualizarNombre(String uid, String nombre) async {
    await _db.collection('usuarios').doc(uid).update({'nombre': nombre});
    await FirebaseAuth.instance.currentUser?.updateDisplayName(nombre);
    ActividadService.registrar(
      'cambiar_nombre',
      'Cambió su nombre a "$nombre"',
    );
  }

  Future<void> toggleFavorito(String cancionId) async {
    final uid = miUid();
    if (uid == null) return;

    final doc = await _db.collection('usuarios').doc(uid).get();
    final data = doc.data();
    if (data == null) return;

    final List<String> favs = List<String>.from(data['favoritos'] ?? []);
    if (favs.contains(cancionId)) {
      favs.remove(cancionId);
    } else {
      favs.add(cancionId);
    }
    await _db
        .collection('usuarios')
        .doc(uid)
        .update({'favoritos': favs});
  }

  /// Guarda una nota privada del usuario para una canción.
  Future<void> guardarNota(String cancionId, String texto) =>
      _guardarNotaEn('notasPorCancion', cancionId, texto);

  /// Guarda una nota privada del usuario para un evento.
  Future<void> guardarNotaEvento(String eventoId, String texto) =>
      _guardarNotaEn('notasPorEvento', eventoId, texto);

  /// Guarda una nota privada del usuario para un recuerdo.
  Future<void> guardarNotaRecuerdo(String recuerdoId, String texto) =>
      _guardarNotaEn('notasPorRecuerdo', recuerdoId, texto);

  Future<void> _guardarNotaEn(
      String campo, String itemId, String texto) async {
    final uid = miUid();
    if (uid == null) return;

    final ref = _db.collection('usuarios').doc(uid);
    if (texto.trim().isEmpty) {
      await ref.update({
        '$campo.$itemId': FieldValue.delete(),
      });
    } else {
      await ref.update({
        '$campo.$itemId': texto.trim(),
      });
    }
  }
}