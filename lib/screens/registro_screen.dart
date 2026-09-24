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
        // main.dart detecta el registro y navega solo
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CREAR CUENTA')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 12),
            const Text(
              'Únete al grupo',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.granate,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Crea tu cuenta para acceder al cancionero, '
              'subir partituras y comentar.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.negro.withOpacity(0.6)),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _nombre,
              textCapitalization: TextCapitalization.words,
              decoration: _deco('Nombre completo', Icons.person),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: _deco('Email', Icons.email),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pass,
              obscureText: true,
              decoration: _deco('Contraseña (mín. 6)', Icons.lock),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pass2,
              obscureText: true,
              decoration: _deco('Repetir contraseña', Icons.lock_outline),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _deco(String label, IconData icono) {
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
