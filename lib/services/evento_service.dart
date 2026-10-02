import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/evento.dart';
import 'actividad_service.dart';

class EventoService {
  final _db = FirebaseFirestore.instance;

  Stream<List<Evento>> listar() {
    return _db
        .collection('eventos')
        .orderBy('fecha', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map(Evento.fromDoc).toList());
  }

  Future<String> agregar(Evento e) async {
    final ref = await _db.collection('eventos').add(e.toMap());
    ActividadService.registrar(
      'crear_evento',
      'Creó el evento "${e.titulo}"',
    );
    return ref.id;
  }

  Future<void> actualizar(String id, Map<String, dynamic> cambios) async {
    await _db.collection('eventos').doc(id).update(cambios);
    final titulo = cambios['titulo'] ?? id;
    ActividadService.registrar(
      'editar_evento',
      'Editó el evento "$titulo"',
    );
  }

  Future<void> eliminar(String id) async {
    String titulo = id;
    try {
      final doc = await _db.collection('eventos').doc(id).get();
      if (doc.exists) {
        titulo = (doc.data()?['titulo'] ?? id).toString();
      }
    } catch (_) {}

    await _db.collection('eventos').doc(id).delete();
    ActividadService.registrar(
      'eliminar_evento',
      'Eliminó el evento "$titulo"',
    );
  }
}