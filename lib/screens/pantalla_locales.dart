import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pantalla_reserva.dart';

class PantallaLocales extends StatelessWidget {
  const PantallaLocales({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF212121),
        foregroundColor: Colors.white,
        title: const Text(
          'Locales',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          const Divider(height: 1, color: Color(0xFFBDBDBD)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('locales').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFFC89B65)));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No hay locales disponibles.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  final locales = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: locales.length,
                    itemBuilder: (context, index) {
                      final local = locales[index];
                      final nombre = local['nombre'];
                      final descripcion = local['descripcion'];

                      return Card(
                        color: Colors.white,
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFC89B65),
                            child: Icon(Icons.storefront, color: Colors.white),
                          ),
                          title: Text(
                            nombre,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF212121),
                            ),
                          ),
                          subtitle: Text(
                            descripcion,
                            style: const TextStyle(color: Color(0xFF757575)),
                          ),
                          trailing: const Icon(Icons.chevron_right, color: Color(0xFF212121)),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PantallaReservaHoras(
                                  localId: local.id,
                                  nombreLocal: nombre,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
