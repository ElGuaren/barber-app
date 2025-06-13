import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PantallaPerfil extends StatefulWidget {
  const PantallaPerfil({super.key});

  @override
  State<PantallaPerfil> createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends State<PantallaPerfil> {
  String? _nombreUsuario;
  final _nombreController = TextEditingController();
  bool _editando = false;

  @override
  void initState() {
    super.initState();
    _cargarNombre();
  }

  Future<void> _cargarNombre() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .get();

    if (doc.exists && doc.data()?['nombre'] != null) {
      setState(() {
        _nombreUsuario = doc.data()!['nombre'];
      });
    }
  }

  Future<void> _guardarNombre() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final nombre = _nombreController.text.trim();
    if (nombre.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .set({'nombre': nombre});

    setState(() {
      _nombreUsuario = nombre;
      _editando = false;
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de usuario'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_circle, size: 100, color: Colors.grey),
              const SizedBox(height: 16),
              _editando
                  ? Column(
                      children: [
                        TextField(
                          controller: _nombreController,
                          decoration:
                              const InputDecoration(labelText: 'Ingresa tu nombre'),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _guardarNombre,
                          child: const Text('Guardar nombre'),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _nombreUsuario ?? 'Nombre no configurado',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18),
                          onPressed: () {
                            _nombreController.text = _nombreUsuario ?? '';
                            setState(() => _editando = true);
                          },
                          tooltip: 'Editar nombre',
                        ),
                      ],
                    ),
              const SizedBox(height: 8),
              Text(
                user?.email ?? 'Correo no disponible',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
