import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recuerdo.dart';
import 'actividad_service.dart';

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
    ActividadService.registrar(
      'crear_recuerdo',
      'Subió el recuerdo "${r.titulo}" (${r.fotos.length} fotos)',
    );
    return ref.id;
  }

  Future<void> actualizar(String id, Map<String, dynamic> cambios) async {
    await _db.collection('recuerdos').doc(id).update(cambios);
    final titulo = cambios['titulo'] ?? id;
    ActividadService.registrar(
      'editar_recuerdo',
      'Editó el recuerdo "$titulo"',
    );
  }

  Future<void> eliminar(String id) async {
    String titulo = id;
    try {
      final doc = await _db.collection('recuerdos').doc(id).get();
      if (doc.exists) {
        titulo = (doc.data()?['titulo'] ?? id).toString();
      }
    } catch (_) {}

    await _db.collection('recuerdos').doc(id).delete();
    ActividadService.registrar(
      'eliminar_recuerdo',
      'Eliminó el recuerdo "$titulo"',
    );
  }
}