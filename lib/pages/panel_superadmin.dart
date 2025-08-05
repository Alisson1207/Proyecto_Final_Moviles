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

  Future<void> _crearUsuario(String email, String password, String rol) async {
    try {
      final authResponse = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('No se pudo crear el usuario en autenticación');
      }

      final userId = authResponse.user!.id;

      await Supabase.instance.client.from('usuarios').insert({
        'id': userId,
        'email': email,
        'rol': rol,
        'activo': true,
      });

      setState(() {
        _usuarios = obtenerUsuarios();
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario agregado correctamente')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al agregar usuario: $e')),
      );
    }
  }

  void _mostrarDialogoAgregarUsuario() {
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    String rolSeleccionado = 'topografo'; 

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Agregar Usuario',
            style: TextStyle(color: Colors.white),
          ),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: emailCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white54),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  const SizedBox(height: 12),
                    TextField(
                      controller: passwordCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Contraseña',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white54),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: rolSeleccionado,
                      items: [
                        DropdownMenuItem(value: 'topografo', child: Text('Topógrafo', style: TextStyle(color: Colors.white))),
                        DropdownMenuItem(value: 'admin', child: Text('Administrador', style: TextStyle(color: Colors.white))),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setStateDialog(() {
                            rolSeleccionado = val;
                          });
                        }
                      },
                      style: const TextStyle(color: Colors.white), 
                      decoration: const InputDecoration(
                        labelText: 'Rol',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white54),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),

                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = emailCtrl.text.trim();
                final password = passwordCtrl.text.trim();

                if (email.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('El email no puede estar vacío')),
                  );
                  return;
                }
                if (password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('La contraseña no puede estar vacía')),
                  );
                  return;
                }

                Navigator.pop(context);
                await _crearUsuario(email, password, rolSeleccionado);
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
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
            Text('Panel Superadmin', style: TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            tooltip: 'Agregar usuario',
            onPressed: _mostrarDialogoAgregarUsuario,
          ),
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
            return const Center(
              child: Text('No hay usuarios.', style: TextStyle(color: Colors.black54)),
            );
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
