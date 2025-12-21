// lib/services/location_service.dart
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

  // Cache ringan untuk setting lokasi kantor selama sesi aplikasi
  static OfficeLocationSettings? _cachedLocationSettings;
  static DateTime? _cachedLocationFetchedAt;

  static Future<ApiResponse<OfficeLocationSettings>> getLocationSettings({
    bool forceRefresh = false,
  }) async {
    try {
      // Gunakan cache jika masih dianggap fresh (misal 5 menit)
      if (!forceRefresh &&
          _cachedLocationSettings != null &&
          _cachedLocationFetchedAt != null) {
        final diff = DateTime.now().difference(_cachedLocationFetchedAt!);
        if (diff.inMinutes < 5) {
          return ApiResponse<OfficeLocationSettings>(
            success: true,
            data: _cachedLocationSettings,
            message: 'Location settings loaded from cache',
            statusCode: 200,
          );
        }
      }

      final response = await _apiService.get(
        '${AppConstants.settingsEndpoint}/location',
        (data) => OfficeLocationSettings.fromJson(data),
      );

      if (response.success && response.data != null) {
        _cachedLocationSettings = response.data;
        _cachedLocationFetchedAt = DateTime.now();
      }

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

  // PERBAIKAN: Menambahkan parameter akurasi dan detail waktu
  // NOTE: Method ini sudah deprecated, gunakan AttendanceService.createAttendance langsung
  @Deprecated('Use AttendanceService.createAttendance instead')
  static Future<ApiResponse<Map<String, dynamic>>> submitAttendance({
    required String type,
    required String sessionId,
    required double latitude,
    required double longitude,
    required String locationAddress,
  }) async {
    try {
      final now = IndonesianTime.now; // Use Indonesian time

      // Data yang dikirim disinkronkan agar formatnya jelas di Backend
      final Map<String, dynamic> body = {
        'type': type,
        'sessionId': sessionId,
        'location': {
          'latitude': latitude,
          'longitude': longitude,
          'address': locationAddress,
          // Opsional: Tambahkan akurasi jika didukung backend
          // 'accuracy': 0.0,
        },
        'timestamp': now.toIso8601String(),
        'timezone_offset': now.timeZoneOffset.inMinutes, // Info zona waktu
      };

      final response = await _apiService.post(
        AppConstants.attendanceEndpoint,
        body,
        (data) => data as Map<String, dynamic>,
      );

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

      // Gunakan akurasi tinggi untuk validasi jarak kantor, dengan batas waktu
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation,
          timeLimit: const Duration(seconds: 8),
        );
      } catch (e) {
        // Jika timeout/error, coba gunakan last known position
        position = await Geolocator.getLastKnownPosition();
        if (position == null) {
          rethrow;
        }
      }

      final distance = calculateDistance(
        position.latitude,
        position.longitude,
        settings.latitude,
        settings.longitude,
      );

      // Tambahkan toleransi sedikit (misal akurasi GPS)
      // Jarak harus <= radius kantor
      return distance <= settings.radius;
    } catch (e) {
      print('❌ [LOCATION SERVICE] Error checking location: $e');
      return false;
    }
  }

  // PERBAIKAN: Format alamat lebih informatif untuk ditampilkan di QR Screen
  static Future<Map<String, dynamic>?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Coba request enable service
        // serviceEnabled = await Geolocator.openLocationSettings();
        // if (!serviceEnabled) return null;
        return null;
      }

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

      // Gunakan 'high' accuracy untuk presensi, jangan 'best' jika hanya untuk display (hemat baterai)
      Position? position;
      try {
        // Batasi waktu tunggu agar UI tidak lama di status "Mendeteksi lokasi..."
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 8),
        );
      } catch (e) {
        // Jika timeout atau error lain, fallback ke last known position
        position = await Geolocator.getLastKnownPosition();
        if (position == null) {
          rethrow;
        }
      }

      // Format alamat yang lebih rapi
      String address =
          'Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}';

      // Jika nanti mau pakai reverse geocoding (ambil nama jalan), bisa ditambahkan di sini
      // String realAddress = await _getGeocodingAddress(position);

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'altitude': position.altitude,
        'address': address, // Bisa diganti real address jika ada geocoding
        'timestamp': IndonesianTime.now.toIso8601String(), // Use Indonesian time
      };
    } catch (e) {
      print('❌ [LOCATION SERVICE] Error getting location: $e');
      return null;
    }
  }
}