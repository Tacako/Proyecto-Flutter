import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AlertasScreenFerro extends StatefulWidget {
  const AlertasScreenFerro({Key? key}) : super(key: key);

  @override
  _AlertasScreenFerroState createState() => _AlertasScreenFerroState();
}

class _AlertasScreenFerroState extends State<AlertasScreenFerro> {
  List<Map<String, dynamic>> alertas = [];

  @override
  void initState() {
    super.initState();
    cargarAlertas();
  }

  Future<void> cargarAlertas() async {
    final List<Map<String, dynamic>> nuevasAlertas = [];

    // Obtener datos de sensores
    final sensoresRes = await http.get(Uri.parse('http://10.144.6.77:3000/sensores'));
    if (sensoresRes.statusCode == 200) {
      final sensores = json.decode(sensoresRes.body);
      for (var s in sensores) {
        final nombreSensor = s['ubicacion1'] ?? 'ubicación desconocida';
        
        // Alertas de temperatura alta
        if (s['temperatura'] != null && double.tryParse(s['temperatura'].toString()) != null) {
          final temp = double.parse(s['temperatura'].toString());
          if (temp > 50) {
            nuevasAlertas.add({
              'tipo': 'Temperatura alta',
              'mensaje': "$nombreSensor detecta: ${temp.toStringAsFixed(1)}°C",
              'color': Colors.redAccent
            });
          }
        }
        
        // Alertas de distancia corta
        if (s['distancia'] != null && double.tryParse(s['distancia'].toString()) != null) {
          final distancia = double.parse(s['distancia'].toString());
          if (distancia < 10) { // Ajusta este valor según lo que consideres "distancia corta"
            nuevasAlertas.add({
              'tipo': 'Distancia corta',
              'mensaje': "$nombreSensor detecta: ${distancia.toStringAsFixed(1)} cm",
              'color': Colors.orange
            });
          }
        }
        
        // Alertas de mucha luz
        if (s['luz'] != null && double.tryParse(s['luz'].toString()) != null) {
          final luz = double.parse(s['luz'].toString());
          if (luz >= 1) { // Ajusta este valor según lo que consideres "mucha luz"
            nuevasAlertas.add({
              'tipo': 'Mucha luz',
              'mensaje': "$nombreSensor detecta: ${luz.toStringAsFixed(1)} lux",
              'color': Colors.yellow[700]
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