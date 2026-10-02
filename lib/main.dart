import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:permission_handler/permission_handler.dart';
import 'models/usuario.dart';
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
      scaffoldBackgroundColor: AppColors.blanco,
      colorScheme: const ColorScheme.light(
        primary: AppColors.granate,
        onPrimary: AppColors.dorado,
        secondary: AppColors.dorado,
        onSecondary: AppColors.negro,
        surface: AppColors.blanco,
        onSurface: AppColors.negro,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.granate,
        foregroundColor: AppColors.dorado,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.dorado,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.blanco,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.dorado, width: 0.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.granate,
          foregroundColor: AppColors.dorado,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.granate,
          side: const BorderSide(color: AppColors.granate, width: 1.5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.negro,
        indicatorColor: AppColors.granate,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(color: AppColors.dorado, fontSize: 12),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.dorado
                : AppColors.dorado.withOpacity(0.5),
          );
        }),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.granate,
        textColor: AppColors.negro,
      ),
      dividerColor: AppColors.dorado,
      inputDecorationTheme: const InputDecorationTheme(
        labelStyle: TextStyle(color: AppColors.granate),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.dorado, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.dorado),
        ),
        border: OutlineInputBorder(),
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
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.negro,
        foregroundColor: AppColors.dorado,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.dorado,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.fondoCardOscuro,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.dorado, width: 0.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.granate,
          foregroundColor: AppColors.dorado,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.dorado,
          side: const BorderSide(color: AppColors.dorado, width: 1.5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.negro,
        indicatorColor: AppColors.granate,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(color: AppColors.dorado, fontSize: 12),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.dorado
                : AppColors.dorado.withOpacity(0.5),
          );
        }),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.dorado,
        textColor: AppColors.textoOscuroClaro,
      ),
      dividerColor: AppColors.dorado,
      inputDecorationTheme: const InputDecorationTheme(
        labelStyle: TextStyle(color: AppColors.dorado),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.dorado, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.dorado),
        ),
        border: OutlineInputBorder(),
      ),
    );
  }
}

/// Escucha auth + rol del usuario, y activa/desactiva bloqueo de
/// capturas según el rol. Los "público" no pueden sacar capturas.
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
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.negro,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.dorado),
            ),
          );
        }
        if (snap.hasData && snap.data != null) {
          final u = snap.data!;
          return HomeScreen(
            nombreUsuario: u.displayName ??
                u.email?.split('@').first ??
                'Usuario',
          );
        }
        // Cuando no hay sesión → desactivar bloqueo
        ScreenSecurityService.disable();
        return const LoginScreen();
      },
    );
  }
}