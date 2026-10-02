import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/categoria.dart';
import 'actividad_service.dart';

class CategoriaService {
  final _db = FirebaseFirestore.instance;

  Stream<List<Categoria>> listar() {
    return _db
        .collection('categorias')
        .orderBy('orden', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map(Categoria.fromDoc).toList());
  }

  Future<String> agregar(Categoria c) async {
    final ref = await _db.collection('categorias').add(c.toMap());
    ActividadService.registrar(
      'crear_categoria',
      'Creó la categoría "${c.emoji} ${c.nombre}"',
    );
    return ref.id;
  }

  Future<void> actualizar(String id, Map<String, dynamic> cambios) async {
    await _db.collection('categorias').doc(id).update(cambios);
    final nombre = cambios['nombre'] ?? id;
    ActividadService.registrar(
      'editar_categoria',
      'Editó la categoría "$nombre"',
    );
  }

  Future<void> eliminar(String id) async {
    String nombre = id;
    try {
      final doc = await _db.collection('categorias').doc(id).get();
      if (doc.exists) {
        nombre = (doc.data()?['nombre'] ?? id).toString();
      }
    } catch (_) {}

    await _db.collection('categorias').doc(id).delete();
    ActividadService.registrar(
      'eliminar_categoria',
      'Eliminó la categoría "$nombre"',
    );
  }
}