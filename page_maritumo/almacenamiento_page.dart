import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AlmacenamientoPage extends StatefulWidget {
  @override
  _AlmacenamientoPageState createState() => _AlmacenamientoPageState();
}

class _AlmacenamientoPageState extends State<AlmacenamientoPage> {
  final _formKey = GlobalKey<FormState>();

  final nombreController = TextEditingController();
  final cantidadController = TextEditingController();
  final horaLlegadaController = TextEditingController();
  final caducidadController = TextEditingController();
  final envioPreferenteController = TextEditingController();

  String estado = 'En almacenamiento';

  // Función para mostrar el selector de fecha
  Future<void> _selectDate(BuildContext context, TextEditingController controller, bool isTime) async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = DateTime(now.year, now.month, now.day);
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      if (isTime) {
        // Si es hora de llegada, se selecciona también la hora
        final TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(hour: 0, minute: 0),
        );
        if (pickedTime != null) {
          final DateTime fullDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          controller.text = fullDateTime.toString(); // Formato completo: '2025-04-12 15:30:00'
        }
      } else {
        controller.text = pickedDate.toString().split(' ')[0]; // Solo la fecha: '2025-04-12'
      }
    }
  }

  Future<void> guardarProducto() async {
    final uri = Uri.parse('http://10.144.6.77:3000/product');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'nombre': nombreController.text,
        'cantidad': double.parse(cantidadController.text),
        'hora_llegada': horaLlegadaController.text,
        'caducidad': caducidadController.text,
        'envio_preferente': envioPreferenteController.text,
        'estado': estado,
      }),
    );

    if (!mounted) return; // <--- Verifica si aún está montado

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Producto guardado exitosamente')),
      );
      _formKey.currentState?.reset();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar producto')),
      );
    }
  }

  @override
  void dispose() {
    nombreController.dispose();
    cantidadController.dispose();
    horaLlegadaController.dispose();
    caducidadController.dispose();
    envioPreferenteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Agregar Producto al Almacenamiento')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nombreController,
                decoration: InputDecoration(labelText: 'Nombre del café'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingrese el nombre' : null,
              ),
              TextFormField(
                controller: cantidadController,
                decoration: InputDecoration(labelText: 'Cantidad (kg)'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingrese la cantidad' : null,
              ),
              GestureDetector(
                onTap: () => _selectDate(context, horaLlegadaController, true),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: horaLlegadaController,
                    decoration: InputDecoration(
                      labelText: 'Hora de llegada',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Seleccione la hora de llegada' : null,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _selectDate(context, caducidadController, false),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: caducidadController,
                    decoration: InputDecoration(
                      labelText: 'Fecha de caducidad',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Seleccione la fecha de caducidad' : null,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _selectDate(context, envioPreferenteController, false),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: envioPreferenteController,
                    decoration: InputDecoration(
                      labelText: 'Fecha de envío preferente',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Seleccione la fecha de envío preferente' : null,
                  ),
                ),
              ),
              DropdownButtonFormField<String>(
                value: estado,
                decoration: InputDecoration(labelText: 'Estado del producto'),
                items: [
                  DropdownMenuItem(value: 'En almacenamiento', child: Text('En almacenamiento')),
                  DropdownMenuItem(value: 'En proceso de envío', child: Text('En proceso de envío')),
                ],
                onChanged: (value) {
                  setState(() {
                    estado = value!;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    guardarProducto();
                  }
                },
                child: Text('Guardar producto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}