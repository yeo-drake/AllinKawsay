import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StorageService {
  // ⚠️ CAMBIA ESTO con tus datos de Cloudinary
  static const String cloudName = 'eveyybgz';
  static const String uploadPreset = 'sikuris_preset';

  Future<String> subirArchivo(File archivo, String carpeta) async {
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

  Future<String> subirPDF(File archivo, String cancionId) =>
      subirArchivo(archivo, 'sikuris/canciones/$cancionId');

  Future<String> subirAudio(File archivo, String cancionId) =>
      subirArchivo(archivo, 'sikuris/canciones/$cancionId');

  Future<String> subirFoto(File archivo, String carpeta) =>
      subirArchivo(archivo, 'sikuris/$carpeta');
}