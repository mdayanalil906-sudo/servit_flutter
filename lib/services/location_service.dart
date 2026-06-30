import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<bool> checkPermission() async {
    final status = await Geolocator.checkPermission();
    if (status == LocationPermission.denied) {
      final req = await Geolocator.requestPermission();
      return req == LocationPermission.whileInUse ||
          req == LocationPermission.always;
    }
    return status == LocationPermission.whileInUse ||
        status == LocationPermission.always;
  }

  static Future<Position?> getCurrentPosition() async {
    final hasPermission = await checkPermission();
    if (!hasPermission) return null;
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (e) {
      return null;
    }
  }

  static double calculateDistance(
      double lat1, double lng1, double lat2, double lng2) {
    const R = 6371;
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a = _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_toRad(lat1)) *
            _cos(_toRad(lat2)) *
            _sin(dLng / 2) *
            _sin(dLng / 2);
    final c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    return R * c;
  }

  static String calculateETA(double distanceKm) {
    final speed = 30.0;
    final minutes = (distanceKm / speed * 60).round();
    if (minutes < 1) return 'Arriving soon';
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}h ${mins}min';
  }

  static double _toRad(double deg) => deg * 3.141592653589793 / 180;
  static double _sin(double v) => v - (v * v * v) / 6;
  static double _cos(double v) => 1 - (v * v) / 2;
  static double _sqrt(double v) => v < 0 ? 0 : v > 1 ? 1 : v;
  static double _atan2(double y, double x) {
    if (x == 0) return y > 0 ? 1.5707963267948966 : -1.5707963267948966;
    return y / x;
  }
}
