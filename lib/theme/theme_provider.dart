import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider {
  static final ValueNotifier<ThemeMode> mode =
      ValueNotifier(ThemeMode.light);

  static const _key = 'tema_modo';

  /// Cargar tema guardado al abrir la app
  static Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final valor = prefs.getString(_key) ?? 'light';
    switch (valor) {
      case 'dark':
        mode.value = ThemeMode.dark;
        break;
      case 'system':
        mode.value = ThemeMode.system;
        break;
      default:
        mode.value = ThemeMode.light;
    }
  }

  /// Cambiar el tema
  static Future<void> cambiar(ThemeMode nuevo) async {
    mode.value = nuevo;
    final prefs = await SharedPreferences.getInstance();
    switch (nuevo) {
      case ThemeMode.dark:
        await prefs.setString(_key, 'dark');
        break;
      case ThemeMode.system:
        await prefs.setString(_key, 'system');
        break;
      default:
        await prefs.setString(_key, 'light');
    }
  }

  /// Alternar entre claro y oscuro (uso rápido)
  static Future<void> alternar() async {
    if (mode.value == ThemeMode.dark) {
      await cambiar(ThemeMode.light);
    } else {
      await cambiar(ThemeMode.dark);
    }
  }

  static String get nombreActual {
    switch (mode.value) {
      case ThemeMode.dark:
        return 'Oscuro';
      case ThemeMode.system:
        return 'Sistema';
      default:
        return 'Claro';
    }
  }

  static IconData get iconoActual {
    switch (mode.value) {
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
      default:
        return Icons.light_mode;
    }
  }
}