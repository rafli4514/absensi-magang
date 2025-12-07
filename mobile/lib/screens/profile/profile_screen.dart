import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  // --- LOGIC HELPERS ---

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

  // --- UI WIDGET BUILDERS ---

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required bool isDarkMode,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  (isDarkMode
                          ? AppThemes.darkAccentBlue
                          : AppThemes.primaryColor)
                      .withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: isDarkMode
                  ? AppThemes.darkAccentBlue
                  : AppThemes.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDarkMode
                        ? AppThemes.darkTextSecondary
                        : theme.hintColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDarkMode
                        ? AppThemes.darkTextPrimary
                        : theme.textTheme.bodyMedium?.color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(
    BuildContext context,
    String label,
    String value,
    bool isDarkMode, {
    bool isHighlight = false,
  }) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isHighlight
                ? AppThemes.errorColor
                : (isDarkMode
                      ? AppThemes.darkAccentBlue
                      : AppThemes.primaryColor),
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 10,
            color: isDarkMode ? AppThemes.darkTextSecondary : theme.hintColor,
          ),
        ),
      ],
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

  Widget _buildModernSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget trailing,
    VoidCallback? onTap,
    required bool isDarkMode,
    Color? iconColor,
    Color? titleColor,
  }) {
    final theme = Theme.of(context);
    final primaryColor = isDarkMode
        ? AppThemes.darkAccentBlue
        : AppThemes.primaryColor;
    final leadingColor = iconColor ?? primaryColor;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: leadingColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: leadingColor, size: 20),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color:
              titleColor ??
              (isDarkMode
                  ? AppThemes.darkTextPrimary
                  : theme.textTheme.bodyMedium?.color),
        ),
      ),
      trailing: trailing,
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      visualDensity: const VisualDensity(vertical: -2),
    );
  }

  Widget _buildDividerItem(bool isDarkMode) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: isDarkMode ? AppThemes.darkOutline : Colors.grey.withOpacity(0.1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final isDarkMode = themeProvider.isDarkMode;
    final user = authProvider.user;

    // --- 1. PREPARE DATA (Extracting & Parsing) ---
    // Extract String fields
    final String displayDivisi = user?.divisi ?? '-';
    final String displayInstansi = user?.instansi ?? '-';
    final String displayPhone = user?.nomorHp ?? '-';

    // Extract Dates
    DateTime? startDate;
    DateTime? endDate;
    int remainingDays = 0;
    String displayStartDate = '-';
    String displayEndDate = '-';

    if (user?.tanggalMulai != null) {
      startDate = DateTime.tryParse(user!.tanggalMulai!);
      if (startDate != null) {
        displayStartDate = DateFormat('dd MMM yyyy').format(startDate);
      }
    }

    // Logic untuk tanggalSelesai (jika tidak null)
    if (user?.tanggalSelesai != null) {
      endDate = DateTime.tryParse(user!.tanggalSelesai!);
      if (endDate != null) {
        displayEndDate = DateFormat('dd MMM yyyy').format(endDate);

        // Hitung sisa hari hanya jika endDate valid
        final now = DateTime.now();
        // Reset jam/menit/detik untuk perhitungan hari yang akurat
        final dateNow = DateTime(now.year, now.month, now.day);
        final dateEnd = DateTime(endDate.year, endDate.month, endDate.day);

        remainingDays = dateEnd.difference(dateNow).inDays;
        // Pastikan tidak negatif untuk tampilan UI
        if (remainingDays < 0) remainingDays = 0;
      }
    }

    final bool hasValidInternshipDates = startDate != null && endDate != null;
    final bool isStudent = authProvider.isStudent;

    String? joinDate = '-';
    if (user?.createdAt != null) {
      joinDate = DateFormat('dd MMM yyyy').format(user!.createdAt!);
    }

    return Scaffold(
      appBar: CustomAppBar(title: 'Profile', showBackButton: false),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // --- PROFILE HEADER ---
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
                            ),
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.transparent,
                              child: Text(
                                (user?.displayName ?? 'U')
                                    .substring(0, 1)
                                    .toUpperCase(),
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? AppThemes.darkAccentBlue
                                      : AppThemes.primaryColor,
                                ),
                              ),
                            ),
                          ),
                          if (user?.isActive == true)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppThemes.successColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.displayName ?? 'User',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDarkMode
                              ? AppThemes.darkTextPrimary
                              : theme.textTheme.titleLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (isDarkMode
                                      ? AppThemes.darkAccentBlue
                                      : AppThemes.primaryColor)
                                  .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user?.role.toUpperCase() ?? 'USER',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? AppThemes.darkAccentBlue
                                : AppThemes.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ID: ${user?.id ?? '-'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDarkMode
                              ? AppThemes.darkTextSecondary
                              : theme.hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                _buildSection(
                  context,
                  title: 'Informasi Pribadi',
                  isDarkMode: isDarkMode,
                  children: [
                    _buildInfoRow(
                      context,
                      icon: Icons.email_rounded,
                      label: "Email",
                      value: user?.email ?? '-',
                      isDarkMode: isDarkMode,
                    ),
                    _buildDividerItem(isDarkMode),
                    // [NEW] Menampilkan Nomor HP
                    _buildInfoRow(
                      context,
                      icon: Icons.phone_rounded,
                      label: "Nomor HP",
                      value: displayPhone,
                      isDarkMode: isDarkMode,
                    ),
                    _buildDividerItem(isDarkMode),
                    _buildInfoRow(
                      context,
                      icon: Icons.calendar_today_rounded,
                      label: "Bergabung Sejak",
                      value: joinDate,
                      isDarkMode: isDarkMode,
                    ),
                    _buildDividerItem(isDarkMode),
                    _buildInfoRow(
                      context,
                      icon: Icons.verified_user_rounded,
                      label: "Status Akun",
                      value: (user?.isActive == true) ? 'Aktif' : 'Tidak Aktif',
                      isDarkMode: isDarkMode,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // --- INTERNSHIP INFO (Termasuk Instansi, Divisi, Tanggal) ---
                if (isStudent)
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(20),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Informasi Magang",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Divider(height: 24),
                        // [NEW] Instansi
                        _buildInfoRow(
                          context,
                          icon: Icons.business_rounded,
                          label: "Instansi / Kampus",
                          value: displayInstansi,
                          isDarkMode: isDarkMode,
                        ),
                        // [NEW] Divisi
                        _buildInfoRow(
                          context,
                          icon: Icons.work_outline_rounded,
                          label: "Divisi Penempatan",
                          value: displayDivisi,
                          isDarkMode: isDarkMode,
                        ),

                        // [NEW] Statistik Tanggal Magang
                        if (hasValidInternshipDates)
                          Container(
                            margin: const EdgeInsets.only(top: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? AppThemes.darkBackground
                                  : AppThemes.neutralLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildMiniStat(
                                  context,
                                  "Mulai",
                                  DateFormat('dd MMM').format(startDate!),
                                  isDarkMode,
                                ),
                                Container(
                                  height: 24,
                                  width: 1,
                                  color: Colors.grey.withOpacity(0.3),
                                ),
                                _buildMiniStat(
                                  context,
                                  "Selesai",
                                  DateFormat('dd MMM').format(endDate!),
                                  isDarkMode,
                                ),
                                Container(
                                  height: 24,
                                  width: 1,
                                  color: Colors.grey.withOpacity(0.3),
                                ),
                                _buildMiniStat(
                                  context,
                                  "Sisa Hari",
                                  "$remainingDays",
                                  isDarkMode,
                                  isHighlight: true,
                                ),
                              ],
                            ),
                          )
                        else if (displayStartDate != '-')
                          // Fallback jika hanya ada tanggal mulai tapi belum ada tanggal selesai
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: _buildInfoRow(
                              context,
                              icon: Icons.date_range,
                              label: "Tanggal Mulai",
                              value: displayStartDate,
                              isDarkMode: isDarkMode,
                            ),
                          ),
                      ],
                    ),
                  ),

                // --- SETTINGS ---
                _buildSection(
                  context,
                  title: 'Settings',
                  isDarkMode: isDarkMode,
                  children: [
                    _buildModernSettingItem(
                      context,
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
                    _buildDividerItem(isDarkMode),
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
                      ),
                      isDarkMode: isDarkMode,
                    ),
                    _buildDividerItem(isDarkMode),
                    _buildModernSettingItem(
                      context,
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
                _buildSection(
                  context,
                  title: 'Account Actions',
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
