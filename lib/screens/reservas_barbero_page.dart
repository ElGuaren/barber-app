import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ReservasBarberoPage extends StatefulWidget {
  const ReservasBarberoPage({super.key});

  @override
  State<ReservasBarberoPage> createState() => _ReservasBarberoPageState();
}

class _ReservasBarberoPageState extends State<ReservasBarberoPage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<String?> _obtenerIdLocal() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _firestore.collection('usuarios').doc(uid).get();
    return doc.data()?['idLocal'];
  }

  Future<List<Map<String, dynamic>>> _obtenerReservas() async {
    final idLocal = await _obtenerIdLocal();
    if (idLocal == null) return [];

    final snapshot = await _firestore
        .collection('reservas')
        .where('localId', isEqualTo: idLocal)
        .get();

    List<Map<String, dynamic>> reservasConUsuario = [];

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final uidCliente = data['uid'];

      final clienteDoc = await _firestore.collection('usuarios').doc(uidCliente).get();
      final clienteData = clienteDoc.data();

      final String fecha = data['fecha'];
      final String hora = data['hora'];
      final DateTime fechaHora = _convertirAFechaHora(fecha, hora);

      reservasConUsuario.add({
        'nombre': clienteData?['nombre'] ?? 'Desconocido',
        'correo': clienteData?['email'] ?? '',
        'telefono': clienteData?['telefono'] ?? '',
        'fecha': fecha,
        'hora': hora,
        'fechaHora': fechaHora, // ← campo para ordenar
      });
    }

    // Ordenar por fecha y hora
    reservasConUsuario.sort((a, b) => a['fechaHora'].compareTo(b['fechaHora']));

    return reservasConUsuario;
  }

  DateTime _convertirAFechaHora(String fecha, String hora) {
    try {
      final dateParts = fecha.split('-'); // dd-MM-yyyy
      final day = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final year = int.parse(dateParts[2]);

      final time = DateFormat.jm().parse(hora); // ej: 11:00 AM
      return DateTime(year, month, day, time.hour, time.minute);
    } catch (e) {
      return DateTime(1900); // valor por defecto si falla
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
                  reserva['nombre'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (reserva['telefono'].toString().isNotEmpty)
                      Text("Teléfono: ${reserva['telefono']}"),
                    if (reserva['correo'].toString().isNotEmpty)
                      Text("Correo: ${reserva['correo']}"),
                    Text("Fecha: ${reserva['fecha']}"),
                    Text("Hora: ${reserva['hora']}"),
                  ],
                ),
                leading: const Icon(Icons.person, color: Color(0xFFC89B65)),
              ),
            );
          },
        );
      },
    );
  }
}
