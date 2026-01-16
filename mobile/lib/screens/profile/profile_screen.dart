import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../navigation/route_names.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../screens/profile/profile_logic.dart';
import '../../themes/app_themes.dart';
import '../../utils/navigation_helper.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/floating_bottom_nav.dart';
import '../../widgets/mentor_bottom_nav.dart';
import '../../widgets/profile_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: 'Keluar',
        content: 'Apakah Anda yakin ingin keluar dari aplikasi?',
        primaryButtonText: 'Keluar',
        primaryButtonColor: colorScheme.error,
        onPrimaryButtonPressed: () async {
          await authProvider.logout();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              RouteNames.login,
              (route) => false,
            );
          }
        },
        secondaryButtonText: 'Batal',
      ),
    );
  }

  // --- HELPER NAVIGASI QR ---
  Future<void> _handleQRScan(BuildContext context) async {
    final result = await Navigator.pushNamed(context, RouteNames.qrScan);
    if (result != null && result is Map && result['success'] == true) {
      if (context.mounted) {
        NavigationHelper.navigateWithoutAnimation(context, RouteNames.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final user = authProvider.user;

    // FIX: Ambil ColorScheme dari Theme context
    final colorScheme = Theme.of(context).colorScheme;

    // Logic Extract Data menggunakan pattern matching (Dart 3.0+)
    final (:displayDivisi, :displayInstansi, :mentorName, :isStudent) =
        ProfileLogic.extractUserData(user, authProvider);

    final (
      :joinDate,
      :endDate,
      :startDate,
      :endDateTime,
      :remainingDays,
      :displayStartDate,
      :displayEndDate,
      :hasValidInternshipDates,
    ) = ProfileLogic.parseUserDates(user);

    return Scaffold(
      // FIX: Gunakan background dari tema
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(title: 'Profil', showBackButton: false),
      // --- FIX: Gunakan Stack agar navigasi bar tetap di bawah ---
      body: Stack(
        children: [
          // 1. LAYER KONTEN
          SingleChildScrollView(
            // Padding bawah ditambah (100) agar tidak tertutup nav bar
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Column(
              children: [
                // 1. IDENTITY CARD (Header + Info Diri dalam satu card)
                IdentityCard(
                  user: user,
                  isDarkMode: isDarkMode,
                  displayInstansi: displayInstansi,
                ),
                const SizedBox(height: 24),

                // 2. DETAIL MAGANG (Mentor, Divisi, Status, Periode)
                if (isStudent) ...[
                  InternshipDetailCard(
                    isDarkMode: isDarkMode,
                    mentorName: mentorName,
                    divisi: displayDivisi,
                    isActive: user?.isActive ?? false,
                    // Data Tanggal
                    hasValidInternshipDates: hasValidInternshipDates,
                    startDate: startDate,
                    endDate: endDateTime,
                    remainingDays: remainingDays,
                    displayStartDate: displayStartDate,
                    displayEndDate: displayEndDate,
                  ),
                  const SizedBox(height: 24),
                ],

                // 3. PENGATURAN
                ProfileSection(
                  title: 'Pengaturan',
                  isDarkMode: isDarkMode,
                  children: [
                    ModernSettingItem(
                      icon: Icons.edit_rounded,
                      title: 'Edit Profil',
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        // FIX: Gunakan onSurfaceVariant (abu-abu)
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onTap: () async {
                        await Navigator.pushNamed(
                          context,
                          RouteNames.editProfile,
                        );
                        authProvider.refreshProfile();
                      },
                      isDarkMode: isDarkMode,
                    ),
                    ProfileDivider(isDarkMode: isDarkMode),
                    ModernSettingItem(
                      icon: Icons.dark_mode_rounded,
                      title: 'Mode Gelap',
                      trailing: Switch(
                        value: isDarkMode,
                        onChanged: (value) {
                          themeProvider.setThemeMode(
                            value ? ThemeMode.dark : ThemeMode.light,
                          );
                        },
                        // FIX: Gunakan primaryColor
                        activeColor: colorScheme.primary,
                      ),
                      isDarkMode: isDarkMode,
                    ),
                    ProfileDivider(isDarkMode: isDarkMode),
                    ModernSettingItem(
                      icon: Icons.lock_rounded,
                      title: 'Ganti Kata Sandi',
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        // FIX: Gunakan onSurfaceVariant
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          RouteNames.changePassword,
                        );
                      },
                      isDarkMode: isDarkMode,
                    ),
                    ProfileDivider(isDarkMode: isDarkMode),
                    ModernSettingItem(
                      icon: Icons.logout_rounded,
                      title: 'Keluar',
                      trailing: const SizedBox.shrink(),
                      onTap: () => _showLogoutDialog(context, authProvider),
                      isDarkMode: isDarkMode,
                      iconColor: colorScheme.error,
                      titleColor: colorScheme.error,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. LAYER NAVIGASI BAR
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: authProvider.isMentor
                ? MentorBottomNav(currentRoute: RouteNames.profile)
                : authProvider.isAdmin
                    ? const SizedBox.shrink()
                    : FloatingBottomNav(
                        currentRoute: RouteNames.profile,
                        onQRScanTap: () => _handleQRScan(context),
                      ),
          ),
        ],
      ),
    );
  }
}
