import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  // Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Check location permission
  static Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  // Request location permission
  static Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  // Get current position
  static Future<Position?> getCurrentPosition() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      // Check permission
      LocationPermission permission = await checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      print('Error getting current position: $e');
      return null;
    }
  }

  // Get current location as string
  static Future<String> getCurrentLocationString() async {
    try {
      final position = await getCurrentPosition();
      if (position != null) {
        return '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
      }
      return 'Lokasi tidak dapat diakses';
    } catch (e) {
      return 'Lokasi tidak dapat diakses';
    }
  }

  // Calculate distance between two points
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  // Check if user is within office radius
  static Future<bool> isWithinOfficeRadius({
    required double officeLat,
    required double officeLon,
    required double radiusInMeters,
  }) async {
    try {
      final position = await getCurrentPosition();
      if (position == null) return false;

      final distance = calculateDistance(
        position.latitude,
        position.longitude,
        officeLat,
        officeLon,
      );

      return distance <= radiusInMeters;
    } catch (e) {
      print('Error checking office radius: $e');
      return false;
    }
  }

  // Get address from coordinates
  static Future<String> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      // For now, return coordinates as address
      // In a real app, you would use a geocoding service
      return 'Lat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}';
    } catch (e) {
      print('Error getting address: $e');
      return 'Alamat tidak ditemukan';
    }
  }

  // Get current address
  static Future<String> getCurrentAddress() async {
    try {
      final position = await getCurrentPosition();
      if (position != null) {
        return await getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );
      }
      return 'Alamat tidak dapat diakses';
    } catch (e) {
      return 'Alamat tidak dapat diakses';
    }
  }

  // Request location permission with dialog
  static Future<bool> requestLocationPermissionWithDialog() async {
    final status = await Permission.location.request();
    return status == PermissionStatus.granted;
  }

  // Check if location permission is granted
  static Future<bool> isLocationPermissionGranted() async {
    final status = await Permission.location.status;
    return status == PermissionStatus.granted;
  }

  // Open location settings
  static Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  // Open app settings
  static Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}
