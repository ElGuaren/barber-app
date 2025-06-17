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
    switch (_paginaActual) {
      case 0:
        return AppBar(
          title: const Text('APPBarber!'),
          backgroundColor: const Color(0xFF212121),
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
          backgroundColor: const Color(0xFF212121),
          foregroundColor: Colors.white,
        );
      case 2:
        return AppBar(
          title: const Text('Perfil'),
          backgroundColor: const Color(0xFF212121),
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
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cerrar sesión"),
        content: const Text("¿Estás seguro que deseas cerrar sesión?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC89B65),
              foregroundColor: Colors.white,
            ),
            child: const Text("Cerrar sesión"),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
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
        children: [
          _opcionCard(
            icono: Icons.calendar_today,
            titulo: 'Agendar horas',
            subtitulo: 'Agenda tu hora en los locales disponibles!',
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
            subtitulo: 'Localiza los locales más cercanos!',
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
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: double.infinity,
          height: 160,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitulo,
                style: const TextStyle(fontSize: 14, color: Color(0xFF707070)),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomLeft,
                child: Icon(icono, size: 40, color: Color(0xFFC89B65)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
