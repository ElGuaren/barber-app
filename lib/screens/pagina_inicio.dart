import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pantalla_perfil.dart';
import 'pantalla_locales.dart';
import 'pantalla_mis_reservas.dart';

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  int _paginaActual = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _construirAppBar(),
      body: _construirContenido(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _paginaActual,
        onTap: (index) => setState(() => _paginaActual = index),
        selectedItemColor: Colors.blue,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Reservas'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  PreferredSizeWidget? _construirAppBar() {
    switch (_paginaActual) {
      case 0:
        return AppBar(
          title: const Text('Bienvenido!'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Cerrar sesión',
              onPressed: _cerrarSesion,
            ),
          ],
        );
      case 1:
        return AppBar(
          title: const Text('Mis reservas'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        );
      case 2:
        return AppBar(
          title: const Text('Perfil'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        );
      default:
        return null;
    }
  }

  Widget _construirContenido() {
    switch (_paginaActual) {
      case 0:
        return const _InicioContenido();
      case 1:
        return const PantallaMisReservas();
      case 2:
        return const PantallaPerfil();
      default:
        return const _InicioContenido();
    }
  }

  void _cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }
}

class _InicioContenido extends StatelessWidget {
  const _InicioContenido();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          _opcionCard(
            icono: Icons.calendar_today,
            titulo: 'Agendar horas',
            subtitulo: 'Schedule appointments',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PantallaLocales()),
              );
            },
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
    );
  }

  static Widget _opcionCard({
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
