import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InventarioFerroviarioPage extends StatefulWidget {
  const InventarioFerroviarioPage({super.key});

  @override
  _InventarioFerroviarioPageState createState() =>
      _InventarioFerroviarioPageState();
}

class _InventarioFerroviarioPageState extends State<InventarioFerroviarioPage> {
  List<dynamic> carros = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCarros();
  }

  Future<void> _fetchCarros() async {
    try {
      final response =
          await http.get(Uri.parse('http://10.144.6.77:3000/ferrocarriles'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            carros = data['carros'];
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => isLoading = false);
          _showError('No se pudieron obtener los carros');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        _showError('Error de conexión');
      }
    }
  }

  // Función para mostrar el mensaje de error
  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Error'),
        content: Text(msg),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))],
      ),
    );
  }

  // Función para eliminar un carro
  Future<void> _deleteCarro(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://10.144.6.77:3000/ferrocarriles/$id'),
      );
      if (response.statusCode == 200) {
        _fetchCarros(); // Refrescar la lista después de eliminar
      } else {
        _showError('No se pudo eliminar el carro');
      }
    } catch (e) {
      _showError('Error al eliminar el carro');
    }
  }

  // Función para editar un carro
  Future<void> _editCarro(int id, String marca, String modelo, String color, String anio) async {
    try {
      final response = await http.put(
        Uri.parse('http://10.144.6.77:3000/ferrocarriles/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'marca': marca,
          'modelo': modelo,
          'color': color,
          'anio': anio,
        }),
      );
      if (response.statusCode == 200) {
        _fetchCarros(); // Refrescar la lista después de editar
      } else {
        _showError('No se pudo editar el carro');
      }
    } catch (e) {
      _showError('Error al editar el carro');
    }
  }

  // Diálogo para editar un carro
  void _showEditDialog(int id, String marca, String modelo, String color, String anio) {
    final marcaController = TextEditingController(text: marca);
    final modeloController = TextEditingController(text: modelo);
    final colorController = TextEditingController(text: color);
    final anioController = TextEditingController(text: anio);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Editar Carro'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: marcaController, decoration: InputDecoration(labelText: 'Marca')),
            TextField(controller: modeloController, decoration: InputDecoration(labelText: 'Modelo')),
            TextField(controller: colorController, decoration: InputDecoration(labelText: 'Color')),
            TextField(controller: anioController, decoration: InputDecoration(labelText: 'Año')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _editCarro(
                id,
                marcaController.text,
                modeloController.text,
                colorController.text,
                anioController.text,
              );
              Navigator.pop(context);
            },
            child: Text('Guardar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inventario Ferroviario')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : carros.isEmpty
              ? Center(child: Text('No hay carros registrados'))
              : ListView.builder(
                  itemCount: carros.length,
                  itemBuilder: (context, index) {
                    final carro = carros[index];
                    return Card(
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        title: Text('${carro['marca']} ${carro['modelo']}'),
                        subtitle: Text('Color: ${carro['color']} • Año: ${carro['anio']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                _showEditDialog(
                                  carro['id'],
                                  carro['marca'],
                                  carro['modelo'],
                                  carro['color'],
                                  carro['anio'].toString(),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _deleteCarro(carro['id']);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}