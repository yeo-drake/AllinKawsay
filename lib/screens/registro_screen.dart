import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../theme/colors.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});
  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _nombre = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _pass2 = TextEditingController();
  bool _loading = false;
  bool _verPass = false;

  Future<void> _registrar() async {
    final nombre = _nombre.text.trim();
    final email = _email.text.trim();
    final pass = _pass.text;
    final pass2 = _pass2.text;

    if (nombre.isEmpty || email.isEmpty || pass.isEmpty) {
      _snack('Completa todos los campos');
      return;
    }
    if (pass.length < 6) {
      _snack('La contraseña debe tener al menos 6 caracteres');
      return;
    }
    if (pass != pass2) {
      _snack('Las contraseñas no coinciden');
      return;
    }

    setState(() => _loading = true);
    try {
      await AuthService().registrar(email, pass, nombre);
      if (mounted) {
        _snack('¡Cuenta creada! Bienvenido/a $nombre');
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String msg = 'Error al registrarte';
      switch (e.code) {
        case 'email-already-in-use':
          msg = 'Ese email ya está registrado';
          break;
        case 'weak-password':
          msg = 'Contraseña muy débil';
          break;
        case 'invalid-email':
          msg = 'Email inválido';
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
    _nombre.dispose();
    _email.dispose();
    _pass.dispose();
    _pass2.dispose();
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
                  // Ícono
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.08),
                      border: Border.all(
                          color: AppColors.dorado.withOpacity(0.3)),
                    ),
                    child: const Icon(Icons.person_add_alt_1,
                        size: 42, color: AppColors.dorado),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'ÚNETE AL GRUPO',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dorado,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crea tu cuenta para acceder al cancionero',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.dorado.withOpacity(0.6),
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: AppColors.dorado.withOpacity(0.25)),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _nombre,
                          textCapitalization:
                              TextCapitalization.words,
                          style: const TextStyle(color: Colors.white),
                          decoration: _deco('Nombre completo', Icons.person),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white),
                          decoration: _deco('Email', Icons.email),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _pass,
                          obscureText: !_verPass,
                          style: const TextStyle(color: Colors.white),
                          decoration: _deco(
                              'Contraseña (mín. 6)', Icons.lock).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _verPass
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color:
                                    AppColors.dorado.withOpacity(0.6),
                              ),
                              onPressed: () => setState(
                                  () => _verPass = !_verPass),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _pass2,
                          obscureText: !_verPass,
                          style: const TextStyle(color: Colors.white),
                          decoration: _deco('Repetir contraseña',
                              Icons.lock_outline),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: FilledButton(
                            onPressed: _loading ? null : _registrar,
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
                                    'CREAR CUENTA',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 3,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton.icon(
                    onPressed: _loading
                        ? null
                        : () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back,
                        size: 16,
                        color: AppColors.dorado.withOpacity(0.7)),
                    label: Text(
                      'Ya tengo cuenta',
                      style: TextStyle(
                        color: AppColors.dorado.withOpacity(0.7),
                        fontSize: 13,
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

  InputDecoration _deco(String label, IconData icono) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppColors.dorado.withOpacity(0.8)),
      prefixIcon:
          Icon(icono, color: AppColors.dorado.withOpacity(0.8), size: 20),
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
    );
  }
}