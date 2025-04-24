import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SeguimientoGpsPage extends StatefulWidget {
  @override
  _SeguimientoGpsPageState createState() => _SeguimientoGpsPageState();
}

class _SeguimientoGpsPageState extends State<SeguimientoGpsPage> {
  late GoogleMapController mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  late LatLng _center;

  @override
  void initState() {
    super.initState();
    _center = LatLng(19.432608, -99.133209); // Centro del mapa (puedes cambiar esto)
    _addPolyline();
  }

  // Función para agregar una línea (simulando la ruta del barco)
  void _addPolyline() {
    final List<LatLng> route = [
      LatLng(19.432608, -99.133209),  // Punto inicial
      LatLng(19.433609, -99.134209),  // Punto 1
      LatLng(19.434609, -99.135209),  // Punto 2
      LatLng(19.435609, -99.136209),  // Punto 3 (etc. Simula la ruta)
    ];

    _polylines.add(
      Polyline(
        polylineId: PolylineId('boat_route'),
        points: route,
        color: Colors.blue,
        width: 5,
      ),
    );
  }

  // Función para configurar el mapa
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Seguimiento GPS de Barco')),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 14.0,
        ),
        markers: _markers,
        polylines: _polylines,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
