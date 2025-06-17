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
      backgroundColor: const Color(0xFF2C2C2C),
      body: Column(
        children: [
          const Divider(height: 1, color: Color(0xFFBDBDBD)),
          Expanded(child: _construirContenido()),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(height: 1, color: Color(0xFFBDBDBD)),
          BottomNavigationBar(
            currentIndex: _paginaActual,
            onTap: (index) => setState(() => _paginaActual = index),
            selectedItemColor: const Color(0xFFC89B65),
            unselectedItemColor: Colors.grey,
            backgroundColor: const Color(0xFF212121),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
              BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Reservas'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
            ],
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget? _construirAppBar() {
    return AppBar(
      title: Text(
        _paginaActual == 0
            ? 'APPBarber!'
            : _paginaActual == 1
                ? 'Mis reservas'
                : 'Perfil',
      ),
      backgroundColor: const Color(0xFF212121),
      foregroundColor: Colors.white,
      actions: _paginaActual == 0
          ? [
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Cerrar sesión',
                onPressed: _confirmarCerrarSesion,
              ),
            ]
          : null,
    );
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

  void _confirmarCerrarSesion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cerrar sesión"),
        content: const Text("¿Estás seguro de que deseas cerrar sesión?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC89B65)),
            onPressed: () async {
              Navigator.pop(context); // cerrar diálogo
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/');
              }
            },
            child: const Text("Cerrar sesión", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icono, size: 40, color: Color(0xFFC89B65)),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                  Text(
                    subtitulo,
                    style: const TextStyle(color: Color(0xFF2C2C2C)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
