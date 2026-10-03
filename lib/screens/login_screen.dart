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
  bool _verPassword = false;

  Future<void> _login() async {
    if (_email.text.trim().isEmpty || _pass.text.trim().isEmpty) {
      _snack('Ingresa email y contraseña');
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthService().login(_email.text.trim(), _pass.text.trim());
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
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
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
              Color(0xFF0F0F0F),
              AppColors.granateOscuro,
              AppColors.granate,
            ],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.dorado.withOpacity(0.25),
                          blurRadius: 30,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const SikuriLogo(size: 130),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'SIKURIS',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dorado,
                      letterSpacing: 10,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'ALLIN KAWSAY',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.dorado.withOpacity(0.65),
                      letterSpacing: 6,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Card de login
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.blanco,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.dorado.withOpacity(0.4),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Email
                        TextField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(
                            color: AppColors.negro,
                            fontSize: 15,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: const TextStyle(
                                color: AppColors.granate,
                                fontWeight: FontWeight.w600),
                            floatingLabelStyle: const TextStyle(
                                color: AppColors.granate,
                                fontWeight: FontWeight.bold),
                            prefixIcon: const Icon(Icons.email_outlined,
                                color: AppColors.granate),
                            hintText: 'tu@email.com',
                            hintStyle: TextStyle(
                                color:
                                    AppColors.negro.withOpacity(0.35)),
                            filled: true,
                            fillColor: AppColors.grisClaro,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                  color: AppColors.dorado, width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                  color:
                                      AppColors.dorado.withOpacity(0.5)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Contraseña
                        TextField(
                          controller: _pass,
                          obscureText: !_verPassword,
                          style: const TextStyle(
                            color: AppColors.negro,
                            fontSize: 15,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            labelStyle: const TextStyle(
                                color: AppColors.granate,
                                fontWeight: FontWeight.w600),
                            floatingLabelStyle: const TextStyle(
                                color: AppColors.granate,
                                fontWeight: FontWeight.bold),
                            prefixIcon: const Icon(Icons.lock_outline,
                                color: AppColors.granate),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _verPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.granate.withOpacity(0.6),
                              ),
                              onPressed: () => setState(
                                  () => _verPassword = !_verPassword),
                            ),
                            filled: true,
                            fillColor: AppColors.grisClaro,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                  color: AppColors.dorado, width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                  color:
                                      AppColors.dorado.withOpacity(0.5)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        // Botón
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: FilledButton(
                            onPressed: _loading ? null : _login,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.granate,
                              foregroundColor: AppColors.dorado,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: AppColors.dorado,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    'ENTRAR',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 3,
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
                            style: TextStyle(
                              color: AppColors.granate,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.music_note,
                          size: 14,
                          color: AppColors.dorado.withOpacity(0.4)),
                      const SizedBox(width: 6),
                      Text(
                        'Cancionero del grupo',
                        style: TextStyle(
                          color: AppColors.dorado.withOpacity(0.4),
                          fontSize: 11,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}