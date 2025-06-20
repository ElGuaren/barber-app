import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PerfilBarberoPage extends StatefulWidget {
  const PerfilBarberoPage({super.key});

  @override
  State<PerfilBarberoPage> createState() => _PerfilBarberoPageState();
}

class _PerfilBarberoPageState extends State<PerfilBarberoPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String _nombre = "";
  String _correo = "";
  String _telefono = "";

  bool _editandoNombre = false;
  bool _editandoTelefono = false;

  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final doc = await _firestore.collection('usuarios').doc(uid).get();
    final data = doc.data();

    setState(() {
      _nombre = data?['nombre'] ?? "";
      _correo = data?['email'] ?? "";
      _telefono = data?['telefono'] ?? "No registrado";
      _nombreController.text = _nombre;
      _telefonoController.text = _telefono;
    });
  }

  Future<void> _guardarCampo(String campo, String valor) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection('usuarios').doc(uid).update({campo: valor});
    _cargarDatosUsuario();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Datos actualizados")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFFC89B65),
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 30),

          // Nombre
          _filaEditable(
            label: "Nombre",
            valor: _nombre,
            controlador: _nombreController,
            editando: _editandoNombre,
            onGuardar: () {
              _guardarCampo("nombre", _nombreController.text.trim());
              setState(() => _editandoNombre = false);
            },
            onEditar: () => setState(() => _editandoNombre = true),
          ),
          const SizedBox(height: 20),

          // Correo (solo lectura)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: 80,
                child: Text("Correo", style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(_correo, style: const TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Teléfono
          _filaEditable(
            label: "Teléfono",
            valor: _telefono,
            controlador: _telefonoController,
            editando: _editandoTelefono,
            onGuardar: () {
              _guardarCampo("telefono", _telefonoController.text.trim());
              setState(() => _editandoTelefono = false);
            },
            onEditar: () => setState(() => _editandoTelefono = true),
          ),
        ],
      ),
    );
  }

  Widget _filaEditable({
    required String label,
    required String valor,
    required TextEditingController controlador,
    required bool editando,
    required VoidCallback onGuardar,
    required VoidCallback onEditar,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: const TextStyle(color: Colors.white)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: editando
              ? TextField(
                  controller: controlador,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.black26,
                    hintStyle: TextStyle(color: Colors.white54),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                )
              : Text(valor, style: const TextStyle(color: Colors.white, fontSize: 16)),
        ),
        IconButton(
          icon: Icon(
            editando ? Icons.check : Icons.edit,
            color: editando ? Colors.green : Colors.grey,
          ),
          onPressed: editando ? onGuardar : onEditar,
        ),
      ],
    );
  }
}
