import 'package:flutter/material.dart';

import '../navigation/route_names.dart';
import '../screens/activities/activities_screen.dart';
import '../screens/home/home_screen.dart';
// IMPORT SCREEN MENTOR
import '../screens/home/mentor_home_screen.dart';
import '../screens/mentor/mentor_validation_screen.dart';
import '../screens/profile/change_password_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/qr_scan/qr_scan_screen.dart';
import '../screens/report/report_screen.dart';
import 'haptic_util.dart';

class NavigationHelper {
  static const Duration defaultTransitionDuration = Duration(milliseconds: 300);

  static void navigateWithoutAnimation(BuildContext context, String routeName) {
    HapticUtil.light();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) =>
            _getScreenForRoute(routeName),
        transitionDuration: defaultTransitionDuration,
        reverseTransitionDuration: defaultTransitionDuration,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  // ... (fungsi lain tetap sama)

  static Widget _getScreenForRoute(String routeName) {
    switch (routeName) {
      case RouteNames.home:
        return const HomeScreen();
      case RouteNames.activities:
        return const ActivitiesScreen();
      case RouteNames.report:
        return const ReportScreen();
      case RouteNames.profile:
        return const ProfileScreen();
      case RouteNames.qrScan:
        return const QrScanScreen();
      case RouteNames.editProfile:
        return const EditProfileScreen();
      case RouteNames.changePassword:
        return const ChangePasswordScreen();

      // --- TAMBAHKAN BAGIAN INI ---
      case RouteNames.mentorHome:
        return const MentorHomeScreen();
      case RouteNames.mentorValidation:
        return const MentorValidationScreen();
      // ----------------------------

      default:
        return const HomeScreen();
    }
  }
}
