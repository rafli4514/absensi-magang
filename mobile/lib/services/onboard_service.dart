import '../models/api_response.dart';
import '../models/onboard_model.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class OnboardService {
  static Future<ApiResponse<List<OnboardPage>>> getOnboardPages() async {
    try {
      final mockPages = [
        OnboardPage(
          id: '1',
          title: 'Selamat Datang di MyInternPlus',
          description:
              'Kelola absensi dan aktivitas magangmu dengan mudah, efisien, dan terorganisir dalam satu aplikasi.',
          imageUrl: 'assets/images/onboard1.png',
          order: 1,
        ),
        OnboardPage(
          id: '2',
          title: 'Absensi Mudah & Cepat',
          description:
              'Cukup scan QR Code atau gunakan lokasi untuk melakukan Clock In dan Clock Out dalam hitungan detik.',
          imageUrl: 'assets/images/onboard2.png',
          order: 2,
        ),
        OnboardPage(
          id: '3',
          title: 'Pantau Progresmu',
          description:
              'Lihat riwayat kehadiran, catatan aktivitas, dan performa magangmu secara real-time.',
          imageUrl: 'assets/images/onboard3.png',
          order: 3,
        ),
      ];

      return ApiResponse(
        success: true,
        data: mockPages,
        message: 'Onboard pages retrieved successfully',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Failed to load onboard pages: $e',
      );
    }
  }

  static Future<bool> markOnboardCompleted() async {
    try {
      await StorageService.setBool(AppConstants.onboardSeenKey, true);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> resetOnboard() async {
    try {
      await StorageService.setBool(AppConstants.onboardSeenKey, false);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> checkFirstLaunch() async {
    try {
      final firstLaunch = await StorageService.getBool(
        AppConstants.firstLaunchKey,
      );
      if (firstLaunch == null) {
        await StorageService.setBool(AppConstants.firstLaunchKey, false);
        return true;
      }
      return false;
    } catch (e) {
      return true;
    }
  }
}
