import 'package:flutter/material.dart';

import '../screens/activities/activities_screen.dart';
// IMPORT FILE ADMIN YANG BARU DIBUAT
import '../screens/admin/admin_home_screen.dart';
import '../screens/admin/admin_interns_screen.dart';
import '../screens/admin/admin_qr_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/mentor_home_screen.dart'; // IMPORT MENTOR
import '../screens/mentor/mentee_detail_screen.dart';
import '../screens/mentor/mentor_validation_screen.dart';
import '../screens/onboard/onboard_screen.dart';
import '../screens/onboard/onboard_welcome_screen.dart';
import '../screens/profile/change_password_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/qr_scan/qr_scan_screen.dart';
import '../screens/report/report_screen.dart';
import '../screens/splash/splash_screen.dart';
import 'route_names.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // ... (rute splash, onboard, login, register tetap sama)
      case RouteNames.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case RouteNames.onboard:
        return MaterialPageRoute(builder: (_) => const OnboardScreen());
      case RouteNames.onboardWelcome:
        return MaterialPageRoute(builder: (_) => const OnboardWelcomeScreen());
      case RouteNames.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case RouteNames.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case RouteNames.mentorValidation:
        return MaterialPageRoute(
            builder: (_) => const MentorValidationScreen());
      case RouteNames.menteeDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
            builder: (_) => MenteeDetailScreen(menteeData: args));
      case RouteNames.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      // FIX: Mentor Screen
      case RouteNames.mentorHome:
        return MaterialPageRoute(builder: (_) => const MentorHomeScreen());

      // FIX: Admin Screen
      case RouteNames.adminHome:
        return MaterialPageRoute(builder: (_) => const AdminHomeScreen());

      // --- ADMIN FEATURES ---
      case RouteNames.adminInterns:
        return MaterialPageRoute(builder: (_) => const AdminInternsScreen());
      case RouteNames.adminQR:
        return MaterialPageRoute(builder: (_) => const AdminQrScreen());

      // ... (rute profile, activities, report tetap sama)
      case RouteNames.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case RouteNames.editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      case RouteNames.changePassword:
        return MaterialPageRoute(builder: (_) => const ChangePasswordScreen());
      case RouteNames.activities:
        return MaterialPageRoute(builder: (_) => const ActivitiesScreen());
      case RouteNames.qrScan:
        return MaterialPageRoute(builder: (_) => const QrScanScreen());
      case RouteNames.report:
        return MaterialPageRoute(builder: (_) => const ReportScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
