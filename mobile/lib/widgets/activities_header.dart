import 'package:flutter/material.dart';

import '../../../themes/app_themes.dart';

class ActivitiesHeader extends StatelessWidget {
  final VoidCallback onAddActivity;
  final VoidCallback onAddLogbook;

  const ActivitiesHeader({
    super.key,
    required this.onAddActivity,
    required this.onAddLogbook,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Menggunakan Column untuk menumpuk Teks dan Tombol secara vertikal
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bagian Teks Judul
        Text(
          'Ringkasan Aktivitas',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color:
                isDark ? AppThemes.darkTextPrimary : AppThemes.onSurfaceColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Pantau progres harianmu',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppThemes.darkTextSecondary : AppThemes.hintColor,
          ),
        ),

        const SizedBox(height: 20), // Memberi jarak antara teks dan tombol

        // Bagian Tombol (50:50)
        Row(
          children: [
            Expanded(
              child: _HeaderActionButton(
                icon: Icons.add_task,
                label: 'Aktivitas',
                onTap: onAddActivity,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12), // Jarak antar tombol
            Expanded(
              child: _HeaderActionButton(
                icon: Icons.book_outlined,
                label: 'Log Book',
                onTap: onAddLogbook,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;

  const _HeaderActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        // Padding vertikal diperbesar agar tombol lebih nyaman ditekan
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color:
              isDark ? AppThemes.darkSurfaceElevated : AppThemes.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppThemes.darkOutline : Colors.grey.shade200,
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        // Menggunakan Row agar Icon dan Teks sejajar (Horizontal)
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: AppThemes.primaryColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14, // Ukuran font disesuaikan agar pas
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppThemes.darkTextSecondary
                    : AppThemes.onSurfaceColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
