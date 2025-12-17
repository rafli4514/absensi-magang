import 'package:flutter/material.dart';

import '../themes/app_themes.dart';

class AttendanceCard extends StatelessWidget {
  final VoidCallback onClockIn;
  final VoidCallback onClockOut;
  final bool isClockedIn;
  final bool isClockedOut;

  const AttendanceCard({
    super.key,
    required this.onClockIn,
    required this.onClockOut,
    required this.isClockedIn,
    required this.isClockedOut,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Logic tampilan tombol
    // - Clock In: hanya tampil jika BELUM pernah clock in hari ini
    // - Clock Out: tampil jika sudah clock in dan BELUM clock out hari ini
    // Siklus baru hari berikutnya akan di-handle oleh reset di AttendanceProvider
    final showClockIn = !isClockedIn;
    final showClockOut = isClockedIn && !isClockedOut;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppThemes.darkSurface : AppThemes.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppThemes.darkOutline : Colors.grey.withOpacity(0.1),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Action',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color:
                  isDark ? AppThemes.darkTextPrimary : AppThemes.onSurfaceColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (showClockIn)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onClockIn,
                    icon: const Icon(Icons.login_rounded),
                    label: const Text('Clock In'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? AppThemes.darkAccentBlue
                          : AppThemes.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              if (showClockOut)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onClockOut,
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Clock Out'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppThemes.warningColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              if (!showClockIn && !showClockOut)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppThemes.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppThemes.successColor),
                    ),
                    child: Center(
                      child: Text(
                        'Absensi Hari Ini Selesai',
                        style: TextStyle(
                          color: AppThemes.successColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}