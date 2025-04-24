import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MaritimoPage extends StatefulWidget {
  const MaritimoPage({super.key});

  @override
  State<MaritimoPage> createState() => _MaritimoPageState();
}

class _MaritimoPageState extends State<MaritimoPage> {
  String nombreUsuario = '';

  @override
  void initState() {
    super.initState();
    obtenerNombre();
  }

  void obtenerNombre() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nombreUsuario = prefs.getString('usuario') ?? '';
    });
  }

  void cerrarSesion(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }

  void navegar(String ruta) {
    // Aquí puedes usar Navigator.pushNamed(context, ruta);
    Navigator.pushNamed(context, '/${ruta.toLowerCase()}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Marítimo - $nombreUsuario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => cerrarSesion(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Selecciona una opción:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => navegar('Inventario'),
              child: const Text('Inventario'),
            ),
            ElevatedButton(
              onPressed: () => navegar('Seguimiento GPS'),
              child: const Text('Seguimiento GPS'),
            ),
            ElevatedButton(
              onPressed: () => navegar('Almacenamiento'),
              child: const Text('Almacenamiento'),
            ),
            ElevatedButton(
              onPressed: () => navegar('Alertas'),
              child: const Text('Alertas'),
            ),
            ElevatedButton(
              onPressed: () => navegar('Rastreo y Monitoreo'),
              child: const Text('Rastreo y Monitoreo'),
            ),
          ],
        ),
      ),
    );
  }
}
