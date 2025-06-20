import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmarPasswordController = TextEditingController();

  bool _verPassword = false;
  bool _verConfirmar = false;

  String _tipoUsuario = 'cliente'; // valor por defecto

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmarPasswordController.dispose();
    super.dispose();
  }

  Future<void> fnRegistrarUsuario() async {
    final nombre = _nombreController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmar = _confirmarPasswordController.text.trim();

    if (nombre.isEmpty || email.isEmpty || password.isEmpty || confirmar.isEmpty) {
      _mostrarMensaje("Por favor, completa todos los campos");
      return;
    }

    if (password != confirmar) {
      _mostrarMensaje("Las contraseñas no coinciden");
      return;
    }

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseFirestore.instance.collection('usuarios').doc(cred.user!.uid).set({
        'nombre': nombre,
        'email': email,
        'tipo': _tipoUsuario, // Guardamos si es barbero o cliente
      });

      _mostrarMensaje("Registro exitoso");

      if (mounted) Navigator.pushReplacementNamed(context, '/');
    } on FirebaseAuthException catch (e) {
      _mostrarMensaje(e.message ?? "Error desconocido");
    }
  }

  void _mostrarMensaje(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: const Color(0xFFC89B65)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/fondo_barberia.jpg',
            fit: BoxFit.cover,
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(16),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Icon(Icons.account_circle, size: 64, color: Color(0xFFC89B65)),
                    const SizedBox(height: 16),
                    const Text('Registrar Usuario',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF212121))),
                    const SizedBox(height: 32),

                    TextField(
                      controller: _nombreController,
                      decoration: _inputStyle("Nombre completo", Icons.person),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _emailController,
                      decoration: _inputStyle("Correo electrónico", Icons.email),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _passwordController,
                      obscureText: !_verPassword,
                      decoration: _inputStyle(
                        "Contraseña",
                        Icons.lock,
                        iconAdicional: IconButton(
                          icon: Icon(_verPassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _verPassword = !_verPassword),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _confirmarPasswordController,
                      obscureText: !_verConfirmar,
                      decoration: _inputStyle(
                        "Confirmar contraseña",
                        Icons.lock_outline,
                        iconAdicional: IconButton(
                          icon: Icon(_verConfirmar ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _verConfirmar = !_verConfirmar),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: _tipoUsuario,
                      items: const [
                        DropdownMenuItem(value: 'cliente', child: Text('Cliente')),
                        DropdownMenuItem(value: 'barbero', child: Text('Barbero')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _tipoUsuario = value);
                        }
                      },
                      decoration: _inputStyle("Tipo de usuario", Icons.person_outline),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: fnRegistrarUsuario,
                        icon: const Icon(Icons.login),
                        label: const Text("Registrar"),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFC89B65),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("¿Ya tienes cuenta? Inicia sesión"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputStyle(String label, IconData icono, {Widget? iconAdicional}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icono),
      suffixIcon: iconAdicional,
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: BorderSide.none,
      ),
    );
  }
}
