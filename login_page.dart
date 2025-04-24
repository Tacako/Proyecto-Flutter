import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final nombreController = TextEditingController();
  final passwordController = TextEditingController();

  String mensaje = '';

  Future<void> login() async {
  final url = Uri.parse('http://10.144.6.77:3000/login');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'nombre': nombreController.text,
      'password': passwordController.text,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('usuario', data['usuario']['nombre']);
    await prefs.setInt('tipo_usuario', data['usuario']['tipo_usuario']);
    await prefs.setString('hora_login', DateTime.now().toIso8601String());

    if (data['usuario']['tipo_usuario'] == 1) {
      Navigator.pushReplacementNamed(context, '/maritimo');
    } else if (data['usuario']['tipo_usuario'] == 2) {
      Navigator.pushReplacementNamed(context, '/ferroviario');
    } else {
      setState(() => mensaje = 'Tipo de usuario no reconocido');
    }
  } else {
    setState(() {
      mensaje = 'Nombre o contraseña incorrectos';
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: login,
              child: const Text('Iniciar sesión'),
            ),
            const SizedBox(height: 20),
            Text(mensaje, style: const TextStyle(color: Colors.blue)),
          ],
        ),
      ),
    );
  }
}
