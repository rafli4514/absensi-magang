// lib/widgets/profile_widgets.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/user.dart';
import '../../../themes/app_themes.dart';

// --- PROFILE WIDGETS ---

class ProfileSection extends StatelessWidget {
  final String title;
  final bool isDarkMode;
  final List<Widget> children;

  const ProfileSection({
    super.key,
    required this.title,
    required this.isDarkMode,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
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
}

class ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDarkMode;

  const ProfileInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
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
}

class MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final bool isDarkMode;
  final bool isHighlight;

  const MiniStat({
    super.key,
    required this.label,
    required this.value,
    required this.isDarkMode,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isHighlight
                ? AppThemes.errorColor
                : (isDarkMode
                      ? AppThemes.darkAccentBlue
                      : AppThemes.primaryColor),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 10,
            color: isDarkMode ? AppThemes.darkTextSecondary : theme.hintColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class ModernSettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget trailing;
  final VoidCallback? onTap;
  final bool isDarkMode;
  final Color? iconColor;
  final Color? titleColor;

  const ModernSettingItem({
    super.key,
    required this.icon,
    required this.title,
    required this.trailing,
    this.onTap,
    required this.isDarkMode,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
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
}

class ProfileDivider extends StatelessWidget {
  final bool isDarkMode;

  const ProfileDivider({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: isDarkMode ? AppThemes.darkOutline : Colors.grey.withOpacity(0.1),
    );
  }
}

class UserProfileCard extends StatelessWidget {
  final User? user;
  final bool isDarkMode;
  final String? joinDate;
  final String? endDate;

  const UserProfileCard({
    super.key,
    required this.user,
    required this.isDarkMode,
    this.joinDate,
    this.endDate,
  });

  static String getInitials(String name) {
    if (name.trim().isEmpty) return 'U';

    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }

    return '${parts[0].substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatarColor = isDarkMode
        ? AppThemes.darkAccentBlue
        : AppThemes.primaryColor;

    return Container(
      padding: const EdgeInsets.all(24),
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
          // --- HEADER: PHOTO, NAME, USERNAME, ROLE ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Foto Profil
              Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: avatarColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: avatarColor.withOpacity(0.15),
                      child: Text(
                        getInitials(user?.nama ?? user?.username ?? 'U'),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: avatarColor,
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
              const SizedBox(width: 16),

              // Detail Nama & Username
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Nama Lengkap (Wajib Tampil)
                    Text(
                      user?.nama ?? '-',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: isDarkMode
                            ? AppThemes.darkTextPrimary
                            : theme.textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // 2. Username (Wajib Tampil dengan @)
                    Text(
                      '@${user?.username ?? '-'}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDarkMode
                            ? AppThemes.darkTextSecondary
                            : theme.hintColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 3. Role Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: avatarColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        user?.displayRole ?? 'User',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: avatarColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // --- INFORMASI KONTAK ---
          Text(
            'Informasi Kontak',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: isDarkMode
                  ? AppThemes.darkTextPrimary
                  : theme.textTheme.titleMedium?.color,
            ),
          ),
          const SizedBox(height: 12),

          // 4. Email
          ProfileInfoRow(
            icon: Icons.email_rounded,
            label: "Email",
            value: user?.email ?? '-',
            isDarkMode: isDarkMode,
          ),
          ProfileDivider(isDarkMode: isDarkMode),

          // 5. Nomor HP
          ProfileInfoRow(
            icon: Icons.phone_rounded,
            label: "Nomor HP",
            value: user?.nomorHp ?? '-',
            isDarkMode: isDarkMode,
          ),

          ProfileDivider(isDarkMode: isDarkMode),

          // 6. Status Akun
          ProfileInfoRow(
            icon: Icons.verified_user_rounded,
            label: "Status Akun",
            value: (user?.isActive == true) ? 'Aktif' : 'Tidak Aktif',
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
  }
}

class InternshipInfoCard extends StatelessWidget {
  final bool isDarkMode;
  final bool isStudent;
  final String displayInstansi;
  final String displayDivisi;
  final bool hasValidInternshipDates;
  final DateTime? startDate;
  final DateTime? endDate;
  final int remainingDays;
  final String displayStartDate;

  const InternshipInfoCard({
    super.key,
    required this.isDarkMode,
    required this.isStudent,
    required this.displayInstansi,
    required this.displayDivisi,
    required this.hasValidInternshipDates,
    this.startDate,
    this.endDate,
    required this.remainingDays,
    required this.displayStartDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Pastikan card ini hanya muncul untuk student
    if (!isStudent) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
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
          Row(
            children: [
              Icon(
                Icons.school_rounded,
                color: isDarkMode
                    ? AppThemes.darkAccentBlue
                    : AppThemes.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "Detail Magang",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? AppThemes.darkTextPrimary : null,
                ),
              ),
            ],
          ),
          const Divider(height: 24),

          // 7. Instansi / Asal Kampus
          ProfileInfoRow(
            icon: Icons.business_rounded,
            label: "Asal Instansi / Kampus",
            value: displayInstansi,
            isDarkMode: isDarkMode,
          ),

          // 8. Divisi Penempatan
          ProfileInfoRow(
            icon: Icons.work_outline_rounded,
            label: "Divisi Penempatan",
            value: displayDivisi,
            isDarkMode: isDarkMode,
          ),

          const SizedBox(height: 16),
          Text(
            "Periode Magang",
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDarkMode ? AppThemes.darkTextSecondary : theme.hintColor,
            ),
          ),
          const SizedBox(height: 12),

          // 9. Statistik Tanggal (Bergabung s/d Berakhir)
          if (hasValidInternshipDates)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppThemes.darkBackground
                    : AppThemes.neutralLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDarkMode
                      ? AppThemes.darkOutline
                      : Colors.transparent,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Tanggal Mulai
                  MiniStat(
                    label: "Mulai",
                    value: DateFormat('dd MMM yyyy').format(startDate!),
                    isDarkMode: isDarkMode,
                  ),
                  Container(
                    height: 30,
                    width: 1,
                    color: Colors.grey.withOpacity(0.3),
                  ),
                  // Tanggal Selesai
                  MiniStat(
                    label: "Selesai",
                    value: DateFormat('dd MMM yyyy').format(endDate!),
                    isDarkMode: isDarkMode,
                  ),
                  Container(
                    height: 30,
                    width: 1,
                    color: Colors.grey.withOpacity(0.3),
                  ),
                  // Sisa Hari
                  MiniStat(
                    label: "Sisa Hari",
                    value: "$remainingDays Hari",
                    isDarkMode: isDarkMode,
                    isHighlight: true,
                  ),
                ],
              ),
            )
          else if (displayStartDate != '-')
            // Fallback jika tanggal belum lengkap
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ProfileInfoRow(
                icon: Icons.date_range,
                label: "Tanggal Mulai",
                value: displayStartDate,
                isDarkMode: isDarkMode,
              ),
            ),
        ],
      ),
    );
  }
}
