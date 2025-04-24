import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class AlertasScreen extends StatefulWidget {
  const AlertasScreen({Key? key}) : super(key: key);

  @override
  _AlertasScreenState createState() => _AlertasScreenState();
}

class _AlertasScreenState extends State<AlertasScreen> {
  List<Map<String, dynamic>> alertas = [];

  @override
  void initState() {
    super.initState();
    cargarAlertas();
  }

  Future<void> cargarAlertas() async {
    final List<Map<String, dynamic>> nuevasAlertas = [];

    // Productos próximos a caducar
    final productosRes = await http.get(Uri.parse('http://10.144.6.77:3000/product?filtroCaducado=false'));
    if (productosRes.statusCode == 200) {
      final productos = json.decode(productosRes.body);
      for (var producto in productos) {
        final caducidad = DateTime.parse(producto['caducidad']);
        final ahora = DateTime.now();
        final diferencia = caducidad.difference(ahora).inDays;

        if (diferencia <= 2 && diferencia >= 0) {
          nuevasAlertas.add({
            'tipo': 'Producto próximo a caducar',
            'mensaje': "${producto['nombre']} caduca el ${DateFormat('dd/MM/yyyy').format(caducidad)}",
            'color': Colors.orange
          });
        }
      }
    }

    // Sensores: Temperatura o humedad alta
    final sensoresRes = await http.get(Uri.parse('http://10.144.6.77:3000/sensores'));
    if (sensoresRes.statusCode == 200) {
      final sensores = json.decode(sensoresRes.body);
      for (var s in sensores) {
        if (s['temperatura'] != null && double.tryParse(s['temperatura'].toString()) != null) {
          final nombreSensor = s['ubicacion'] ?? 'ubicación desconocida';
          final temp = double.parse(s['temperatura'].toString());
          if (temp > 35) {
            nuevasAlertas.add({
              'tipo': 'Temperatura alta',
              'mensaje': "$nombreSensor detecta: ${temp.toStringAsFixed(1)}°C",
              'color': Colors.redAccent
            });
          }
        }


        if (s['humedad'] != null && double.tryParse(s['humedad'].toString()) != null) {
          final humedad = double.parse(s['humedad'].toString());
          final nombreSensor = s['ubicacion'] ?? 'ubicación desconocida';
          if (humedad > 85) {
            nuevasAlertas.add({
              'tipo': 'Humedad alta',
              'mensaje': "$nombreSensor detecta: ${humedad.toStringAsFixed(1)}%",
              'color': Colors.blueAccent
            });
          }
        }
      }
    }

    setState(() {
      alertas = nuevasAlertas;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Alertas"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: cargarAlertas,
          )
        ],
      ),
      body: alertas.isEmpty
          ? const Center(child: Text("No hay alertas activas"))
          : ListView.builder(
              itemCount: alertas.length,
              itemBuilder: (context, index) {
                final alerta = alertas[index];
                return Card(
                  color: alerta['color'],
                  child: ListTile(
                    leading: const Icon(Icons.warning, color: Colors.white),
                    title: Text(alerta['tipo'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text(alerta['mensaje'], style: const TextStyle(color: Colors.white)),
                  ),
                );
              },
            ),
    );
  }
}