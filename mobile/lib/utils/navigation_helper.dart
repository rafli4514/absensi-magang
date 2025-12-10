import 'package:flutter/material.dart';

import '../navigation/route_names.dart';
import '../screens/activities/activities_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/change_password_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/qr_scan/qr_scan_screen.dart';
import '../screens/report/report_screen.dart';

class NavigationHelper {
  static void navigateWithoutAnimation(BuildContext context, String routeName) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) =>
            _getScreenForRoute(routeName),
        // UBAH DURASI: Beri waktu sedikit (misal 300ms) agar transisi halus
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        // TAMBAHKAN TRANSITIONS BUILDER: Gunakan Fade (pudar)
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Animasi Fade In/Out
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
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
