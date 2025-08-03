import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final supabase = Supabase.instance.client;


  static Future<bool> enviarMiUbicacion(double lat, double lng) async {
    try {
      await supabase.from('ubicaciones').insert({
        'lat': lat,
        'lng': lng,
        'updated_at': DateTime.now().toIso8601String()
      });
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

          if (lat != null && lng != null) {
            callback('desconocido', LatLng(lat, lng)); 
          }
        }
      });
  }
}
