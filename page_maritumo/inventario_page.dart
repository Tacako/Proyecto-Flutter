import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class InventarioPage extends StatefulWidget {
  @override
  _InventarioPageState createState() => _InventarioPageState();
}

class _InventarioPageState extends State<InventarioPage> {
  List<dynamic> productos = [];
  String? filtroEstado;
  bool mostrarCaducados = false;

  @override
  void initState() {
    super.initState();
    obtenerProductos();
  }

  String formatFecha(String fecha) {
    final fechaLocal = DateTime.parse(fecha).toLocal();
    return DateFormat('yyyy-MM-dd hh:mm:ss a').format(fechaLocal);
  }

  Future<void> obtenerProductos() async {
    final queryParams = {
      if (filtroEstado != null && filtroEstado!.isNotEmpty)
        'filtroEstado': filtroEstado!,
      if (mostrarCaducados) 'filtroCaducado': 'true',
    };

    final uri = Uri.http('10.144.6.77:3000', '/product', queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200 && mounted) {
      setState(() {
        productos = json.decode(response.body);
      });
    } else {
      print('Error al cargar productos');
    }
  }

  Future<void> eliminarProducto(int id) async {
    final uri = Uri.http('10.144.6.77:3000', '/product/$id');
    final response = await http.delete(uri);

    if (response.statusCode == 200) {
      obtenerProductos();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Producto eliminado')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar')),
      );
    }
  }
  
  String formatFechaMySQL(String fecha) {
  DateTime fechaHora = DateTime.parse(fecha).toLocal(); // Convierte la fecha a formato local
  return DateFormat('yyyy-MM-dd HH:mm:ss').format(fechaHora); // Formato adecuado para MySQL
}

// Diálogo para editar un producto de café
void _showEditDialog(int id, String nombre, String cantidad, String horaLlegada, String caducidad, String envioPreferente, String estado) {
  final nombreController = TextEditingController(text: nombre);
  final cantidadController = TextEditingController(text: cantidad.toString());
  final horaLlegadaController = TextEditingController(text: horaLlegada);
  final caducidadController = TextEditingController(text: caducidad);
  final envioPreferenteController = TextEditingController(text: envioPreferente);
  final estadoContoller = TextEditingController(text: estado);

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('Editar Producto de Café'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nombreController,
            decoration: InputDecoration(labelText: 'Nombre del café'),
          ),
          TextField(
            controller: cantidadController,
            decoration: InputDecoration(labelText: 'Cantidad (kg)'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: horaLlegadaController,
            decoration: InputDecoration(labelText: 'Hora de llegada'),
            keyboardType: TextInputType.datetime,
          ),
          TextField(
            controller: caducidadController,
            decoration: InputDecoration(labelText: 'Fecha de caducidad'),
            keyboardType: TextInputType.datetime,
          ),
          TextField(
            controller: envioPreferenteController,
            decoration: InputDecoration(labelText: 'Envío preferente'),
            keyboardType: TextInputType.datetime,
          ),
          TextField(
            controller: estadoContoller,
            decoration: InputDecoration(labelText: 'Estado'),
            keyboardType: TextInputType.datetime,
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            _editCafe(
              id,
              nombreController.text,
              double.tryParse(cantidadController.text) ?? 0.0,
              horaLlegadaController.text,
              caducidadController.text,
              envioPreferenteController.text,
              estadoContoller.text
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

// Función para editar un producto de café
Future<void> _editCafe(int id, String nombre, double cantidad, String horaLlegada, String caducidad, String envioPreferente, String estado) async {
  final uri = Uri.http('10.144.6.77:3000', '/product/$id');
  final response = await http.put(
    uri,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'nombre': nombre,
      'cantidad': cantidad,
      'hora_llegada': horaLlegada,
      'caducidad': caducidad,
      'envio_preferente': envioPreferente,
      'estado': estado
    }),
  );

  if (response.statusCode == 200) {
    obtenerProductos();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Producto de café actualizado')),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al actualizar producto de café')),
    );
  }
}


  Widget construirProducto(Map<String, dynamic> producto) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 3,
      child: ListTile(
        title: Text('${producto["nombre"]} - ${producto["cantidad"]} kg'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hora de llegada: ${formatFecha(producto["hora_llegada"])}'),
            Text('Caducidad: ${formatFecha(producto["caducidad"])}'),
            Text('Envío preferente: ${formatFecha(producto["envio_preferente"])}'),
            Text('Estado: ${producto["estado"]}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.orange),
              onPressed: () => _showEditDialog(
                producto['id'],
                producto['nombre'],
                producto['cantidad'],
                producto['hora_llegada'],
                producto['caducidad'],
                producto['envio_preferente'],
                producto['estado']
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => eliminarProducto(producto['id']),
            ),
          ],
        ),
      ),
    );
  }

  Widget construirFiltros() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          DropdownButton<String>(
            isExpanded: true,
            hint: Text('Filtrar por estado'),
            value: filtroEstado,
            onChanged: (value) {
              setState(() {
                filtroEstado = value == 'Todos' ? null : value;
                obtenerProductos();
              });
            },
            items: [
              DropdownMenuItem(value: 'En proceso de envío', child: Text('En proceso de envío')),
              DropdownMenuItem(value: 'En almacenamiento', child: Text('En almacenamiento')),
              DropdownMenuItem(value: 'Todos', child: Text('Todos')),
            ],
          ),
          CheckboxListTile(
            title: Text("Mostrar productos caducados"),
            value: mostrarCaducados,
            onChanged: (value) {
              setState(() {
                mostrarCaducados = value ?? false;
                obtenerProductos();
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inventario')),
      body: Column(
        children: [
          construirFiltros(),
          Expanded(
            child: productos.isEmpty
                ? Center(child: Text('No hay productos'))
                : ListView.builder(
                    itemCount: productos.length,
                    itemBuilder: (context, index) {
                      return construirProducto(productos[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}