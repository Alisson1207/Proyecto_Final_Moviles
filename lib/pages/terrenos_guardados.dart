import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'detalles.dart';

class PantallaTerrenosGuardados extends StatelessWidget {
  const PantallaTerrenosGuardados({super.key});

  Future<List<Map<String, dynamic>>> obtenerTerrenos() async {
    final datos = await Supabase.instance.client
        .from('terrenos_trazados')
        .select()
        .order('fecha', ascending: false);

    return List<Map<String, dynamic>>.from(datos);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade800,
        title: const Row(
          children: [
            Icon(Icons.map_outlined, color: Colors.lightGreenAccent),
            SizedBox(width: 8),
            Text('Terrenos Trazados', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: obtenerTerrenos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final terrenos = snapshot.data ?? [];

          if (terrenos.isEmpty) {
            return const Center(
              child: Text(
                'No hay terrenos trazados aún.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            itemCount: terrenos.length,
            itemBuilder: (context, index) {
              final terreno = terrenos[index];
              final fecha = DateTime.tryParse(terreno['fecha']) ?? DateTime.now();
              final area = terreno['area'] ?? 0.0;
              final nombre = terreno['nombre'] ?? 'Terreno sin nombre';

              return ListTile(
                title: Text(
                  nombre,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  'Área: ${area.toStringAsFixed(2)} m²\n${fecha.toLocal()}',
                  style: const TextStyle(color: Colors.white60),
                ),
                trailing: const Icon(Icons.keyboard_arrow_right, color: Colors.white),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetalleTerreno(terreno: terreno),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
