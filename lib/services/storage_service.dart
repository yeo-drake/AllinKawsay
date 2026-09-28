import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StorageService {
  // ⚠️ Reemplaza con tu Cloud name
  static const String cloudName = 'eveyybgz';
  static const String uploadPreset = 'sikuris_preset';

  Future<String> _subirConTipo(
      File archivo, String carpeta, String resourceType) async {
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload',
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

  // Imagen de partitura
  Future<String> subirPartitura(File archivo, String cancionId) =>
      _subirConTipo(archivo, 'sikuris/canciones/$cancionId', 'image');

  // Audio (Cloudinary lo trata como 'video')
  Future<String> subirAudio(File archivo, String cancionId) =>
      _subirConTipo(archivo, 'sikuris/canciones/$cancionId', 'video');

  // Fotos de recuerdos
  Future<String> subirFoto(File archivo, String carpeta) =>
      _subirConTipo(archivo, 'sikuris/$carpeta', 'image');
}