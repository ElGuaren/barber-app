import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AgregarHorasPage extends StatefulWidget {
  const AgregarHorasPage({super.key});

  @override
  State<AgregarHorasPage> createState() => _AgregarHorasPageState();
}

class _AgregarHorasPageState extends State<AgregarHorasPage> {
  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaInicio;
  TimeOfDay? _horaFin;

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<String?> _obtenerIdLocal() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final doc = await _firestore.collection('usuarios').doc(uid).get();
    return doc.data()?['idLocal'];
  }

  Future<void> _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _fechaSeleccionada = picked);
  }

  Future<void> _seleccionarHora(bool esInicio) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      setState(() => esInicio ? _horaInicio = picked : _horaFin = picked);
    }
  }

  Future<void> _guardarHoras() async {
    if (_fechaSeleccionada == null || _horaInicio == null || _horaFin == null) {
      _mostrarMensaje("Completa todos los campos");
      return;
    }

    final idLocal = await _obtenerIdLocal();
    if (idLocal == null) {
      _mostrarMensaje("No se encontró el local");
      return;
    }

    final fechaTexto = DateFormat('dd-MM-yyyy').format(_fechaSeleccionada!);
    DateTime inicio = DateTime(
      _fechaSeleccionada!.year,
      _fechaSeleccionada!.month,
      _fechaSeleccionada!.day,
      _horaInicio!.hour,
      _horaInicio!.minute,
    );
    DateTime fin = DateTime(
      _fechaSeleccionada!.year,
      _fechaSeleccionada!.month,
      _fechaSeleccionada!.day,
      _horaFin!.hour,
      _horaFin!.minute,
    );

    if (inicio.isAfter(fin) || inicio == fin) {
      _mostrarMensaje("El rango horario no es válido");
      return;
    }

    List<Map<String, dynamic>> horasAGuardar = [];
    while (inicio.isBefore(fin)) {
      final horaTexto = DateFormat.jm().format(inicio);
      horasAGuardar.add({'fecha': fechaTexto, 'hora': horaTexto});
      inicio = inicio.add(const Duration(hours: 1)); // ← cada 1 hora
    }

    await _firestore.collection('locales').doc(idLocal).update({
      'horas': FieldValue.arrayUnion(horasAGuardar),
    });

    _mostrarMensaje("Horas guardadas correctamente");

    setState(() {
      _fechaSeleccionada = null;
      _horaInicio = null;
      _horaFin = null;
    });
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: const Color(0xFFC89B65)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Agregar horas disponibles",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _seleccionarFecha,
                  icon: const Icon(Icons.date_range),
                  label: Text(_fechaSeleccionada == null
                      ? "Seleccionar fecha"
                      : DateFormat('dd-MM-yyyy').format(_fechaSeleccionada!)),
                  style: _botonEstilo(),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () => _seleccionarHora(true),
                  icon: const Icon(Icons.access_time),
                  label: Text(_horaInicio == null ? "Seleccionar hora inicio" : _horaInicio!.format(context)),
                  style: _botonEstilo(),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () => _seleccionarHora(false),
                  icon: const Icon(Icons.access_time_filled),
                  label: Text(_horaFin == null ? "Seleccionar hora fin" : _horaFin!.format(context)),
                  style: _botonEstilo(),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (_fechaSeleccionada == null || _horaInicio == null || _horaFin == null) {
                      _mostrarMensaje("Completa todos los campos");
                      return;
                    }

                    final confirmar = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Confirmar horario"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Fecha: ${DateFormat('dd-MM-yyyy').format(_fechaSeleccionada!)}"),
                            Text("Hora inicio: ${_horaInicio!.format(context)}"),
                            Text("Hora fin: ${_horaFin!.format(context)}"),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Cancelar"),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC89B65)),
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text("Confirmar"),
                          ),
                        ],
                      ),
                    );

                    if (confirmar == true) {
                      _guardarHoras();
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: const Text("Guardar horas"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC89B65),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ButtonStyle _botonEstilo() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.grey[100],
      foregroundColor: const Color(0xFF212121),
      minimumSize: const Size(double.infinity, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
