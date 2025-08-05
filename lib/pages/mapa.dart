import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../services/supabase_service.dart';

class PantallaMapa extends StatefulWidget {
  const PantallaMapa({super.key});

  @override
  State<PantallaMapa> createState() => _PantallaMapaState();
}

class _PantallaMapaState extends State<PantallaMapa> {
  LatLng? _miUbicacion;
  Stream<Position>? _posStream;

  @override
  void initState() {
    super.initState();
    iniciarStreamUbicacion();
  }

  void iniciarStreamUbicacion() async {
    final permiso = await Geolocator.requestPermission();
    if (permiso == LocationPermission.denied) return;

    _posStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1,
      ),
    );

    _posStream!.listen((pos) async {
      final nuevaUbicacion = LatLng(pos.latitude, pos.longitude);

      setState(() {
        _miUbicacion = nuevaUbicacion;
      });
      await SupabaseService.enviarUbicacionTiempoReal(
        nuevaUbicacion.latitude,
        nuevaUbicacion.longitude,
      );
    });
  }

  Future<void> _enviarUbicacionManual() async {
    if (_miUbicacion == null) return;

    final ok = await SupabaseService.enviarMiUbicacion(
      _miUbicacion!.latitude,
      _miUbicacion!.longitude,
    );

    if (ok) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              '✅ Ubicación enviada con éxito',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              '❌ Error al enviar ubicación',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _cerrarSesion(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    if (_miUbicacion == null) {
      return Scaffold(
        backgroundColor: Colors.blueGrey.shade900,
        appBar: AppBar(
          backgroundColor: Colors.blueGrey.shade800,
          title: const Row(
            children: [
              Icon(Icons.map_rounded, color: Colors.lightBlueAccent),
              SizedBox(width: 8),
              Text('Mapa', style: TextStyle(color: Colors.white)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              tooltip: 'Cerrar sesión',
              onPressed: () => _cerrarSesion(context),
            ),
          ],
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
          ),
        ),
      );
    }

    final marcadores = <Marker>[
      Marker(
        point: _miUbicacion!,
        width: 40,
        height: 40,
        child: const Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade800,
        title: const Row(
          children: [
            Icon(Icons.map_rounded, color: Colors.lightBlueAccent),
            SizedBox(width: 8),
            Text('Mapa', style: TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Cerrar sesión',
            onPressed: () => _cerrarSesion(context),
          ),
        ],
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _miUbicacion!,
                initialZoom: 15,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: const ['a', 'b', 'c'],
                ),
                MarkerLayer(markers: marcadores),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _enviarUbicacionManual,
                icon: const Icon(Icons.send, color: Colors.white),
                label: const Text(
                  "Enviar Ubicación",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
