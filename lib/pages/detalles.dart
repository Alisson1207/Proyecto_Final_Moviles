import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class DetalleTerreno extends StatelessWidget {
  final Map<String, dynamic> terreno;

  const DetalleTerreno({super.key, required this.terreno});

  @override
  Widget build(BuildContext context) {
    // Validación defensiva de los puntos
    List<LatLng> puntos = [];
    try {
      final lista = jsonDecode(terreno['puntos']);
      puntos = (lista as List)
          .map((p) => LatLng(p['lat'] as double, p['lng'] as double))
          .toList();
    } catch (_) {
      puntos = [];
    }

    final area = (terreno['area'] ?? 0).toDouble();
    final nombre = terreno['nombre'] ?? 'Sin nombre';
    final fecha = DateTime.tryParse(terreno['fecha'] ?? '') ?? DateTime.now();

    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade800,
        title: const Row(
          children: [
            Icon(Icons.terrain_rounded, color: Colors.lightGreenAccent),
            SizedBox(width: 8),
            Text('Detalle del Terreno', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      body: puntos.isEmpty
          ? const Center(
              child: Text(
                '⚠️ No se pudieron mostrar los puntos del terreno.',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: puntos.first,
                      initialZoom: 16,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: const ['a', 'b', 'c'],
                      ),
                      PolygonLayer(
                        polygons: [
                          Polygon(
                            points: puntos,
                            color: Colors.green.withOpacity(0.3),
                            borderColor: Colors.greenAccent,
                            borderStrokeWidth: 3,
                          ),
                        ],
                      ),
                      MarkerLayer(
                        markers: puntos
                            .map(
                              (p) => Marker(
                                point: p,
                                width: 30,
                                height: 30,
                                child: const Icon(Icons.location_on,
                                    color: Colors.red),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  color: Colors.blueGrey.shade800,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('🗺️ Nombre: $nombre',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16)),
                      Text('📏 Área: ${area.toStringAsFixed(2)} m²',
                          style: const TextStyle(color: Colors.white)),
                      Text('📅 Fecha: ${fecha.toLocal()}',
                          style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
