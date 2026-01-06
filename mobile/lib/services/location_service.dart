import 'dart:math';

import 'package:geolocator/geolocator.dart';

import '../models/api_response.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../utils/indonesian_time.dart';

class OfficeLocationSettings {
  final String officeAddress;
  final double latitude;
  final double longitude;
  final int radius;
  final bool useRadius;

  OfficeLocationSettings({
    required this.officeAddress,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.useRadius,
  });

  factory OfficeLocationSettings.fromJson(Map<String, dynamic> json) {
    return OfficeLocationSettings(
      officeAddress: json['officeAddress'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      radius: (json['radius'] as num?)?.toInt() ?? 100,
      useRadius: json['useRadius'] ?? true,
    );
  }
}

class LocationService {
  static final ApiService _apiService = ApiService();

  static Future<ApiResponse<OfficeLocationSettings>>
      getLocationSettings() async {
    return await _apiService.get(
      '${AppConstants.settingsEndpoint}/location',
      (data) => OfficeLocationSettings.fromJson(data),
    );
  }

  static Future<Map<String, dynamic>?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 8),
      );

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'address': 'Lat: ${position.latitude}, Lng: ${position.longitude}',
        'timestamp': IndonesianTime.now.toIso8601String(),
      };
    } catch (e) {
      return null;
    }
  }

  static double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371000;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static double _toRadians(double degrees) => degrees * pi / 180;

  static Future<bool> isWithinOfficeRadius(
      OfficeLocationSettings settings) async {
    if (!settings.useRadius) return true;
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      double dist = calculateDistance(position.latitude, position.longitude,
          settings.latitude, settings.longitude);
      return dist <= settings.radius;
    } catch (_) {
      return false;
    }
  }
}
