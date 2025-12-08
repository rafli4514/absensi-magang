import 'package:permission_handler/permission_handler.dart' as handler;

class PermissionService {
  // Request camera permission
  static Future<bool> requestCameraPermission() async {
    final status = await handler.Permission.camera.request();
    return status.isGranted;
  }

  // Request gallery permission (storage)
  static Future<bool> requestGalleryPermission() async {
    // Cek dulu, kalau sudah granted langsung return true
    if (await handler.Permission.storage.isGranted ||
        await handler.Permission.photos.isGranted) {
      return true;
    }

    // Request storage (untuk Android < 13)
    final statusStorage = await handler.Permission.storage.request();

    // Request photos (untuk Android 13+)
    final statusPhotos = await handler.Permission.photos.request();

    return statusStorage.isGranted || statusPhotos.isGranted;
  }

  // Request location permission
  static Future<bool> requestLocationPermission() async {
    final status = await handler.Permission.location.request();
    return status.isGranted;
  }

  // Check all permissions needed for QR scan
  static Future<Map<String, bool>> checkAllPermissions() async {
    return {
      'camera': await handler.Permission.camera.isGranted,
      'gallery':
          await handler.Permission.storage.isGranted ||
          await handler.Permission.photos.isGranted,
      'location': await handler.Permission.location.isGranted,
    };
  }

  // Open app settings
  static Future<void> openAppSettings() async {
    // PERBAIKAN UTAMA: Panggil dari handler, bukan diri sendiri
    await handler.openAppSettings();
  }
}
