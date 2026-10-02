import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class CompartirService {
  static const _channel = MethodChannel('com.sikuris/screen_security');

  /// Guarda bytes de una imagen en el cache y abre el diálogo de
  /// compartir del sistema Android.
  static Future<void> compartirImagen(
      Uint8List bytes, String nombreArchivo) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$nombreArchivo');
    await file.writeAsBytes(bytes);
    await _channel.invokeMethod('compartirArchivo', {
      'path': file.path,
    });
  }
}