import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:permission_handler/permission_handler.dart';
import 'models/usuario.dart';
import 'services/auth_service.dart';
import 'services/screen_security_service.dart';
import 'services/usuario_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'theme/colors.dart';
import 'theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.sikuris.sikuris_app.channel.audio',
      androidNotificationChannelName: 'Reproducción de audio',
      androidNotificationOngoing: true,
    );
  } catch (e) {
    debugPrint('⚠️ Error al inicializar audio background: $e');
  }

  await ThemeProvider.cargar();

  try {
    final status = await Permission.notification.status;
    if (status.isDenied) {
      await Permission.notification.request();
    }
  } catch (e) {
    debugPrint('⚠️ Error pidiendo permiso: $e');
  }

  runApp(const SikurisApp());
}

class SikurisApp extends StatelessWidget {
  const SikurisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeProvider.mode,
      builder: (context, modo, _) {
        return MaterialApp(
          title: 'Allin Kawsay',
          debugShowCheckedModeBanner: false,
          theme: _temaClaro(),
          darkTheme: _temaOscuro(),
          themeMode: modo,
          home: const _AuthGate(),
        );
      },
    );
  }

  ThemeData _temaClaro() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFFAFAFA),
      colorScheme: const ColorScheme.light(
        primary: AppColors.granate,
        onPrimary: AppColors.dorado,
        secondary: AppColors.dorado,
        onSecondary: AppColors.negro,
        surface: AppColors.blanco,
        onSurface: AppColors.negro,
        surfaceVariant: Color(0xFFF0F0F0),
        onSurfaceVariant: AppColors.negro,
        outline: AppColors.dorado,
      ),
      // === TIPOGRAFÍA ===
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: -1,
          color: AppColors.negro,
        ),
        headlineMedium: TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          color: AppColors.negro,
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          color: AppColors.negro,
        ),
        titleMedium: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.negro,
        ),
        bodyLarge: TextStyle(
          letterSpacing: 0.2,
          color: AppColors.negro,
        ),
        bodyMedium: TextStyle(
          letterSpacing: 0.15,
          color: AppColors.negro,
        ),
      ),
      // === APP BAR ===
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.dorado,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.dorado,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.5,
        ),
        iconTheme: IconThemeData(color: AppColors.dorado),
      ),
      // === CARDS ===
      cardTheme: CardTheme(
        color: AppColors.blanco,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
              color: AppColors.dorado.withOpacity(0.25), width: 1),
        ),
      ),
      // === BOTONES ===
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.granate,
          foregroundColor: AppColors.dorado,
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.granate,
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: const BorderSide(color: AppColors.granate, width: 1.5),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.granate,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      // === NAV BAR ===
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.negro,
        elevation: 8,
        height: 68,
        indicatorColor: AppColors.granate,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(
            color: AppColors.dorado,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected)
                ? AppColors.dorado
                : AppColors.dorado.withOpacity(0.55),
          );
        }),
      ),
      // === LIST TILES ===
      listTileTheme: ListTileThemeData(
        iconColor: AppColors.granate,
        textColor: AppColors.negro,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      // === OTROS ===
      dividerColor: AppColors.dorado.withOpacity(0.25),
      dividerTheme: DividerThemeData(
        color: AppColors.dorado.withOpacity(0.25),
        thickness: 1,
        space: 24,
      ),
      // === INPUTS ===
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.blanco,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        labelStyle: const TextStyle(color: AppColors.granate),
        floatingLabelStyle:
            const TextStyle(color: AppColors.granate, fontWeight: FontWeight.bold),
        hintStyle: TextStyle(color: AppColors.negro.withOpacity(0.4)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.dorado, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              BorderSide(color: AppColors.dorado.withOpacity(0.5), width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      // === FAB ===
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.granate,
        foregroundColor: AppColors.dorado,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      // === SNACKBAR ===
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.negro,
        contentTextStyle: const TextStyle(
          color: AppColors.dorado,
          fontWeight: FontWeight.w500,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      // === CHIPS ===
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.granate.withOpacity(0.08),
        selectedColor: AppColors.granate,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
        side: BorderSide(color: AppColors.granate.withOpacity(0.3)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      // === DIALOG ===
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.blanco,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.granate,
        ),
        contentTextStyle: TextStyle(
          fontSize: 15,
          color: AppColors.negro.withOpacity(0.8),
          height: 1.5,
        ),
      ),
      // === BOTTOM SHEET ===
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.blanco,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        showDragHandle: false,
      ),
      // === TABBAR ===
      tabBarTheme: const TabBarTheme(
        labelColor: AppColors.dorado,
        unselectedLabelColor: Colors.white70,
        indicatorColor: AppColors.dorado,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          fontSize: 12,
        ),
      ),
    );
  }

  ThemeData _temaOscuro() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.fondoOscuro,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.granate,
        onPrimary: AppColors.dorado,
        secondary: AppColors.dorado,
        onSecondary: AppColors.negro,
        surface: AppColors.fondoCardOscuro,
        onSurface: AppColors.textoOscuroClaro,
        surfaceVariant: AppColors.fondoCardOscuroElevado,
        onSurfaceVariant: AppColors.textoOscuroClaro,
        outline: AppColors.dorado,
        error: Color(0xFFCF6679),
        onError: AppColors.negro,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: -1,
          color: AppColors.textoOscuroClaro,
        ),
        headlineMedium: TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          color: AppColors.textoOscuroClaro,
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          color: AppColors.textoOscuroClaro,
        ),
        titleMedium: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textoOscuroClaro,
        ),
        bodyLarge: TextStyle(
          letterSpacing: 0.2,
          color: AppColors.textoOscuroClaro,
        ),
        bodyMedium: TextStyle(
          letterSpacing: 0.15,
          color: AppColors.textoOscuroClaro,
        ),
        bodySmall: TextStyle(
          color: AppColors.textoOscuroMedio,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.dorado,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.dorado,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.5,
        ),
        iconTheme: IconThemeData(color: AppColors.dorado),
      ),
      cardTheme: CardTheme(
        color: AppColors.fondoCardOscuro,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
              color: AppColors.dorado.withOpacity(0.35), width: 1),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.granate,
          foregroundColor: AppColors.dorado,
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.dorado,
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: const BorderSide(color: AppColors.dorado, width: 1.5),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.dorado,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.negro,
        elevation: 8,
        height: 68,
        indicatorColor: AppColors.granate,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(
            color: AppColors.dorado,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected)
                ? AppColors.dorado
                : AppColors.dorado.withOpacity(0.55),
          );
        }),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: AppColors.dorado,
        textColor: AppColors.textoOscuroClaro,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      dividerColor: AppColors.dorado.withOpacity(0.3),
      dividerTheme: DividerThemeData(
        color: AppColors.dorado.withOpacity(0.3),
        thickness: 1,
        space: 24,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.fondoCardOscuro,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        labelStyle: const TextStyle(color: AppColors.dorado),
        floatingLabelStyle:
            const TextStyle(color: AppColors.dorado, fontWeight: FontWeight.bold),
        hintStyle: TextStyle(color: AppColors.textoOscuroMedio.withOpacity(0.6)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.dorado, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              BorderSide(color: AppColors.dorado.withOpacity(0.5), width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.granate,
        foregroundColor: AppColors.dorado,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.granateOscuro,
        contentTextStyle: const TextStyle(
          color: AppColors.dorado,
          fontWeight: FontWeight.w500,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.granate.withOpacity(0.3),
        selectedColor: AppColors.granate,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
        side: BorderSide(color: AppColors.dorado.withOpacity(0.3)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.fondoCardOscuro,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.dorado,
        ),
        contentTextStyle: TextStyle(
          fontSize: 15,
          color: AppColors.textoOscuroClaro.withOpacity(0.85),
          height: 1.5,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.fondoCardOscuro,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        showDragHandle: false,
      ),
      tabBarTheme: const TabBarTheme(
        labelColor: AppColors.dorado,
        unselectedLabelColor: Colors.white54,
        indicatorColor: AppColors.dorado,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  StreamSubscription? _userSub;
  String? _ultimoRol;

  @override
  void initState() {
    super.initState();
    _userSub = UsuarioService().miUsuario().listen((u) {
      final rol = u?.rol;
      if (rol == _ultimoRol) return;
      _ultimoRol = rol;

      if (rol == 'publico') {
        ScreenSecurityService.enable();
      } else {
        ScreenSecurityService.disable();
      }
    });
  }

  @override
  void dispose() {
    _userSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.negro,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.dorado),
            ),
          );
        }

        if (authSnap.hasData && authSnap.data != null) {
          return StreamBuilder<Usuario?>(
            stream: UsuarioService().miUsuario(),
            builder: (context, userSnap) {
              if (userSnap.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  backgroundColor: AppColors.negro,
                  body: Center(
                    child: CircularProgressIndicator(
                        color: AppColors.dorado),
                  ),
                );
              }

              final u = userSnap.data;
              if (u != null && u.baneado) {
                return const CuentaSuspendidaScreen();
              }

              final authUser = authSnap.data!;
              return HomeScreen(
                nombreUsuario: authUser.displayName ??
                    authUser.email?.split('@').first ??
                    'Usuario',
              );
            },
          );
        }

        ScreenSecurityService.disable();
        return const LoginScreen();
      },
    );
  }
}

class CuentaSuspendidaScreen extends StatelessWidget {
  const CuentaSuspendidaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.negro,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withOpacity(0.15),
                    border: Border.all(color: Colors.red, width: 3),
                  ),
                  child: const Icon(Icons.block,
                      size: 60, color: Colors.red),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Cuenta suspendida',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dorado,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Tu acceso a la app fue suspendido por un '
                  'administrador del grupo.\n\n'
                  'Si crees que es un error, contactate con '
                  'la directiva.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.dorado.withOpacity(0.7),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text('CERRAR SESIÓN',
                        style: TextStyle(letterSpacing: 1.5)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.dorado,
                      side: const BorderSide(
                          color: AppColors.dorado, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () async {
                      await AuthService().logout();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}