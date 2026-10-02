import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class RespaldoService {
  final _db = FirebaseFirestore.instance;

  /// Genera un JSON con TODO el contenido del grupo.
  /// Estructura:
  /// {
  ///   "generadoEn": "2026-10-02T...",
  ///   "canciones": [...],
  ///   "eventos": [...],
  ///   "recuerdos": [...],
  ///   "historia": {...},
  ///   "usuarios": [...]
  /// }
  Future<String> generarRespaldo() async {
    final canciones = await _db.collection('canciones').get();
    final eventos = await _db.collection('eventos').get();
    final recuerdos = await _db.collection('recuerdos').get();
    final historiaDoc =
        await _db.collection('historia').doc('principal').get();
    final usuarios = await _db.collection('usuarios').get();

    final data = {
      'generadoEn': DateTime.now().toIso8601String(),
      'version': '1.0.0',
      'canciones': canciones.docs
          .map((d) => {'id': d.id, ...d.data()})
          .toList(),
      'eventos':
          eventos.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
      'recuerdos': recuerdos.docs
          .map((d) => {'id': d.id, ...d.data()})
          .toList(),
      'historia': historiaDoc.exists
          ? {'id': historiaDoc.id, ...?historiaDoc.data()}
          : null,
      'usuarios': usuarios.docs
          .map((d) => {
                'id': d.id,
                // No exportamos datos sensibles, solo info pública
                'nombre': d.data()['nombre'] ?? '',
                'rol': d.data()['rol'] ?? 'publico',
                'fechaRegistro': d.data()['fechaRegistro'],
              })
          .toList(),
    };

    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(data);
  }

  /// Cuenta los elementos para mostrar un preview antes de exportar
  Future<Map<String, int>> contarElementos() async {
    final c = await _db.collection('canciones').count().get();
    final e = await _db.collection('eventos').count().get();
    final r = await _db.collection('recuerdos').count().get();
    final u = await _db.collection('usuarios').count().get();
    return {
      'canciones': c.count ?? 0,
      'eventos': e.count ?? 0,
      'recuerdos': r.count ?? 0,
      'usuarios': u.count ?? 0,
    };
  }
}