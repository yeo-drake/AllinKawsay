import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class DescargaService {
  static const _channel = MethodChannel('com.sikuris/screen_security');

  /// Descarga un archivo desde una URL y lo guarda en la carpeta
  /// Descargas del dispositivo.
  /// Devuelve el nombre del archivo guardado, o null si falla.
  static Future<String?> descargar(
      String url, String nombreArchivo, String mimeType) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception('Error HTTP: ${response.statusCode}');
      }

      final Uint8List bytes = response.bodyBytes;

      final resultado = await _channel.invokeMethod('guardarEnDescargas', {
        'bytes': bytes,
        'nombre': nombreArchivo,
        'mime': mimeType,
      });

      if (resultado != null) {
        return nombreArchivo;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Genera un nombre único para el archivo con timestamp.
  static String nombreConTimestamp(String base, String extension) {
    final ahora = DateTime.now();
    final ts = '${ahora.year}${ahora.month.toString().padLeft(2, '0')}'
        '${ahora.day.toString().padLeft(2, '0')}_'
        '${ahora.hour.toString().padLeft(2, '0')}'
        '${ahora.minute.toString().padLeft(2, '0')}'
        '${ahora.second.toString().padLeft(2, '0')}';
    final limpio = base.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');
    return '${limpio}_$ts.$extension';
  }
}