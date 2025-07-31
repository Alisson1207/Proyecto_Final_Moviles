import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final supabase = Supabase.instance.client;

  static Future<bool> enviarMiUbicacion(double lat, double lng) async {
    try {
      final user = supabase.auth.currentUser;
      final userId = user?.id;
      
      if (userId == null) {
        return false;
      }

      final existingLocation = await supabase
          .from('ubicaciones')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();

      if (existingLocation != null) {
        await supabase
            .from('ubicaciones')
            .update({
              'lat': lat,
              'lng': lng,
              'updated_at': DateTime.now().toIso8601String()
            })
            .eq('user_id', userId);
      } else {
        await supabase.from('ubicaciones').insert({
          'user_id': userId,
          'lat': lat,
          'lng': lng,
          'updated_at': DateTime.now().toIso8601String()
        });
      }

      return true;
    } catch (e) {
      print('Error al enviar ubicación: $e');
      return false;
    }
  }

  static void escucharUbicaciones(Function(String, LatLng) callback) {
    supabase.from('ubicaciones')
      .stream(primaryKey: ['id'])
      .listen((data) {
        for (final item in data) {
          final lat = item['lat'];
          final lng = item['lng'];
          final userId = item['user_id'];
          if (lat != null && lng != null && userId != null) {
            callback(userId, LatLng(lat, lng));
          }
        }
      });
  }
}

