import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class RastreoMonitoreoPage extends StatefulWidget {
  @override
  _RastreoMonitoreoPageState createState() => _RastreoMonitoreoPageState();
}

class _RastreoMonitoreoPageState extends State<RastreoMonitoreoPage> {
  List<Map<String, dynamic>> sensores = [];
  String mensajeRespuesta = '';
  DateTime? fechaSeleccionada;

  // Obtener datos del backend
  Future<void> obtenerDatos({String? fecha}) async {
    final uri = fecha != null
        ? Uri.parse('http://10.144.6.77:3000/sensores?fecha=$fecha')
        : Uri.parse('http://10.144.6.77:3000/sensores');

    final response = await http.get(uri);

    if (!mounted) return; // Verifica si el widget sigue montado

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      setState(() {
        sensores = List<Map<String, dynamic>>.from(data);
        mensajeRespuesta = 'Datos recibidos correctamente';
      });
    } else {
      setState(() {
        sensores = [];
        mensajeRespuesta = 'Error al obtener los datos';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    obtenerDatos(); // Carga inicial de datos (último minuto)
  }

  Future<void> seleccionarFecha() async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );

    if (fecha != null) {
      final TimeOfDay? hora = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (hora != null) {
        final DateTime fechaHora = DateTime(
          fecha.year,
          fecha.month,
          fecha.day,
          hora.hour,
          hora.minute,
        );

        fechaSeleccionada = fechaHora;
        obtenerDatos(fecha: fechaHora.toIso8601String());
      }
    }
  }

  // Función para formatear la fecha a un formato legible
  String formatFecha(String fecha) {
    DateTime fechaHora = DateTime.parse(fecha).toLocal(); // Convertir a la hora local
    return DateFormat('yyyy-MM-dd hh:mm:ss a').format(fechaHora); // Formato: 2025-04-12 10:00:18 PM
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rastreo y Monitoreo'),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: seleccionarFecha,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => obtenerDatos(),
              child: Text('Actualizar Datos Recientes'),
            ),
            SizedBox(height: 10),
            mensajeRespuesta.isNotEmpty
                ? Text(
                    mensajeRespuesta,
                    style: TextStyle(color: Colors.green),
                  )
                : Container(),
            SizedBox(height: 10),
            Expanded(
              child: sensores.isNotEmpty
                  ? ListView.builder(
                      itemCount: sensores.length,
                      itemBuilder: (context, index) {
                        final item = sensores[index];
                        String fechaFormateada = formatFecha(item['fecha_hora']);
                        return Card(
                          child: ListTile(
                            title: Text('Temperatura: ${item['temperatura']} °C'),
                            subtitle: Text(
                                'Humedad: ${item['humedad']}%\nFecha: $fechaFormateada'),
                          ),
                        );
                      },
                    )
                  : Center(child: Text('No hay datos disponibles')),
            ),
          ],
        ),
      ),
    );
  }
}