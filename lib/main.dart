import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() => runApp(const SikurisApp());

class SikurisApp extends StatelessWidget {
  const SikurisApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sikuris',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B4513),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
