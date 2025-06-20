import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pagina_inicio_barbero.dart';

class CrearLocalPage extends StatefulWidget {
  const CrearLocalPage({super.key});

  @override
  State<CrearLocalPage> createState() => _CrearLocalPageState();
}

class _CrearLocalPageState extends State<CrearLocalPage> {
  final TextEditingController _nombreLocalController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> _guardarLocal() async {
    final nombre = _nombreLocalController.text.trim();
    final descripcion = _descripcionController.text.trim();
    final uid = _auth.currentUser?.uid;

    if (nombre.isEmpty || descripcion.isEmpty || uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    try {
      final nuevoLocal = await _firestore.collection('locales').add({
        'nombre': nombre,
        'descripcion': descripcion,
        'uidBarbero': uid,
        'horas': [],
      });

      await _firestore.collection('usuarios').doc(uid).update({
        'idLocal': nuevoLocal.id,
      });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PantallaInicioBarbero()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al guardar el local: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registrar Barbería")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nombreLocalController,
              decoration: const InputDecoration(
                labelText: "Nombre del local",
                prefixIcon: Icon(Icons.store),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descripcionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Descripción del local",
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _guardarLocal,
              icon: const Icon(Icons.check),
              label: const Text("Guardar y continuar"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC89B65),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
