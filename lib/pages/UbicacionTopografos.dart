import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UbicacionTopografos extends StatefulWidget {
  const UbicacionTopografos({super.key});

  @override
  State<UbicacionTopografos> createState() => _UbicacionTopografosState();
}

class _UbicacionTopografosState extends State<UbicacionTopografos> {
  List<Map<String, dynamic>> _topografos = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _cargarUbicaciones();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _cargarUbicaciones();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _cargarUbicaciones() async {
    final data = await Supabase.instance.client
        .from('temporal')
        .select()
        .order('fecha', ascending: false);

    setState(() {
      _topografos = List<Map<String, dynamic>>.from(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: const Text('Ubicación de Topógrafos'),
      ),
      body: _topografos.isEmpty
          ? const Center(child: Text('Sin ubicaciones disponibles.'))
          : FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(_topografos.first['lat'], _topografos.first['lng']),
                initialZoom: 14,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: const ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: _topografos.map((t) {
                    final lat = t['lat'] as double;
                    final lng = t['lng'] as double;
                    final email = t['email'] ?? 'Topógrafo';
                    return Marker(
                      point: LatLng(lat, lng),
                      width: 40,
                      height: 40,
                      child: Column(
                        children: [
                          const Icon(Icons.location_on, color: Colors.red, size: 36),
                          Text(email, style: const TextStyle(fontSize: 12, color: Colors.black)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
    );
  }
}
