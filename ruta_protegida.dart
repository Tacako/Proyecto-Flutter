import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RutaProtegida extends StatelessWidget {
  final Widget pantallaProtegida;

  const RutaProtegida({super.key, required this.pantallaProtegida});

  Future<bool> haySesion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('usuario') != null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: haySesion(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.data == true) {
          return pantallaProtegida;
        } else {
          // Redirige si no hay sesión
          Future.microtask(() =>
              Navigator.pushReplacementNamed(context, '/login'));
          return const Scaffold(); // Se muestra brevemente
        }
      },
    );
  }
}
