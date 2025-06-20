import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'pagina_inicio.dart';           // Para clientes
import 'pagina_inicio_barbero.dart';  // Para barberos
import 'crear_local_page.dart';       // NUEVO: para barberos sin local

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _mostrarClave = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesionEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _mostrarMensaje("Completa todos los campos");
      return;
    }

    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _verificarTipoYRedirigir(cred.user!.uid);
    } on FirebaseAuthException catch (e) {
      _mostrarMensaje("Error: ${e.message}");
    }
  }

  Future<void> _iniciarSesionGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final cred = await FirebaseAuth.instance.signInWithCredential(credential);

      await _verificarTipoYRedirigir(cred.user!.uid);
    } catch (e) {
      _mostrarMensaje("Error al iniciar sesión con Google: $e");
    }
  }

  Future<void> _verificarTipoYRedirigir(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
    final datos = doc.data();
    final tipo = datos?['tipo'] ?? 'cliente';

    if (tipo == 'barbero') {
      final idLocal = datos?['idLocal'] ?? '';
      if (idLocal.isEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CrearLocalPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PantallaInicioBarbero()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PantallaInicio()),
      );
    }
  }

  void _mostrarMensaje(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
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
                    const Text(
                      "¡Bienvenido a APPBarber!",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
                    ),
                    const SizedBox(height: 24),

                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputStyle("Correo electrónico", Icons.email),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _passwordController,
                      obscureText: !_mostrarClave,
                      decoration: _inputStyle(
                        "Contraseña",
                        Icons.lock,
                        iconAdicional: IconButton(
                          icon: Icon(_mostrarClave ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _mostrarClave = !_mostrarClave),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _iniciarSesionEmail,
                        icon: const Icon(Icons.login),
                        label: const Text("Iniciar sesión"),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFC89B65),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text("O también", style: TextStyle(color: Colors.black54)),
                    const SizedBox(height: 12),

                    FilledButton.icon(
                      onPressed: _iniciarSesionGoogle,
                      icon: const Icon(Icons.login),
                      label: const Text("Continuar con Google"),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF212121),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                      ),
                    ),

                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/register'),
                      child: const Text("¿No tienes cuenta? Regístrate"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/recuperar'),
                      child: const Text("¿Olvidaste tu contraseña?"),
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
