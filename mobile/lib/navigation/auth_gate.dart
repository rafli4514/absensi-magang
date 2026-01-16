import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../providers/onboard_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/admin/admin_home_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/mentor_home_screen.dart';
import '../screens/onboard/onboard_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Cek User sudah login atau belum (Synchronous & Cepat)
    final isLoggedIn = AuthService.isLoggedIn;
    
    // 2. Jika belum login -> ke LoginScreen
    if (!isLoggedIn) {
      return const LoginScreen();
    }

    // 3. Jika sudah login -> Cek Onboarding & Role
    return Consumer<OnboardProvider>(
      builder: (context, onboardProvider, _) {
         // Cek onboarding (Jika belum selesai, force ke onboarding)
         if (!onboardProvider.onboardCompleted) {
            return const OnboardScreen();
         }

         // Redirect berdasarkan Role User yang tersimpan di static
         final user = AuthService.currentUser;
         if (user?.isAdmin ?? false) {
            return const AdminHomeScreen();
         } else if (user?.isPembimbing ?? false) {
            return const MentorHomeScreen();
         } else {
            return const HomeScreen();
         }
      },
    );
  }
}
