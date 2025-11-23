import 'package:flutter/material.dart';

import '../themes/app_themes.dart';
import 'modern_stautus_card.dart'; // Import yang benar

class AttendanceStatusCard extends StatelessWidget {
  final String clockInTime;
  final String? clockOutTime;
  final bool isClockedIn;
  final bool isClockedOut;

  const AttendanceStatusCard({
    super.key,
    this.clockInTime = '--:--',
    this.clockOutTime,
    this.isClockedIn = false,
    this.isClockedOut = false,
  });

  String _getClockOutStatus(bool isClockedOut, bool canClockOut) {
    if (isClockedOut) {
      return 'Completed';
    } else if (canClockOut) {
      return 'Available';
    } else {
      return 'Not Available';
    }
  }

  bool _isClockOutAvailable() {
    final now = DateTime.now();
    return now.hour >= 17; // Available setelah jam 17:00
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final canClockOut = _isClockOutAvailable();
    final clockOutStatus = _getClockOutStatus(isClockedOut, canClockOut);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppThemes.darkSurface : AppThemes.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: isDark
            ? Border.all(color: AppThemes.darkOutline, width: 0.5)
            : Border.all(
                color: AppThemes.backgroundColor.withOpacity(0.5),
                width: 1,
              ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Check In Card
              Expanded(
                child: ModernStatusCard(
                  title: 'Clock In',
                  time: clockInTime,
                  icon: Icons.login_rounded,
                  status: isClockedIn ? 'Completed' : 'Not Clocked In',
                  isCompleted: isClockedIn,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 16),
              // Check Out Card
              Expanded(
                child: ModernStatusCard(
                  title: 'Clock Out',
                  time: clockOutTime ?? '--:--',
                  icon: Icons.logout_rounded,
                  status: clockOutStatus,
                  isCompleted: isClockedOut,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress Bar - Dinamis berdasarkan status
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? AppThemes.darkOutline : AppThemes.backgroundColor,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Row(
              children: [
                // Bagian yang sudah selesai (hijau)
                Expanded(
                  flex: isClockedIn ? 1 : 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppThemes.successColor, AppThemes.successDark],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(3),
                        bottomLeft: Radius.circular(3),
                      ),
                    ),
                  ),
                ),
                // Bagian yang sedang berjalan (biru)
                Expanded(
                  flex: isClockedIn && !isClockedOut ? 1 : 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppThemes.primaryColor, AppThemes.primaryDark],
                      ),
                    ),
                  ),
                ),
                // Bagian yang belum (abu-abu)
                Expanded(
                  flex: !isClockedIn ? 1 : (isClockedOut ? 0 : 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppThemes.darkOutlineVariant
                          : AppThemes.neutralLight,
                      borderRadius: BorderRadius.only(
                        topRight: const Radius.circular(3),
                        bottomRight: const Radius.circular(3),
                        topLeft: !isClockedIn
                            ? const Radius.circular(3)
                            : Radius.zero,
                        bottomLeft: !isClockedIn
                            ? const Radius.circular(3)
                            : Radius.zero,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getProgressText(isClockedIn, isClockedOut),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppThemes.darkTextSecondary
                      : AppThemes.hintColor,
                ),
              ),
              Text(
                'Office Hours: 08:00 - 17:00',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppThemes.darkTextSecondary
                      : AppThemes.hintColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getProgressText(bool isClockedIn, bool isClockedOut) {
    if (!isClockedIn) {
      return 'Not Clocked In';
    } else if (isClockedIn && !isClockedOut) {
      return 'Working...';
    } else {
      return 'Workday Complete';
    }
  }
}
