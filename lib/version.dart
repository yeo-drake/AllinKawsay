import 'version_build.dart';

class AppVersion {
  // ⚠️ EDITAR MANUALMENTE cuando haya actualizaciones importantes
  //
  // MAJOR: cambios mega grandes. Es raro cambiarlo.
  // MINOR: nuevas funcionalidades grandes (ej: agregar un módulo nuevo)
  // PATCH: correcciones o cambios chicos
  //
  // El cuarto número (build) se genera automático desde GitHub Actions.

  static const String major = '1';
  static const String minor = '0';
  static const String patch = '0';

  static const int build = VersionBuild.build;

  /// Versión completa: 1.0.0.463
  static String get full => '$major.$minor.$patch.$build';

  /// Versión corta sin build: 1.0.0
  static String get short => '$major.$minor.$patch';
}