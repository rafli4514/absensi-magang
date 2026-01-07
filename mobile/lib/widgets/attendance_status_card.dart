import 'package:flutter/material.dart';

import '../themes/app_themes.dart';
import 'modern_status_card.dart';

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
    if (isClockedOut) return 'Selesai';
    if (canClockOut) return 'Tersedia';
    return 'Belum Tersedia';
  }

  bool _isClockOutAvailable() {
    final now = DateTime.now();
    return now.hour >= 17;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final canClockOut = _isClockOutAvailable();
    final clockOutStatus = _getClockOutStatus(isClockedOut, canClockOut);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ModernStatusCard(
                  title: 'Jam Masuk',
                  time: clockInTime,
                  icon: Icons.login_rounded,
                  status: isClockedIn ? 'Valid' : 'Belum Absen',
                  isCompleted: isClockedIn,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ModernStatusCard(
                  title: 'Jam Pulang',
                  time: clockOutTime ?? '--:--',
                  icon: Icons.logout_rounded,
                  status: clockOutStatus,
                  isCompleted: isClockedOut,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress Bar
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: isClockedIn ? 1 : 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppThemes.successColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(3),
                        bottomLeft: Radius.circular(3),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: isClockedIn && !isClockedOut ? 1 : 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppThemes.primaryColor,
                    ),
                  ),
                ),
                Expanded(
                  flex: !isClockedIn ? 1 : (isClockedOut ? 0 : 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.outline.withOpacity(0.2),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(3),
                        bottomRight: Radius.circular(3),
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
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                'Jam Kerja: 08:00 - 17:00',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getProgressText(bool isClockedIn, bool isClockedOut) {
    if (!isClockedIn) return 'Belum Absen Masuk';
    if (isClockedIn && !isClockedOut) return 'Sedang Bekerja...';
    return 'Pekerjaan Selesai';
  }
}
