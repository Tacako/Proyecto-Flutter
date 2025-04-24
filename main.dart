import 'package:aplicaciones_moviles/page_ferroviario/alertas.dart';
import 'package:aplicaciones_moviles/page_ferroviario/almacenamiento.dart';
import 'package:aplicaciones_moviles/page_ferroviario/ferroviario_page.dart';
import 'package:aplicaciones_moviles/page_ferroviario/inventario_page.dart';
import 'package:aplicaciones_moviles/page_ferroviario/rastreo_monitoreo_page.dart';
import 'package:aplicaciones_moviles/page_ferroviario/seguimiento.gps.dart';
import 'package:aplicaciones_moviles/page_maritumo/Alertas.dart';
import 'package:aplicaciones_moviles/page_maritumo/almacenamiento_page.dart';
import 'package:aplicaciones_moviles/page_maritumo/inventario_page.dart';
import 'package:aplicaciones_moviles/page_maritumo/maritimo_page.dart';
import 'package:aplicaciones_moviles/page_maritumo/rastreo_monitoreo_page.dart';
import 'package:aplicaciones_moviles/page_maritumo/seguimiento.gps.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

Future<Widget> verificarSesion() async {
  final prefs = await SharedPreferences.getInstance();
  final tipo = prefs.getInt('tipo_usuario');
  final horaGuardada = prefs.getString('hora_login');

  if (horaGuardada != null) {
    final horaLogin = DateTime.parse(horaGuardada);
    final ahora = DateTime.now();
    final diferencia = ahora.difference(horaLogin);

    if (diferencia.inMinutes > 30) {
      // Más de 30 minutos → cerrar sesión
      await prefs.clear();
      return const LoginPage();
    }
  }

  if (tipo == 1) return const MaritimoPage();
  if (tipo == 2) return const FerroviarioPage();
  return const LoginPage();
}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      routes: {
        '/login': (context) => const LoginPage(),
        '/maritimo': (context) => const MaritimoPage(),
        '/ferroviario': (context) => const FerroviarioPage(),
        '/inventario': (context) => InventarioPage(),
        '/almacenamiento': (context) => AlmacenamientoPage(),
        '/rastreo y monitoreo': (context) => RastreoMonitoreoPage(),
        '/seguimiento gps': (context) => SeguimientoGpsPage(),
        '/alertas': (context) => AlertasScreen(),
        '/inventario ferro': (context) => InventarioFerroviarioPage(),
        '/almacenamiento ferro': (context) => AlmacenamientoFerroviarioPage(),
        '/rastreo y monitoreo ferro': (context) => RastreoMonitoreoFerroPage(),
        '/seguimiento gps ferro': (context) => SeguimientoGpsFerroPage(),
        '/alertas ferro': (context) => AlertasScreenFerro()
        

      },
      home: FutureBuilder(
        future: verificarSesion(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          } else {
            return snapshot.data!;
          }
        },
      ),
    );
  }
}