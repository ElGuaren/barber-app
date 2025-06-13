import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pantalla_perfil.dart';
import 'pantalla_locales.dart';

class PantallaInicio extends StatelessWidget {
  const PantallaInicio({super.key});

  void _cerrarSesion(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  void _irAlPerfil(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PantallaPerfil()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bienvenido!'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Perfil de usuario',
            onPressed: () => _irAlPerfil(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () => _cerrarSesion(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            _opcionCard(
              icono: Icons.calendar_today,
              titulo: 'Agendar horas',
              subtitulo: 'Schedule appointments',
              onTap: () {Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const PantallaLocales()),
  );},
            ),
            const SizedBox(height: 20),
            _opcionCard(
              icono: Icons.location_on,
              titulo: 'Locales cercanos',
              subtitulo: 'Nearby locations',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _opcionCard({
    required IconData icono,
    required String titulo,
    required String subtitulo,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icono, size: 40, color: Colors.blue),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(subtitulo, style: const TextStyle(color: Colors.grey)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}