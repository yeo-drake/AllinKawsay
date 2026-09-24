import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../theme/colors.dart';
import '../widgets/logo.dart';
import 'registro_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    if (_email.text.trim().isEmpty || _pass.text.trim().isEmpty) {
      _snack('Ingresa email y contraseña');
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthService().login(_email.text.trim(), _pass.text.trim());
      // main.dart detecta el cambio y navega solo
    } on FirebaseAuthException catch (e) {
      String msg = 'Error al iniciar sesión';
      switch (e.code) {
        case 'user-not-found':
          msg = 'No existe una cuenta con ese email';
          break;
        case 'wrong-password':
          msg = 'Contraseña incorrecta';
          break;
        case 'invalid-email':
          msg = 'Email inválido';
          break;
        case 'invalid-credential':
          msg = 'Email o contraseña incorrectos';
          break;
      }
      _snack(msg);
    } catch (e) {
      _snack('Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.negro,
              AppColors.granateOscuro,
              AppColors.granate,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SikuriLogo(size: 140),
                  const SizedBox(height: 20),
                  const Text(
                    'SIKURIS',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dorado,
                      letterSpacing: 6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Cancionero del grupo',
                    style: TextStyle(
                      color: AppColors.dorado.withOpacity(0.7),
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDeco(
                                'Email', Icons.email),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _pass,
                            obscureText: true,
                            decoration:
                                _inputDeco('Contraseña', Icons.lock),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: FilledButton(
                              onPressed: _loading ? null : _login,
                              child: _loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child:
                                          CircularProgressIndicator(
                                        color: AppColors.dorado,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text(
                                      'ENTRAR',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: _loading
                                ? null
                                : () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const RegistroScreen(),
                                      ),
                                    ),
                            child: const Text(
                              '¿No tienes cuenta? Regístrate',
                              style: TextStyle(color: AppColors.granate),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label, IconData icono) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.granate),
      prefixIcon: Icon(icono, color: AppColors.granate),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.dorado, width: 2),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.dorado),
      ),
      border: const OutlineInputBorder(),
    );
  }
}
