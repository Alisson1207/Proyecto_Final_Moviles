import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/login.dart';
import 'pages/mapa.dart';
import 'pages/panel_admin.dart';
import 'pages/panel_superadmin.dart';

class VerificarAutenticacion extends StatefulWidget {
  @override
  State<VerificarAutenticacion> createState() => _VerificarAutenticacionState();
}

class _VerificarAutenticacionState extends State<VerificarAutenticacion>
    with SingleTickerProviderStateMixin {
  bool _yaNavego = false;
  String? _mensaje;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _redirigir();
    });
  }

  Future<void> _redirigir() async {
    if (_yaNavego) return;
    _yaNavego = true;

    final sesion = Supabase.instance.client.auth.currentSession;

    if (sesion == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => IniciarSesion()),
      );
      return;
    }

    final usuario = Supabase.instance.client.auth.currentUser;

    if (usuario == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => IniciarSesion()),
      );
      return;
    }

    setState(() {
      _mensaje = 'Bienvenido de nuevo 👋';
    });

    try {
      final respuesta = await Supabase.instance.client
          .from('usuarios')
          .select('rol')
          .eq('id', usuario.id)
          .single();

      final rol = respuesta['rol'];

      await Future.delayed(const Duration(seconds: 2)); // pequeña pausa visual

      if (rol == 'topografo') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => PantallaMapa()),
        );
      } else if (rol == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => PanelAdmin()),
        );
      } else if (rol == 'superadmin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => PanelSuperadmin()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rol desconocido: $rol')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => IniciarSesion()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al verificar el rol')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => IniciarSesion()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // azul oscuro elegante
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_searching, size: 90, color: Color(0xFF38BDF8)),
            const SizedBox(height: 20),
            const Text(
              'GeoTrack App',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF38BDF8),
              ),
            ),
            if (_mensaje != null) ...[
              const SizedBox(height: 12),
              Text(
                _mensaje!,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 30),
            const CircularProgressIndicator(
              color: Color(0xFF38BDF8),
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
