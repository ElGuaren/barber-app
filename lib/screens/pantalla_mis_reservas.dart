import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PantallaMisReservas extends StatelessWidget {
  const PantallaMisReservas({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF2C2C2C),
        body: Center(
          child: Text(
            "Usuario no autenticado",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2C),
      body: Column(
        children: [
          const Divider(height: 1, color: Color(0xFFBDBDBD)),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('usuarios')
                  .doc(uid)
                  .collection('reservas')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFC89B65)));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No tienes reservas activas",
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                final reservas = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: reservas.length,
                  itemBuilder: (context, index) {
                    final reserva = reservas[index];
                    final local = reserva['nombreLocal'] ?? 'Local desconocido';
                    final fecha = reserva['fecha'] ?? 'Sin fecha';
                    final hora = reserva['hora'] ?? 'Sin hora';

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      color: Colors.white,
                      child: ListTile(
                        leading: const Icon(Icons.event_available, color: Color(0xFFC89B65)),
                        title: Text("Reserva en $local", style: const TextStyle(color: Colors.black)),
                        subtitle: Text(
                          "Fecha: $fecha\nHora: $hora",
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
