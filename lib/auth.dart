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

class _VerificarAutenticacionState extends State<VerificarAutenticacion> {
  bool _yaNavego = false; // Evita redirecciones múltiples

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

    try {
      final respuesta = await Supabase.instance.client
          .from('usuarios')
          .select('rol')
          .eq('id', usuario.id)
          .single();

      final rol = respuesta['rol'];

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
        // Rol desconocido
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rol desconocido: $rol')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => IniciarSesion()),
        );
      }
    } catch (e) {
      // Error al obtener el rol
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
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.location_on, size: 90, color: Color(0xFF0EA5E9)),
            SizedBox(height: 20),
            Text(
              'GeoTrack App',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF38BDF8),
              ),
            ),
            SizedBox(height: 30),
            CircularProgressIndicator(
              color: Color(0xFF38BDF8),
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
