import '../models/api_response.dart';
import '../models/onboard_model.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class OnboardService {
  static Future<ApiResponse<List<OnboardPage>>> getOnboardPages() async {
    try {
      // For now, return mock data. You can replace this with API call later
      final mockPages = [
        OnboardPage(
          id: '1',
          title: 'Welcome to Employee App',
          description:
              'Manage your attendance and activities efficiently with our mobile application.',
          imageUrl: 'assets/images/onboard1.png',
          order: 1,
        ),
        OnboardPage(
          id: '2',
          title: 'Easy Attendance',
          description:
              'Clock in and out easily using QR code scanning or location-based attendance.',
          imageUrl: 'assets/images/onboard2.png',
          order: 2,
        ),
        OnboardPage(
          id: '3',
          title: 'Track Your Progress',
          description:
              'Monitor your attendance history, leaves, and performance in one place.',
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
      print('Error marking onboard completed: $e');
      return false;
    }
  }

  static Future<bool> resetOnboard() async {
    try {
      await StorageService.setBool(AppConstants.onboardSeenKey, false);
      return true;
    } catch (e) {
      print('Error resetting onboard: $e');
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
      print('Error checking first launch: $e');
      return true;
    }
  }
}
