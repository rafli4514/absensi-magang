import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  // Check location permissions
  Future<bool> checkPermission() async {
    final status = await Permission.location.status;
    if (status.isGranted) {
      return true;
    } else {
      final result = await Permission.location.request();
      return result.isGranted;
    }
  }

  // Get current position
  Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await checkPermission();
      if (!hasPermission) {
        throw Exception('Location permission denied');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return position;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  // Calculate distance between two coordinates
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  // Check if location is within radius
  bool isWithinRadius({
    required double currentLat,
    required double currentLng,
    required double targetLat,
    required double targetLng,
    required double radius,
  }) {
    final distance = calculateDistance(
      currentLat,
      currentLng,
      targetLat,
      targetLng,
    );
    return distance <= radius;
  }

  // Get location address - SIMPLIFIED VERSION without geocoding
  Future<String?> getAddressFromCoordinates(double lat, double lng) async {
    try {
      // Return simple coordinates format
      return 'Lat: ${lat.toStringAsFixed(6)}, Lng: ${lng.toStringAsFixed(6)}';
    } catch (e) {
      print('Error getting address: $e');
      return null;
    }
  }

  // Get formatted location data for API
  Future<Map<String, dynamic>?> getLocationData() async {
    try {
      final position = await getCurrentPosition();
      if (position != null) {
        final address = await getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );

        return {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'accuracy': position.accuracy,
          'altitude': position.altitude,
          'speed': position.speed,
          'speedAccuracy': position.speedAccuracy,
          'heading': position.heading,
          'timestamp': position.timestamp?.toIso8601String(),
          'address': address,
        };
      }
      return null;
    } catch (e) {
      print('Error getting location data: $e');
      return null;
    }
  }
}
