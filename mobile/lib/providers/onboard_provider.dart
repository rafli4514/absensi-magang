import 'package:flutter/foundation.dart';

import '../services/storage_service.dart';
import '../utils/constants.dart'; // MAKE SURE THIS IMPORT EXISTS

class OnboardProvider with ChangeNotifier {
  bool _onboardCompleted = false;

  bool get onboardCompleted => _onboardCompleted;

  OnboardProvider() {
    _loadOnboardStatus();
  }

  Future<void> _loadOnboardStatus() async {
    _onboardCompleted = (await StorageService.getBool(AppConstants.onboardSeenKey)) ?? false;
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
