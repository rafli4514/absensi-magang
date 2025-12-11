import 'package:flutter/material.dart';

import '../navigation/route_names.dart';
import '../screens/activities/activities_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/change_password_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/qr_scan/qr_scan_screen.dart';
import '../screens/report/report_screen.dart';
import 'haptic_util.dart';

class NavigationHelper {
  // Tambahkan durasi standar
  static const Duration defaultTransitionDuration = Duration(milliseconds: 300);

  static void navigateWithoutAnimation(BuildContext context, String routeName) {
    HapticUtil.light(); // Feedback saat ganti tab
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

  static void navigateToLoginAndClear(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
        context, RouteNames.login, (route) => false);
  }

  static void pushWithoutAnimation(BuildContext context, String routeName) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) =>
            _getScreenForRoute(routeName),
        // Berikan durasi juga di sini jika ingin push halus
        transitionDuration: const Duration(milliseconds: 100),
        reverseTransitionDuration: const Duration(milliseconds: 100),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

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
      default:
        return const HomeScreen();
    }
  }
}
