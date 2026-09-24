import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'theme/colors.dart';

void main() => runApp(const SikurisApp());

class SikurisApp extends StatelessWidget {
  const SikurisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sikuris',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
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
      ),
      home: const LoginScreen(),
    );
  }
}
