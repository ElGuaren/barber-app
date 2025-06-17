import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PantallaReservaHoras extends StatelessWidget {
  final String localId;
  final String nombreLocal;

  const PantallaReservaHoras({
    super.key,
    required this.localId,
    required this.nombreLocal,
  });

  void _confirmarReserva(BuildContext context, Map<String, dynamic> hora) async {
    final fecha = hora['fecha'];
    final horaTexto = hora['hora'];

    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar reserva"),
        content: Text("¿Deseas reservar la hora $horaTexto el $fecha?"),
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
            child: const Text("Reservar"),
          ),
        ],
      ),
    );

    if (confirmacion == true) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final reservaData = {
        'uid': user.uid,
        'localId': localId,
        'nombreLocal': nombreLocal,
        'fecha': fecha,
        'hora': horaTexto,
        'timestamp': Timestamp.now(),
      };

      try {
        await FirebaseFirestore.instance.collection('reservas').add(reservaData);
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .collection('reservas')
            .add(reservaData);

        await FirebaseFirestore.instance.collection('locales').doc(localId).update({
          'horas': FieldValue.arrayRemove([hora])
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Reserva realizada con éxito"),
            backgroundColor: Color(0xFFC89B65),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al guardar la reserva: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2C),
      appBar: AppBar(
        title: Text(nombreLocal),
        backgroundColor: const Color(0xFF212121),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const Divider(height: 1, color: Color(0xFFBDBDBD)),
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('locales').doc(localId).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFC89B65)));
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(
                    child: Text(
                      "Local no encontrado.",
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;
                final horas = (data['horas'] as List?)?.cast<Map<String, dynamic>>() ?? [];

                if (horas.isEmpty) {
                  return const Center(
                    child: Text(
                      "No hay horas disponibles.",
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: horas.length,
                  itemBuilder: (context, index) {
                    final hora = horas[index];
                    final fecha = hora['fecha'];
                    final horaTexto = hora['hora'];

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      color: Colors.white,
                      child: ListTile(
                        title: Text(
                          "Hora disponible: $horaTexto",
                          style: const TextStyle(color: Colors.black),
                        ),
                        subtitle: Text(
                          "Fecha: $fecha",
                          style: const TextStyle(color: Colors.black87),
                        ),
                        trailing: const Icon(Icons.access_time, color: Color(0xFFC89B65)),
                        onTap: () => _confirmarReserva(context, hora),
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
