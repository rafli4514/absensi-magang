// lib/services/permission_service.dart
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // Request camera permission
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  // Request gallery permission (storage)
  static Future<bool> requestGalleryPermission() async {
    if (await Permission.storage.isGranted) {
      return true;
    }

    final status = await Permission.storage.request();
    return status.isGranted;
  }

  // Request location permission
  static Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  // Check all permissions needed for QR scan
  static Future<Map<String, bool>> checkAllPermissions() async {
    return {
      'camera': await Permission.camera.isGranted,
      'gallery': await Permission.storage.isGranted,
      'location': await Permission.location.isGranted,
    };
  }

  // Request all permissions
  static Future<Map<String, bool>> requestAllPermissions() async {
    final results = await [
      Permission.camera,
      Permission.storage,
      Permission.location,
    ].request();

    return {
      'camera': results[Permission.camera]?.isGranted ?? false,
      'gallery': results[Permission.storage]?.isGranted ?? false,
      'location': results[Permission.location]?.isGranted ?? false,
    };
  }

  // Open app settings
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
