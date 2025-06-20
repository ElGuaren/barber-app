import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class PantallaMisReservas extends StatefulWidget {
  const PantallaMisReservas({super.key});

  @override
  State<PantallaMisReservas> createState() => _PantallaMisReservasState();
}

class _PantallaMisReservasState extends State<PantallaMisReservas> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> _obtenerReservas() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];

    final snapshot = await _firestore
        .collection('usuarios')
        .doc(uid)
        .collection('reservas')
        .get();

    List<Map<String, dynamic>> reservas = [];

    for (final doc in snapshot.docs) {
      final data = doc.data();

      String? localId = data['localId'];
      String nombreLocal = data['nombreLocal'] ?? 'Local desconocido';
      String fecha = data['fecha'] ?? '';
      String hora = data['hora'] ?? '';
      String telefonoBarbero = 'No registrado';
      String nombreBarbero = 'Barbero desconocido';

      if (localId != null) {
        final localDoc = await _firestore.collection('locales').doc(localId).get();
        final localData = localDoc.data();
        if (localData != null) {
          final uidBarbero = localData['uidBarbero'];
          if (uidBarbero != null) {
            final barberoDoc = await _firestore.collection('usuarios').doc(uidBarbero).get();
            final barberoData = barberoDoc.data();
            if (barberoData != null) {
              telefonoBarbero = barberoData['telefono'] ?? 'No registrado';
              nombreBarbero = barberoData['nombre'] ?? 'Barbero';
            }
          }
        }
      }

      reservas.add({
        'nombreLocal': nombreLocal,
        'fecha': fecha,
        'hora': hora,
        'nombreBarbero': nombreBarbero,
        'telefonoBarbero': telefonoBarbero,
      });
    }

    // Ordenar por fecha y hora (formato: dd-MM-yyyy + 12h)
    reservas.sort((a, b) {
      final aFechaHora = _convertirFechaHora(a['fecha'], a['hora']);
      final bFechaHora = _convertirFechaHora(b['fecha'], b['hora']);
      return aFechaHora.compareTo(bFechaHora);
    });

    return reservas;
  }

  DateTime _convertirFechaHora(String fecha, String hora) {
    try {
      final formato = DateFormat('dd-MM-yyyy hh:mm a');
      return formato.parse('$fecha $hora');
    } catch (_) {
      return DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _obtenerReservas(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }

        final reservas = snapshot.data ?? [];

        if (reservas.isEmpty) {
          return const Center(
            child: Text("Aún no hay reservas", style: TextStyle(color: Colors.white)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: reservas.length,
          itemBuilder: (context, index) {
            final reserva = reservas[index];
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              color: Colors.white,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(
                  "Reserva en ${reserva['nombreLocal']}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Barbero: ${reserva['nombreBarbero']}"),
                    Text("Teléfono: ${reserva['telefonoBarbero']}"),
                    Text("Fecha: ${reserva['fecha']}"),
                    Text("Hora: ${reserva['hora']}"),
                  ],
                ),
                leading: const Icon(Icons.event_note, color: Color(0xFFC89B65)),
              ),
            );
          },
        );
      },
    );
  }
}
