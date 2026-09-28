import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StorageService {
  // ⚠️ Reemplaza con tu Cloud name
  static const String cloudName = 'eveyybgz';
  static const String uploadPreset = 'sikuris_preset';

  // Método general para subir archivos, ahora recibe el tipo de recurso
  Future<String> _subirConTipo(File archivo, String carpeta, String resourceType) async {
    // La URL ahora incluye el resource_type (image, video, raw)
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

  // Sube PDFs usando el tipo 'raw'
  Future<String> subirPDF(File archivo, String cancionId) =>
      _subirConTipo(archivo, 'sikuris/canciones/$cancionId', 'raw');

  // Sube audios usando el tipo 'video'
  Future<String> subirAudio(File archivo, String cancionId) =>
      _subirConTipo(archivo, 'sikuris/canciones/$cancionId', 'video');

  // Sube fotos usando el tipo 'image'
  Future<String> subirFoto(File archivo, String carpeta) =>
      _subirConTipo(archivo, 'sikuris/$carpeta', 'image');
}