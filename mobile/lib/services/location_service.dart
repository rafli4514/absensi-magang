import 'dart:math';

import 'package:geolocator/geolocator.dart';

import '../models/api_response.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

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

class QRValidationResponse {
  final bool isValid;
  final Map<String, dynamic> data;
  final String type;
  final String sessionId;

  QRValidationResponse({
    required this.isValid,
    required this.data,
    required this.type,
    required this.sessionId,
  });

  factory QRValidationResponse.fromJson(Map<String, dynamic> json) {
    return QRValidationResponse(
      isValid: json['isValid'] ?? false,
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      type: json['type'] ?? '',
      sessionId: json['sessionId'] ?? '',
    );
  }
}

class LocationService {
  static final ApiService _apiService = ApiService();

  static Future<ApiResponse<OfficeLocationSettings>>
  getLocationSettings() async {
    try {
      final response = await _apiService.get(
        '${AppConstants.settingsEndpoint}/location',
        (data) => OfficeLocationSettings.fromJson(data),
      );

      return response;
    } catch (e) {
      return ApiResponse<OfficeLocationSettings>(
        success: false,
        message: 'Failed to get location settings: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  static Future<ApiResponse<QRValidationResponse>> validateQRCode(
    String qrData,
  ) async {
    try {
      final response = await _apiService.post(
        '${AppConstants.qrEndpoint}/validate',
        {'qrData': qrData},
        (data) => QRValidationResponse.fromJson(data),
      );

      return response;
    } catch (e) {
      return ApiResponse<QRValidationResponse>(
        success: false,
        message: 'Failed to validate QR code: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> submitAttendance({
    required String type,
    required String sessionId,
    required double latitude,
    required double longitude,
    required String locationAddress,
  }) async {
    try {
      final response = await _apiService.post(AppConstants.attendanceEndpoint, {
        'type': type,
        'sessionId': sessionId,
        'location': {
          'latitude': latitude,
          'longitude': longitude,
          'address': locationAddress,
        },
        'timestamp': DateTime.now().toIso8601String(),
      }, (data) => data as Map<String, dynamic>);

      return response;
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Failed to submit attendance: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371000;

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  static double _toRadians(double degrees) {
    return degrees * pi / 180;
  }

  static Future<bool> isWithinOfficeRadius(
    OfficeLocationSettings settings,
  ) async {
    try {
      if (!settings.useRadius) {
        return true;
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final distance = calculateDistance(
        position.latitude,
        position.longitude,
        settings.latitude,
        settings.longitude,
      );

      return distance <= settings.radius;
    } catch (e) {
      print('❌ [LOCATION SERVICE] Error checking location: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      // Get current position
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Simple address format - you can enhance this later
      String address =
          'Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}';

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'address': address,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('❌ [LOCATION SERVICE] Error getting location: $e');
      return null;
    }
  }
}
