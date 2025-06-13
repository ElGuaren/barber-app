import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PantallaLocales extends StatelessWidget {
  const PantallaLocales({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Locales'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('locales').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No hay locales disponibles.'));
            }

            final locales = snapshot.data!.docs;

            return ListView.builder(
              itemCount: locales.length,
              itemBuilder: (context, index) {
                final local = locales[index];
                final nombre = local['nombre'];
                final descripcion = local['descripcion'];

                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.build, color: Colors.white),
                    ),
                    title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(descripcion),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Aquí podrías abrir el detalle del local o calendario de horas
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
