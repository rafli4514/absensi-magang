import 'package:flutter/foundation.dart';

import '../services/storage_service.dart';
import '../utils/constants.dart'; // MAKE SURE THIS IMPORT EXISTS

class OnboardProvider with ChangeNotifier {
  static bool _hasSeenOnboarding = false;

  static Future<void> init() async {
    _hasSeenOnboarding =
        (await StorageService.getBool(AppConstants.onboardSeenKey)) ?? false;
  }

  bool _onboardCompleted = _hasSeenOnboarding;

  bool get onboardCompleted => _onboardCompleted;

  OnboardProvider() {
     // Sync with static state
     _onboardCompleted = _hasSeenOnboarding;
  }
  
  // Method instance init sudah tidak diperlukan untuk startup, tapi dibiarkan jika ada use case lain
  Future<void> initInstance() async {
    await _loadOnboardStatus();
  }

  Future<void> _loadOnboardStatus() async {
    _onboardCompleted =
        (await StorageService.getBool(AppConstants.onboardSeenKey)) ?? false;
    notifyListeners();
  }

  Future<void> completeOnboard() async {
    _onboardCompleted = true;
    await StorageService.setBool(AppConstants.onboardSeenKey, true);
    notifyListeners();
  }

  Future<void> resetOnboard() async {
    _onboardCompleted = false;
    await StorageService.setBool(AppConstants.onboardSeenKey, false);
    notifyListeners();
  }
}
