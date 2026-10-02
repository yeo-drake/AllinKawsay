import 'package:flutter/material.dart';

class AppColors {
  // === PALETA PRINCIPAL DEL GRUPO ===
  static const granate = Color(0xFF6E1423);
  static const granateOscuro = Color(0xFF4A0D18);
  static const dorado = Color(0xFFD4AF37);
  static const doradoClaro = Color(0xFFE8C86A);
  static const negro = Color(0xFF1A1A1A);
  static const blanco = Color(0xFFFFFFFF);
  static const grisClaro = Color(0xFFF5F5F5);
  static const grisMedio = Color(0xFFBDBDBD);

  // === MODO OSCURO ===
  static const fondoOscuro = Color(0xFF121212);
  static const fondoCardOscuro = Color(0xFF1E1E1E);
  static const textoOscuroClaro = Color(0xFFE0E0E0);
  static const textoOscuroMedio = Color(0xFFB0B0B0);

  // === HELPERS DE TEXTO ===
  // Devuelve el color correcto según el tema activo

  /// Texto principal (títulos, contenido)
  static Color textoPrincipal(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textoOscuroClaro
        : negro;
  }

  /// Texto secundario (subtítulos, textos con opacidad)
  static Color textoSecundario(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textoOscuroMedio
        : negro.withOpacity(0.6);
  }

  /// Texto terciario (hints, textos muy suaves)
  static Color textoTerciario(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textoOscuroMedio.withOpacity(0.7)
        : negro.withOpacity(0.5);
  }

  /// Color del borde y separadores
  static Color borde(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? dorado.withOpacity(0.4)
        : dorado;
  }
}