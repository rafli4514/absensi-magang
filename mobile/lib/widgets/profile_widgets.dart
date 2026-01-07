import 'package:flutter/material.dart';

import '../../../models/user.dart';
import '../../../themes/app_themes.dart';

class ProfileSection extends StatelessWidget {
  final String title;
  final bool isDarkMode; // Keep for interface compatibility, unused in logic
  final List<Widget> children;

  const ProfileSection({
    super.key,
    required this.title,
    required this.isDarkMode,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
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
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppThemes.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppThemes.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                      fontSize: 11, color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: valueColor ?? colorScheme.onSurface,
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
    return Divider(
        color: Theme.of(context).colorScheme.outline.withOpacity(0.2));
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
    final colorScheme = Theme.of(context).colorScheme;
    final leadingColor = iconColor ?? AppThemes.primaryColor;

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
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: titleColor ?? colorScheme.onSurface,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}

class IdentityCard extends StatelessWidget {
  final User? user;
  final bool isDarkMode;
  final String? displayInstansi;

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
    final colorScheme = Theme.of(context).colorScheme;
    final avatarColor = AppThemes.primaryColor;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
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
                        color: avatarColor),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.nama ?? '-',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: colorScheme.onSurface),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${user?.username ?? '-'}',
                      style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500),
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
                            color: avatarColor),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: colorScheme.outline.withOpacity(0.2)),
          const SizedBox(height: 16),
          if (user?.idPesertaMagang != null &&
              user!.idPesertaMagang!.isNotEmpty)
            ProfileInfoRow(
              icon: Icons.badge_rounded,
              label: "NIM / NISN / ID",
              value: user!.idPesertaMagang!,
              isDarkMode: isDarkMode,
            ),
          const SizedBox(height: 8),
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
    return ProfileSection(
      title: 'Detail Magang',
      isDarkMode: isDarkMode,
      children: [
        if (mentorName != null && mentorName!.isNotEmpty && mentorName != '-')
          ProfileInfoRow(
              icon: Icons.supervisor_account_rounded,
              label: "Pembimbing Lapangan",
              value: mentorName!,
              isDarkMode: isDarkMode),
        ProfileDivider(isDarkMode: isDarkMode),
        ProfileInfoRow(
            icon: Icons.work_outline_rounded,
            label: "Divisi Penempatan",
            value: divisi ?? '-',
            isDarkMode: isDarkMode),
        ProfileDivider(isDarkMode: isDarkMode),
        ProfileInfoRow(
          icon: isActive ? Icons.verified_user_rounded : Icons.gpp_bad_rounded,
          label: "Status Akun",
          value: isActive ? 'Aktif' : 'Tidak Aktif',
          valueColor: isActive ? AppThemes.successColor : AppThemes.errorColor,
          isDarkMode: isDarkMode,
        ),
      ],
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
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isHighlight ? AppThemes.errorColor : AppThemes.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
