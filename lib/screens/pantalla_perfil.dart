import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PantallaPerfil extends StatefulWidget {
  const PantallaPerfil({super.key});

  @override
  State<PantallaPerfil> createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends State<PantallaPerfil> {
  final user = FirebaseAuth.instance.currentUser;
  String? nombreUsuario;
  String? telefonoUsuario;
  bool editandoNombre = false;
  bool editandoTelefono = false;

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  Future<void> cargarDatos() async {
    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(user?.uid).get();
    if (doc.exists) {
      setState(() {
        nombreUsuario = doc['nombre'];
        telefonoUsuario = doc.data()?['telefono'] ?? ''; // <- corrección aquí
        _nombreController.text = nombreUsuario ?? '';
        _telefonoController.text = telefonoUsuario ?? '';
      });
    }
  }

  Future<void> guardarCampo(String campo, String valor) async {
    if (user != null && valor.isNotEmpty) {
      await FirebaseFirestore.instance.collection('usuarios').doc(user!.uid).update({
        campo: valor,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$campo actualizado'), backgroundColor: const Color(0xFFC89B65)),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2C),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 48),
            const Icon(Icons.account_circle, size: 100, color: Color(0xFFC89B65)),
            const SizedBox(height: 12),
            Text(
              nombreUsuario ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Nombre", style: TextStyle(color: Colors.white60)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: editandoNombre
                          ? TextField(
                              controller: _nombreController,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                filled: true,
                                fillColor: Colors.white24,
                                hintStyle: TextStyle(color: Colors.white),
                                border: OutlineInputBorder(borderSide: BorderSide.none),
                              ),
                            )
                          : Text(
                              nombreUsuario ?? '',
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                    ),
                    IconButton(
                      icon: Icon(editandoNombre ? Icons.check : Icons.edit, color: Colors.white60),
                      onPressed: () {
                        if (editandoNombre) {
                          guardarCampo('nombre', _nombreController.text.trim());
                          setState(() {
                            nombreUsuario = _nombreController.text.trim();
                            editandoNombre = false;
                          });
                        } else {
                          setState(() => editandoNombre = true);
                        }
                      },
                    )
                  ],
                ),
                const SizedBox(height: 16),

                const Text("Correo", style: TextStyle(color: Colors.white60)),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 16),

                const Text("Teléfono", style: TextStyle(color: Colors.white60)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: editandoTelefono
                          ? TextField(
                              controller: _telefonoController,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                filled: true,
                                fillColor: Colors.white24,
                                hintStyle: TextStyle(color: Colors.white),
                                border: OutlineInputBorder(borderSide: BorderSide.none),
                              ),
                            )
                          : Text(
                              telefonoUsuario?.isNotEmpty == true ? telefonoUsuario! : 'No registrado',
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                    ),
                    IconButton(
                      icon: Icon(editandoTelefono ? Icons.check : Icons.edit, color: Colors.white60),
                      onPressed: () {
                        if (editandoTelefono) {
                          guardarCampo('telefono', _telefonoController.text.trim());
                          setState(() {
                            telefonoUsuario = _telefonoController.text.trim();
                            editandoTelefono = false;
                          });
                        } else {
                          setState(() => editandoTelefono = true);
                        }
                      },
                    )
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
