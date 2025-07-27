import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PanelSuperadmin extends StatelessWidget {
  const PanelSuperadmin({super.key});

  Future<void> _cerrarSesion(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.indigo.shade800,
        title: const Row(
          children: [
            Icon(Icons.verified_user_rounded, color: Colors.amberAccent),
            SizedBox(width: 8),
            Text('Panel Superadministrador', style: TextStyle(color: Colors.white)),
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
          'Bienvenido al Panel del Superadministrador',
          style: TextStyle(fontSize: 20, color: Color(0xFF0A3D62)),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
