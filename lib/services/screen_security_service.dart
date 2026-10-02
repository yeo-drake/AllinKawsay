import 'package:flutter/services.dart';

class ScreenSecurityService {
  static const _channel =
      MethodChannel('com.sikuris/screen_security');

  /// Bloquea capturas de pantalla y grabación (solo Android).
  static Future<void> enable() async {
    try {
      await _channel.invokeMethod('enable');
    } catch (_) {
      // Ignorar si el canal no está disponible
    }
  }

  /// Permite capturas de pantalla y grabación.
  static Future<void> disable() async {
    try {
      await _channel.invokeMethod('disable');
    } catch (_) {
      // Ignorar si el canal no está disponible
    }
  }
}