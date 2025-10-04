import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricService {
  static final LocalAuthentication _localAuth = LocalAuthentication();

  // Check if biometric authentication is available
  static Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      print('Error checking biometric availability: $e');
      return false;
    }
  }

  // Get available biometric types
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
  } catch (e) {
      print('Error getting available biometrics: $e');
      return [];
    }
  }

  // Authenticate with biometric
  static Future<bool> authenticate({
    required String reason,
    String? cancelButton,
  }) async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        return false;
      }

      final result = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          sensitiveTransaction: true,
        ),
      );

      return result;
    } catch (e) {
      print('Error during biometric authentication: $e');
      return false;
    }
  }

  // Authenticate for attendance
  static Future<bool> authenticateForAttendance() async {
    return await authenticate(
      reason: 'Gunakan autentikasi biometrik untuk verifikasi absensi',
    );
  }

  // Authenticate for login
  static Future<bool> authenticateForLogin() async {
    return await authenticate(
      reason: 'Gunakan autentikasi biometrik untuk masuk ke aplikasi',
    );
  }

  // Check if biometric is enabled in settings
  static Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('biometric_enabled') ?? false;
  }

  // Enable biometric authentication
  static Future<void> enableBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', true);
  }

  // Disable biometric authentication
  static Future<void> disableBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', false);
  }

  // Get biometric type name
  static String getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.iris:
        return 'Iris';
      case BiometricType.strong:
        return 'Strong Biometric';
      case BiometricType.weak:
        return 'Weak Biometric';
    }
  }

  // Get all available biometric types as string
  static Future<String> getAvailableBiometricTypesString() async {
    final types = await getAvailableBiometrics();
    if (types.isEmpty) {
      return 'Tidak ada autentikasi biometrik yang tersedia';
    }
    
    final typeNames = types.map((type) => getBiometricTypeName(type)).join(', ');
    return 'Tersedia: $typeNames';
  }

  // Check if user can use biometric for attendance
  static Future<bool> canUseBiometricForAttendance() async {
    final isAvailable = await isBiometricAvailable();
    final isEnabled = await isBiometricEnabled();
    return isAvailable && isEnabled;
  }

  // Setup biometric for first time
  static Future<bool> setupBiometric() async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        return false;
      }

      // Test authentication
      final result = await authenticate(
        reason: 'Atur autentikasi biometrik untuk aplikasi absensi',
      );

      if (result) {
        await enableBiometric();
        return true;
      }
      return false;
    } catch (e) {
      print('Error setting up biometric: $e');
      return false;
    }
  }

  // Show biometric settings dialog
  static Future<void> showBiometricSettingsDialog() async {
    // This would typically show a dialog with biometric settings
    // For now, we'll just enable/disable based on availability
    final isAvailable = await isBiometricAvailable();
    if (isAvailable) {
      final isEnabled = await isBiometricEnabled();
      if (isAvailable) {
        await disableBiometric();
      } else {
        await enableBiometric();
      }
    }
  }
}