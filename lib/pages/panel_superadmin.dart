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
      backgroundColor: Color(0xFFECEFF1),
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
    );
  }
}
