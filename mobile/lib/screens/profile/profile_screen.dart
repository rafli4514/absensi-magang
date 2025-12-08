// screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:myinternplus/screens/profile/profile_logic.dart';
import 'package:provider/provider.dart';

import '../../navigation/route_names.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../themes/app_themes.dart';
import '../../utils/navigation_helper.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/floating_bottom_nav.dart';
import '../../widgets/profile_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: 'Logout',
        content: 'Are you sure you want to logout?',
        primaryButtonText: 'Logout',
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
        secondaryButtonText: 'Cancel',
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

    // --- EXTRACT DATA USING LOGIC CLASSES ---
    final (:displayDivisi, :displayInstansi, :isStudent) =
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
    ) = ProfileLogic.parseUserDates(
      user,
    );

    return Scaffold(
      appBar: CustomAppBar(title: 'Profile', showBackButton: false),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // --- USER PROFILE CARD (GABUNGAN) ---
                UserProfileCard(
                  user: user,
                  isDarkMode: isDarkMode,
                  joinDate: joinDate,
                  endDate: endDate,
                ),
                const SizedBox(height: 24),

                // --- INTERNSHIP INFO ---
                InternshipInfoCard(
                  isDarkMode: isDarkMode,
                  isStudent: isStudent,
                  displayInstansi: displayInstansi,
                  displayDivisi: displayDivisi,
                  hasValidInternshipDates: hasValidInternshipDates,
                  startDate: startDate,
                  endDate: endDateTime,
                  remainingDays: remainingDays,
                  displayStartDate: displayStartDate,
                ),

                // --- SETTINGS ---
                ProfileSection(
                  title: 'Pengaturan',
                  isDarkMode: isDarkMode,
                  children: [
                    ModernSettingItem(
                      icon: Icons.edit_rounded,
                      title: 'Edit Profile',
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
                      title: 'Dark Mode',
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
                      title: 'Logout',
                      trailing: const SizedBox.shrink(),
                      onTap: () => _showLogoutDialog(context, authProvider),
                      isDarkMode: isDarkMode,
                      iconColor: AppThemes.errorColor,
                      titleColor: AppThemes.errorColor,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // --- ACTIONS ---
                ProfileSection(
                  title: 'Tindakan Akun',
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
                          'Change Password',
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
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingBottomNav(
              currentRoute: RouteNames.profile,
              onQRScanTap: () => NavigationHelper.navigateWithoutAnimation(
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
