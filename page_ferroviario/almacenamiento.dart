import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AlmacenamientoFerroviarioPage extends StatefulWidget {
  @override
  _AlmacenamientoFerroviarioPageState createState() => _AlmacenamientoFerroviarioPageState();
}

class _AlmacenamientoFerroviarioPageState extends State<AlmacenamientoFerroviarioPage> {
  final _formKey = GlobalKey<FormState>();
  String marca = '';
  String modelo = '';
  String color = '';
  String anio = '';

  Future<void> _guardarCarro() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final response = await http.post(
        Uri.parse('http://10.144.6.77:3000/ferrocarriles'),
        headers: {'Content-Type': 'application/json'},
        body: '''{
          "marca": "$marca",
          "modelo": "$modelo",
          "color": "$color",
          "anio": ${int.parse(anio)}
        }''',
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Carro agregado exitosamente')));
        _formKey.currentState!.reset();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al agregar carro')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fallo de conexión')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Agregar Carro Ferroviario')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Marca'),
              onChanged: (value) => marca = value,
              validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Modelo'),
              onChanged: (value) => modelo = value,
              validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Color'),
              onChanged: (value) => color = value,
              validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Año'),
              keyboardType: TextInputType.number,
              onChanged: (value) => anio = value,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Campo requerido';
                final parsed = int.tryParse(value);
                return (parsed == null || parsed < 1900 || parsed > DateTime.now().year)
                    ? 'Año inválido'
                    : null;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _guardarCarro,
              child: Text('Guardar Carro'),
            )
          ]),
        ),
      ),
    );
  }
}