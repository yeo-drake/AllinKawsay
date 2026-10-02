class YoutubeHelper {
  /// Extrae el ID de un video de YouTube desde cualquier formato de URL.
  /// Devuelve null si no es una URL válida de YouTube.
  static String? extraerId(String url) {
    if (url.isEmpty) return null;

    try {
      final uri = Uri.parse(url);

      // youtu.be/VIDEO_ID
      if (uri.host == 'youtu.be') {
        return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
      }

      // youtube.com/watch?v=VIDEO_ID
      if (uri.host.contains('youtube.com')) {
        final v = uri.queryParameters['v'];
        if (v != null && v.isNotEmpty) return v;

        // youtube.com/embed/VIDEO_ID
        if (uri.pathSegments.length >= 2 &&
            uri.pathSegments[0] == 'embed') {
          return uri.pathSegments[1];
        }

        // youtube.com/shorts/VIDEO_ID
        if (uri.pathSegments.length >= 2 &&
            uri.pathSegments[0] == 'shorts') {
          return uri.pathSegments[1];
        }
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  /// Devuelve la URL de la miniatura del video.
  /// Usa la calidad "hqdefault" que siempre existe.
  static String? miniaturaUrl(String url) {
    final id = extraerId(url);
    if (id == null) return null;
    return 'https://img.youtube.com/vi/$id/hqdefault.jpg';
  }

  /// Devuelve la URL de la miniatura en alta calidad.
  /// Puede no existir para videos viejos.
  static String? miniaturaHdUrl(String url) {
    final id = extraerId(url);
    if (id == null) return null;
    return 'https://img.youtube.com/vi/$id/maxresdefault.jpg';
  }

  /// Devuelve true si la URL es de YouTube
  static bool esYoutube(String url) {
    return extraerId(url) != null;
  }
}