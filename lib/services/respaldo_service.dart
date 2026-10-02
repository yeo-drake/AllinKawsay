import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class RespaldoService {
  final _db = FirebaseFirestore.instance;

  /// Convierte recursivamente cualquier valor no-JSON-serializable
  /// (Timestamp, GeoPoint, etc.) a un formato compatible.
  dynamic _limpiar(dynamic valor) {
    if (valor == null) return null;
    if (valor is Timestamp) return valor.toDate().toIso8601String();
    if (valor is GeoPoint) {
      return {'lat': valor.latitude, 'lng': valor.longitude};
    }
    if (valor is DocumentReference) return valor.path;
    if (valor is List) return valor.map(_limpiar).toList();
    if (valor is Map) {
      final nuevo = <String, dynamic>{};
      valor.forEach((k, v) {
        nuevo[k.toString()] = _limpiar(v);
      });
      return nuevo;
    }
    if (valor is String ||
        valor is num ||
        valor is bool) {
      return valor;
    }
    // Fallback
    return valor.toString();
  }

  Future<String> generarRespaldo() async {
    final canciones = await _db.collection('canciones').get();
    final eventos = await _db.collection('eventos').get();
    final recuerdos = await _db.collection('recuerdos').get();
    final historiaDoc =
        await _db.collection('historia').doc('principal').get();
    final usuarios = await _db.collection('usuarios').get();
    final categorias = await _db.collection('categorias').get();

    final data = {
      'generadoEn': DateTime.now().toIso8601String(),
      'version': '1.0.0',
      'canciones': canciones.docs
          .map((d) => {'id': d.id, ..._limpiar(d.data()) as Map})
          .toList(),
      'eventos': eventos.docs
          .map((d) => {'id': d.id, ..._limpiar(d.data()) as Map})
          .toList(),
      'recuerdos': recuerdos.docs
          .map((d) => {'id': d.id, ..._limpiar(d.data()) as Map})
          .toList(),
      'historia': historiaDoc.exists
          ? {'id': historiaDoc.id,
             ..._limpiar(historiaDoc.data()) as Map}
          : null,
      'categorias': categorias.docs
          .map((d) => {'id': d.id, ..._limpiar(d.data()) as Map})
          .toList(),
      'usuarios': usuarios.docs
          .map((d) {
        final data = d.data();
        return {
          'id': d.id,
          'nombre': data['nombre'] ?? '',
          'rol': data['rol'] ?? 'publico',
          'fechaRegistro':
              _limpiar(data['fechaRegistro']),
        };
      }).toList(),
    };

    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(data);
  }

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