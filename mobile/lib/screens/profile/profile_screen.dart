import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../navigation/route_names.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../themes/app_themes.dart';
import '../../utils/navigation_helper.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/floating_bottom_nav.dart';

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

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: 'About',
        content:
            'Employee App v1.0.0\n\nManage your attendance and activities efficiently.',
        primaryButtonText: 'OK',
        onPrimaryButtonPressed: () => Navigator.pop(context),
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

    return Scaffold(
      appBar: CustomAppBar(title: 'Profile', showBackButton: false),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Profile Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? AppThemes.darkSurface
                        : AppThemes.surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDarkMode
                          ? AppThemes.darkOutline
                          : Colors.grey.withOpacity(0.15),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(
                          isDarkMode ? 0.2 : 0.08,
                        ),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    (isDarkMode
                                            ? AppThemes.darkAccentBlue
                                            : AppThemes.primaryColor)
                                        .withOpacity(0.3),
                                width: 3,
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  isDarkMode
                                      ? AppThemes.darkAccentBlue
                                      : AppThemes.primaryColor,
                                  isDarkMode
                                      ? AppThemes.primaryDark
                                      : AppThemes.primaryDark,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      (isDarkMode
                                              ? AppThemes.darkAccentBlue
                                              : AppThemes.primaryColor)
                                          .withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.transparent,
                              child: Text(
                                (user?.name ?? user?.displayName ?? 'U').substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppThemes.successColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        user?.name ?? 'User Name',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDarkMode
                              ? AppThemes.darkTextPrimary
                              : theme.textTheme.titleLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        user?.position ?? 'Position',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDarkMode
                              ? AppThemes.darkAccentBlue
                              : AppThemes.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.department ?? 'Department',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDarkMode
                              ? AppThemes.darkTextSecondary
                              : theme.hintColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              (isDarkMode
                                      ? AppThemes.darkAccentBlue
                                      : AppThemes.primaryColor)
                                  .withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                (isDarkMode
                                        ? AppThemes.darkAccentBlue
                                        : AppThemes.primaryColor)
                                    .withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildModernStatItem(
                              context,
                              'Present',
                              '22',
                              isDarkMode,
                            ),
                            _buildDivider(isDarkMode),
                            _buildModernStatItem(
                              context,
                              'Late',
                              '2',
                              isDarkMode,
                            ),
                            _buildDivider(isDarkMode),
                            _buildModernStatItem(
                              context,
                              'Absent',
                              '0',
                              isDarkMode,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Settings Section
                _buildSection(
                  context,
                  title: 'Settings',
                  isDarkMode: isDarkMode,
                  children: [
                    _buildModernSettingItem(
                      context,
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
                        activeTrackColor:
                            (isDarkMode
                                    ? AppThemes.darkAccentBlue
                                    : AppThemes.primaryColor)
                                .withOpacity(0.3),
                      ),
                      isDarkMode: isDarkMode,
                    ),
                    _buildDividerItem(isDarkMode),
                    _buildModernSettingItem(
                      context,
                      icon: Icons.notifications_active_rounded,
                      title: 'Notifications',
                      trailing: Switch(
                        value: true,
                        onChanged: (value) {
                          // Handle notification toggle
                        },
                        activeColor: isDarkMode
                            ? AppThemes.darkAccentBlue
                            : AppThemes.primaryColor,
                        activeTrackColor:
                            (isDarkMode
                                    ? AppThemes.darkAccentBlue
                                    : AppThemes.primaryColor)
                                .withOpacity(0.3),
                      ),
                      isDarkMode: isDarkMode,
                    ),
                    _buildDividerItem(isDarkMode),
                    _buildModernSettingItem(
                      context,
                      icon: Icons.language_rounded,
                      title: 'Language',
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: isDarkMode
                            ? AppThemes.darkTextSecondary
                            : theme.hintColor,
                      ),
                      onTap: () {
                        // Handle language selection
                      },
                      isDarkMode: isDarkMode,
                    ),
                    _buildDividerItem(isDarkMode),
                    _buildModernSettingItem(
                      context,
                      icon: Icons.help_center_rounded,
                      title: 'Help & Support',
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: isDarkMode
                            ? AppThemes.darkTextSecondary
                            : theme.hintColor,
                      ),
                      onTap: () {
                        // Handle help
                      },
                      isDarkMode: isDarkMode,
                    ),
                    _buildDividerItem(isDarkMode),
                    _buildModernSettingItem(
                      context,
                      icon: Icons.info_rounded,
                      title: 'About',
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: isDarkMode
                            ? AppThemes.darkTextSecondary
                            : theme.hintColor,
                      ),
                      onTap: () {
                        _showAboutDialog(context);
                      },
                      isDarkMode: isDarkMode,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Actions Section
                _buildSection(
                  context,
                  title: 'Account Actions',
                  isDarkMode: isDarkMode,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: _buildModernActionButton(
                        icon: Icons.edit_rounded,
                        label: 'Edit Profile',
                        color: isDarkMode
                            ? AppThemes.darkAccentBlue
                            : AppThemes.primaryColor,
                        onPressed: () {
                          Navigator.pushNamed(context, RouteNames.editProfile);
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: _buildModernActionButton(
                        icon: Icons.lock_rounded,
                        label: 'Change Password',
                        color: AppThemes.infoColor,
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            RouteNames.changePassword,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: _buildModernActionButton(
                        icon: Icons.logout_rounded,
                        label: 'Logout',
                        color: AppThemes.errorColor,
                        isFilled: true,
                        onPressed: () {
                          _showLogoutDialog(context, authProvider);
                        },
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
              onQRScanTap: () {
                NavigationHelper.navigateWithoutAnimation(
                  context,
                  RouteNames.qrScan,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required bool isDarkMode,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? AppThemes.darkSurface : AppThemes.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode
              ? AppThemes.darkOutline
              : Colors.grey.withOpacity(0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: isDarkMode
                  ? AppThemes.darkTextPrimary
                  : theme.textTheme.titleMedium?.color,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildModernStatItem(
    BuildContext context,
    String title,
    String value,
    bool isDarkMode,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: isDarkMode
                ? AppThemes.darkAccentBlue
                : AppThemes.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDarkMode ? AppThemes.darkTextSecondary : theme.hintColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(bool isDarkMode) {
    return Container(
      width: 1,
      height: 30,
      color: isDarkMode ? AppThemes.darkOutline : Colors.grey.withOpacity(0.2),
    );
  }

  Widget _buildDividerItem(bool isDarkMode) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: isDarkMode ? AppThemes.darkOutline : Colors.grey.withOpacity(0.1),
    );
  }

  Widget _buildModernSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget trailing,
    VoidCallback? onTap,
    required bool isDarkMode,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color:
              (isDarkMode ? AppThemes.darkAccentBlue : AppThemes.primaryColor)
                  .withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isDarkMode ? AppThemes.darkAccentBlue : AppThemes.primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: isDarkMode
              ? AppThemes.darkTextPrimary
              : theme.textTheme.bodyMedium?.color,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      visualDensity: const VisualDensity(vertical: -2),
    );
  }

  Widget _buildModernActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    bool isFilled = false,
  }) {
    return isFilled
        ? ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, color: Colors.white),
            label: Text(label, style: const TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 2,
            ),
          )
        : OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, color: color),
            label: Text(label, style: TextStyle(color: color)),
            style: OutlinedButton.styleFrom(
              foregroundColor: color,
              side: BorderSide(color: color),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          );
  }
}
