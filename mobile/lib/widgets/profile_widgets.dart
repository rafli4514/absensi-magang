import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/user.dart';
import '../../../themes/app_themes.dart';

// --- ATOMIC WIDGETS (Tetap Sama) ---

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
      width: double.infinity,
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
  final Color? valueColor;

  const ProfileInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.isDarkMode,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0), // Sedikit dirapatkan
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isDarkMode
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
                    fontSize: 11,
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
                    fontSize: 14,
                    color: valueColor ??
                        (isDarkMode
                            ? AppThemes.darkTextPrimary
                            : theme.textTheme.bodyMedium?.color),
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
    final primaryColor =
        isDarkMode ? AppThemes.darkAccentBlue : AppThemes.primaryColor;
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
          color: titleColor ??
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

// --- NEW COMPOUND WIDGETS ---

// 1. IDENTITY CARD (GABUNGAN Header & Info Diri)
class IdentityCard extends StatelessWidget {
  final User? user;
  final bool isDarkMode;
  final String? displayInstansi; // Optional, untuk mahasiswa

  const IdentityCard({
    super.key,
    required this.user,
    required this.isDarkMode,
    this.displayInstansi,
  });

  static String getInitials(String name) {
    if (name.trim().isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return '${parts[0].substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatarColor =
        isDarkMode ? AppThemes.darkAccentBlue : AppThemes.primaryColor;

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
        children: [
          // BAGIAN ATAS: Identitas Utama (Foto, Nama, Role)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: avatarColor.withOpacity(0.3), width: 2),
                ),
                child: CircleAvatar(
                  radius: 35,
                  backgroundColor: avatarColor.withOpacity(0.15),
                  child: Text(
                    getInitials(user?.nama ?? user?.username ?? 'U'),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: avatarColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Nama & Role
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.nama ?? '-',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: isDarkMode
                            ? AppThemes.darkTextPrimary
                            : theme.textTheme.titleLarge?.color,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: avatarColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        user?.displayRole ?? 'Pengguna',
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

          // PEMBATAS (GARIS HORIZONTAL)
          const SizedBox(height: 20),
          Divider(
            color: isDarkMode
                ? AppThemes.darkOutline
                : Colors.grey.withOpacity(0.2),
            thickness: 1,
          ),
          const SizedBox(height: 16),

          // BAGIAN BAWAH: Informasi Diri (NIM, HP, Instansi)
          if (user?.idPesertaMagang != null &&
              user!.idPesertaMagang!.isNotEmpty) ...[
            ProfileInfoRow(
              icon: Icons.badge_rounded,
              label: "NIM / NISN / ID",
              value: user!.idPesertaMagang!,
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 8),
          ],

          ProfileInfoRow(
            icon: Icons.phone_rounded,
            label: "Nomor HP",
            value: user?.nomorHp ?? '-',
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 8),

          ProfileInfoRow(
            icon: Icons.school_rounded,
            label: "Asal Instansi / Kampus",
            value: displayInstansi ?? user?.instansi ?? '-',
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
  }
}

// 2. INTERNSHIP DETAIL CARD (Detail Magang + Status + Periode)
class InternshipDetailCard extends StatelessWidget {
  final bool isDarkMode;
  final String? mentorName;
  final String? divisi;
  final bool isActive;
  final bool hasValidInternshipDates;
  final DateTime? startDate;
  final DateTime? endDate;
  final int remainingDays;
  final String displayStartDate;
  final String displayEndDate;

  const InternshipDetailCard({
    super.key,
    required this.isDarkMode,
    this.mentorName,
    this.divisi,
    required this.isActive,
    required this.hasValidInternshipDates,
    this.startDate,
    this.endDate,
    required this.remainingDays,
    required this.displayStartDate,
    required this.displayEndDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ProfileSection(
      title: 'Detail Magang',
      isDarkMode: isDarkMode,
      children: [
        if (mentorName != null && mentorName!.isNotEmpty && mentorName != '-')
          ProfileInfoRow(
            icon: Icons.supervisor_account_rounded,
            label: "Pembimbing Lapangan",
            value: mentorName!,
            isDarkMode: isDarkMode,
          ),
        if (mentorName != null && mentorName!.isNotEmpty && mentorName != '-')
          ProfileDivider(isDarkMode: isDarkMode),

        ProfileInfoRow(
          icon: Icons.work_outline_rounded,
          label: "Divisi Penempatan",
          value: divisi ?? '-',
          isDarkMode: isDarkMode,
        ),
        ProfileDivider(isDarkMode: isDarkMode),

        ProfileInfoRow(
          icon: isActive ? Icons.verified_user_rounded : Icons.gpp_bad_rounded,
          label: "Status Akun",
          value: isActive ? 'Aktif' : 'Tidak Aktif',
          valueColor: isActive ? AppThemes.successColor : AppThemes.errorColor,
          isDarkMode: isDarkMode,
        ),

        const SizedBox(height: 20),

        // Periode Magang Section (Nested)
        Text(
          "Periode Magang",
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: isDarkMode ? AppThemes.darkTextSecondary : theme.hintColor,
          ),
        ),
        const SizedBox(height: 12),

        if (hasValidInternshipDates)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? AppThemes.darkBackground
                  : AppThemes.neutralLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkMode ? AppThemes.darkOutline : Colors.transparent,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                MiniStat(
                  label: "Mulai",
                  value: DateFormat('dd MMM yyyy').format(startDate!),
                  isDarkMode: isDarkMode,
                ),
                Container(
                    height: 30, width: 1, color: Colors.grey.withOpacity(0.3)),
                MiniStat(
                  label: "Selesai",
                  value: DateFormat('dd MMM yyyy').format(endDate!),
                  isDarkMode: isDarkMode,
                ),
                Container(
                    height: 30, width: 1, color: Colors.grey.withOpacity(0.3)),
                MiniStat(
                  label: "Sisa Hari",
                  value: "$remainingDays Hari",
                  isDarkMode: isDarkMode,
                  isHighlight: true,
                ),
              ],
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileInfoRow(
                  icon: Icons.date_range,
                  label: "Tanggal Mulai",
                  value: displayStartDate,
                  isDarkMode: isDarkMode,
                ),
                ProfileDivider(isDarkMode: isDarkMode),
                ProfileInfoRow(
                  icon: Icons.event_available,
                  label: "Tanggal Selesai",
                  value: displayEndDate,
                  isDarkMode: isDarkMode,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
