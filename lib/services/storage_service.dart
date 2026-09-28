import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StorageService {
  // ⚠️ Reemplaza con tu Cloud name
  static const String cloudName = 'eveyybgz';
  static const String uploadPreset = 'sikuris_preset';

  // Método general para subir archivos usando el tipo de recurso 'auto'
  Future<String> _subirConAuto(File archivo, String carpeta) async {
    // La URL usa 'auto', dejando que Cloudinary decida el tipo correcto
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/auto/upload',
    );

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..fields['folder'] = carpeta
      ..files.add(await http.MultipartFile.fromPath('file', archivo.path));

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception('Error subiendo archivo: $body');
    }

    final json = jsonDecode(body);
    return json['secure_url'] as String;
  }

  // Sube la imagen de la partitura (Cloudinary lo tratará como 'image')
  Future<String> subirPartitura(File archivo, String cancionId) =>
      _subirConAuto(archivo, 'sikuris/canciones/$cancionId');

  // Sube el audio (Cloudinary lo tratará como 'video')
  Future<String> subirAudio(File archivo, String cancionId) =>
      _subirConAuto(archivo, 'sikuris/canciones/$cancionId');

  // Sube fotos para los recuerdos (Cloudinary lo tratará como 'image')
  Future<String> subirFoto(File archivo, String carpeta) =>
      _subirConAuto(archivo, 'sikuris/$carpeta');
}