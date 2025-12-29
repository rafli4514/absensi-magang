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
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: 'Keluar',
        content: 'Apakah Anda yakin ingin keluar dari aplikasi?',
        primaryButtonText: 'Keluar',
        primaryButtonColor: AppThemes.errorColor,
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final isDarkMode = themeProvider.isDarkMode;
    final user = authProvider.user;

    // Logic Profile (Destructuring diperbaiki)
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
      appBar: CustomAppBar(title: 'Profil', showBackButton: false),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                UserProfileCard(
                  user: user,
                  isDarkMode: isDarkMode,
                  joinDate: joinDate,
                  endDate: endDate,
                ),
                const SizedBox(height: 24),

                // Hanya tampilkan detail magang jika user adalah STUDENT
                if (isStudent)
                  InternshipInfoCard(
                    isDarkMode: isDarkMode,
                    isStudent: isStudent,
                    displayInstansi: displayInstansi,
                    displayDivisi: displayDivisi,
                    idPesertaMagang: user?.idPesertaMagang,
                    mentorName: mentorName,
                    hasValidInternshipDates: hasValidInternshipDates,
                    startDate: startDate,
                    endDate: endDateTime,
                    remainingDays: remainingDays,
                    displayStartDate: displayStartDate,
                    displayEndDate: displayEndDate,
                  ),

                ProfileSection(
                  title: 'Pengaturan',
                  isDarkMode: isDarkMode,
                  children: [
                    ModernSettingItem(
                      icon: Icons.edit_rounded,
                      title: 'Edit Profil',
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: isDarkMode
                            ? AppThemes.darkTextSecondary
                            : theme.hintColor,
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
                        value: themeProvider.themeMode == ThemeMode.dark,
                        onChanged: (value) {
                          themeProvider.setThemeMode(
                            value ? ThemeMode.dark : ThemeMode.light,
                          );
                        },
                        activeColor: isDarkMode
                            ? AppThemes.darkAccentBlue
                            : AppThemes.primaryColor,
                      ),
                      isDarkMode: isDarkMode,
                    ),
                    ProfileDivider(isDarkMode: isDarkMode),
                    ModernSettingItem(
                      icon: Icons.logout_rounded,
                      title: 'Keluar',
                      trailing: const SizedBox.shrink(),
                      onTap: () => _showLogoutDialog(context, authProvider),
                      isDarkMode: isDarkMode,
                      iconColor: AppThemes.errorColor,
                      titleColor: AppThemes.errorColor,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                ProfileSection(
                  title: 'Keamanan Akun',
                  isDarkMode: isDarkMode,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            RouteNames.changePassword,
                          );
                        },
                        icon: const Icon(
                          Icons.lock_rounded,
                          color: AppThemes.infoColor,
                        ),
                        label: const Text(
                          'Ganti Kata Sandi',
                          style: TextStyle(color: AppThemes.infoColor),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppThemes.infoColor,
                          side: const BorderSide(color: AppThemes.infoColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),

          // Pilih Bottom Nav Sesuai Role
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
                        onQRScanTap: () =>
                            NavigationHelper.navigateWithoutAnimation(
                          context,
                          RouteNames.qrScan,
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
