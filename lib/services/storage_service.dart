import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class StorageService {
  // ⚠️ Reemplaza con tu Cloud name
  static const String cloudName = 'eveyybgz';
  static const String uploadPreset = 'sikuris_preset';

  Future<String> _subirConAuto(File archivo, String carpeta) async {
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

  Future<String> subirPartitura(File archivo, String cancionId) =>
      _subirConAuto(archivo, 'sikuris/canciones/$cancionId');

  Future<String> subirAudio(File archivo, String cancionId) =>
      _subirConAuto(archivo, 'sikuris/canciones/$cancionId');

  Future<String> subirFoto(File archivo, String carpeta) =>
      _subirConAuto(archivo, 'sikuris/$carpeta');

  /// Descarga un archivo desde URL y lo comparte/guarda
  Future<void> descargar(String url, String nombreArchivo) async {
    final dir = await getTemporaryDirectory();
    final archivo = File('${dir.path}/$nombreArchivo');
    final res = await http.get(Uri.parse(url));
    if (res.statusCode != 200) {
      throw Exception('No se pudo descargar (${res.statusCode})');
    }
    await archivo.writeAsBytes(res.bodyBytes);
    await Share.shareXFiles(
      [XFile(archivo.path)],
      text: 'Sikuris - $nombreArchivo',
    );
  }
}