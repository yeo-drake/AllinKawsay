import 'package:flutter/material.dart';

class AppColors {
  // === PALETA PRINCIPAL DEL GRUPO ===
  static const granate = Color(0xFF6E1423);
  static const granateOscuro = Color(0xFF4A0D18);
  static const granateClaro = Color(0xFF8B1F35);
  static const dorado = Color(0xFFD4AF37);
  static const doradoClaro = Color(0xFFE8C86A);
  static const doradoOscuro = Color(0xFFA67C00);
  static const negro = Color(0xFF1A1A1A);
  static const blanco = Color(0xFFFFFFFF);
  static const grisClaro = Color(0xFFF5F5F5);
  static const grisMedio = Color(0xFFBDBDBD);
  static const grisOscuro = Color(0xFF424242);

  // === MODO OSCURO ===
  static const fondoOscuro = Color(0xFF0F0F0F);
  static const fondoCardOscuro = Color(0xFF1A1A1A);
  static const fondoCardOscuroElevado = Color(0xFF242424);
  static const textoOscuroClaro = Color(0xFFE8E8E8);
  static const textoOscuroMedio = Color(0xFFB0B0B0);

  // === GRADIENTES ===
  static const gradienteGranate = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [granateOscuro, granate],
  );

  static const gradienteOscuro = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [negro, granateOscuro],
  );

  static const gradienteDorado = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [dorado, doradoOscuro],
  );

  // === HELPERS DE TEXTO ===
  static Color textoPrincipal(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textoOscuroClaro
        : negro;
  }

  static Color textoSecundario(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textoOscuroMedio
        : negro.withOpacity(0.65);
  }

  static Color textoTerciario(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textoOscuroMedio.withOpacity(0.7)
        : negro.withOpacity(0.5);
  }

  static Color borde(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? dorado.withOpacity(0.35)
        : dorado.withOpacity(0.55);
  }

  static Color cardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? fondoCardOscuro
        : blanco;
  }

  static Color fondoApp(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? fondoOscuro
        : const Color(0xFFFAFAFA);
  }
}