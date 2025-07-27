import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ocrewhcitbcuflszmpyx.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9jcmV3aGNpdGJjdWZsc3ptcHl4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM1NzQ1OTYsImV4cCI6MjA2OTE1MDU5Nn0.2JvttKGn3DbL986xmAhvsqAv5BfznhWBEEaXi898VHc',
  );

  runApp(const MiAplicacion());
}

class MiAplicacion extends StatelessWidget {
  const MiAplicacion({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      primaryColor: const Color(0xFF0EA5E9),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF0EA5E9),
        secondary: Color(0xFF10B981),
        background: Color(0xFF0F172A),
        error: Color(0xFFF87171),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Color(0xFFF1F5F9)),
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GeoTrack App',
      theme: tema,
      home: VerificarAutenticacion(),
    );
  }
}