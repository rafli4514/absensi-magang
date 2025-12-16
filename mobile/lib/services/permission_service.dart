import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart' as handler;

class PermissionService {
  // Request camera permission
  static Future<bool> requestCameraPermission() async {
    // Web akan prompt sendiri saat akses kamera
    if (kIsWeb) {
      return true;
    }

    try {
      final status = await handler.Permission.camera.request();
      return status.isGranted;
    } catch (e) {
      // Jika permission tidak didukung, return true
      return true;
    }
  }

  // Request gallery permission (storage)
  static Future<bool> requestGalleryPermission() async {
    // Web tidak memerlukan permission storage
    if (kIsWeb) {
      return true;
    }

    // Cek dulu, kalau sudah granted langsung return true
    try {
      if (await handler.Permission.storage.isGranted ||
          await handler.Permission.photos.isGranted) {
        return true;
      }

      // Request storage (untuk Android < 13)
      final statusStorage = await handler.Permission.storage.request();

      // Request photos (untuk Android 13+)
      final statusPhotos = await handler.Permission.photos.request();

      return statusStorage.isGranted || statusPhotos.isGranted;
    } catch (e) {
      // Jika permission tidak didukung di platform ini, return true
      return true;
    }
  }

  // Request location permission
  static Future<bool> requestLocationPermission() async {
    // Web menggunakan browser geolocation API, tidak perlu permission handler
    if (kIsWeb) {
      // Di web, geolocation akan diprompt oleh browser
      return true;
    }

    try {
      final status = await handler.Permission.location.request();
      return status.isGranted;
    } catch (e) {
      // Jika permission tidak didukung, return true
      return true;
    }
  }

  // Check all permissions needed for QR scan
  static Future<Map<String, bool>> checkAllPermissions() async {
    // Web tidak memerlukan permission check yang sama seperti mobile
    if (kIsWeb) {
      return {
        'camera': true, // Web akan prompt sendiri saat akses kamera
        'gallery': true, // Web tidak memerlukan storage permission
        'location': true, // Web akan prompt sendiri saat akses lokasi
      };
    }

    try {
      return {
        'camera': await handler.Permission.camera.isGranted,
        'gallery': await handler.Permission.storage.isGranted ||
            await handler.Permission.photos.isGranted,
        'location': await handler.Permission.location.isGranted,
      };
    } catch (e) {
      // Jika ada error (misalnya permission tidak didukung), return semua true
      return {
        'camera': true,
        'gallery': true,
        'location': true,
      };
    }
  }

  // Open app settings
  static Future<void> openAppSettings() async {
    // PERBAIKAN UTAMA: Panggil dari handler, bukan diri sendiri
    await handler.openAppSettings();
  }
}
