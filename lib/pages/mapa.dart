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
  Map<String, LatLng> _usuarios = {};
  Stream<Position>? _posStream;

  @override
  void initState() {
    super.initState();
    iniciarStreamUbicacion();
    SupabaseService.escucharUbicaciones((userId, latLng) {
      // Filtrar mi propio usuario para evitar que aparezca duplicado
      final usuarioActual = Supabase.instance.client.auth.currentUser;
      if (usuarioActual != null && userId != usuarioActual.id) {
        setState(() {
          _usuarios[userId] = latLng;
        });
      }
    });
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
      setState(() {
        _miUbicacion = LatLng(pos.latitude, pos.longitude);
      });
      await SupabaseService.enviarMiUbicacion(pos.latitude, pos.longitude);
    });
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
        child: TweenAnimationBuilder<LatLng>(
          tween: Tween<LatLng>(
            begin: _miUbicacion!,
            end: _miUbicacion!,
          ),
          duration: const Duration(milliseconds: 500),
          builder: (context, value, child) {
            return const Icon(Icons.person_pin_circle, color: Colors.blue, size: 40);
          },
        ),
      ),
      ..._usuarios.entries.map(
        (entry) => Marker(
          point: entry.value,
          width: 40,
          height: 40,
          child: TweenAnimationBuilder<LatLng>(
            tween: Tween<LatLng>(
              begin: entry.value,
              end: entry.value,
            ),
            duration: const Duration(milliseconds: 500),
            builder: (context, value, child) {
              return const Icon(Icons.location_on, color: Colors.red, size: 40);
            },
          ),
        ),
      )
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
      body: FlutterMap(
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
    );
  }
}
