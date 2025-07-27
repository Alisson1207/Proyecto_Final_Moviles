import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PanelAdmin extends StatelessWidget {
  const PanelAdmin({super.key});

  Future<void> _cerrarSesion(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade800,
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings_outlined, color: Colors.amberAccent),
            SizedBox(width: 8),
            Text('Panel Admin', style: TextStyle(color: Colors.white)),
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
        child: Text(
          'Bienvenido al Panel del Administrador',
          style: TextStyle(fontSize: 20, color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
