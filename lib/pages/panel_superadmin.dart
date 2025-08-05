import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'UbicacionTopografos.dart';
class PanelSuperadmin extends StatefulWidget {
  const PanelSuperadmin({super.key});

  @override
  State<PanelSuperadmin> createState() => _PanelSuperadminState();
}

class _PanelSuperadminState extends State<PanelSuperadmin> {
  late Future<List<Map<String, dynamic>>> _usuarios;

  @override
  void initState() {
    super.initState();
    _usuarios = obtenerUsuarios();
  }

  Future<List<Map<String, dynamic>>> obtenerUsuarios() async {
    final res = await Supabase.instance.client
        .from('usuarios')
        .select()
        .order('email', ascending: true);
    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> cambiarEstado(String id, bool nuevoEstado) async {
    await Supabase.instance.client
        .from('usuarios')
        .update({'activo': nuevoEstado})
        .eq('id', id);
    setState(() {
      _usuarios = obtenerUsuarios();
    });
  }

  Future<void> eliminarUsuario(String id) async {
    await Supabase.instance.client
        .from('usuarios')
        .delete()
        .eq('id', id);
    setState(() {
      _usuarios = obtenerUsuarios();
    });
  }

  Future<void> _cerrarSesion(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECEFF1),
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
          IconButton(
            icon: const Icon(Icons.map_outlined, color: Colors.white),
            tooltip: 'Ver ubicación topógrafos',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const UbicacionTopografos(),
                ),
              );
            },
          ),
        ],
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _usuarios,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final usuarios = snapshot.data!;
          if (usuarios.isEmpty) {
            return const Center(child: Text('No hay usuarios.', style: TextStyle(color: Colors.black54)));
          }

          return ListView.builder(
            itemCount: usuarios.length,
            itemBuilder: (context, index) {
              final user = usuarios[index];
              final activo = user['activo'] ?? true;
              final rol = user['rol'] ?? 'desconocido';
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.person, color: Colors.indigo),
                  title: Text(user['email'] ?? 'Sin email'),
                  subtitle: Text('Rol: $rol\nActivo: ${activo ? "Sí" : "No"}'),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          activo ? Icons.block : Icons.check_circle,
                          color: activo ? Colors.red : Colors.green,
                        ),
                        tooltip: activo ? 'Desactivar' : 'Activar',
                        onPressed: () => cambiarEstado(user['id'], !activo),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_forever, color: Colors.grey),
                        tooltip: 'Eliminar usuario',
                        onPressed: () => eliminarUsuario(user['id']),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
