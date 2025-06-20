import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'agregar_horas_page.dart';
import 'reservas_barbero_page.dart';
import 'perfil_barbero_page.dart';

class PantallaInicioBarbero extends StatefulWidget {
  const PantallaInicioBarbero({super.key});

  @override
  State<PantallaInicioBarbero> createState() => _PantallaInicioBarberoState();
}

class _PantallaInicioBarberoState extends State<PantallaInicioBarbero> {
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
          title: const Text('Reservas'),
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
        return const AgregarHorasPage();
      case 1:
        return const ReservasBarberoPage();
      case 2:
        return const PerfilBarberoPage();
      default:
        return const AgregarHorasPage();
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
