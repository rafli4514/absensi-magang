import 'package:flutter/material.dart';

import '../themes/app_themes.dart';

class AttendanceCard extends StatelessWidget {
  final VoidCallback onClockIn;
  final VoidCallback onClockOut;
  final VoidCallback onRequestLeave;
  final bool isClockedIn;
  final bool isClockedOut;
  final bool canClockOut;
  final String workEndTime;
  final String? leaveStatus;

  const AttendanceCard({
    super.key,
    required this.onClockIn,
    required this.onClockOut,
    required this.onRequestLeave,
    required this.isClockedIn,
    required this.isClockedOut,
    this.canClockOut = true,
    this.workEndTime = "17:00",
    this.leaveStatus,
  });

  @override
  Widget build(BuildContext context) {
    // SYSTEM HOOKS (Otomatis deteksi mode)
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    final isOnLeave = leaveStatus != null && leaveStatus!.isNotEmpty;
    final isSakit = leaveStatus?.toUpperCase() == 'SAKIT';

    final statusColor = isSakit ? AppThemes.infoColor : AppThemes.warningColor;
    final statusIcon = isSakit
        ? Icons.medical_services_outlined
        : Icons.assignment_ind_outlined;
    final statusTitle =
        isSakit ? 'Izin Sakit Disetujui' : 'Permohonan Izin Disetujui';
    final statusMessage = isSakit
        ? 'Semoga lekas sembuh! Istirahat yang cukup.'
        : 'Hati-hati di jalan dan semoga urusan lancar!';

    final showClockIn = !isClockedIn && !isOnLeave;
    final showClockOut = isClockedIn && !isClockedOut && !isOnLeave;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // BACKGROUND: Putih di Light, Abu Gelap di Dark
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        // BORDER: Abu tipis di Light, Abu lebih gelap di Dark
        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
        // SHADOW: Hanya muncul di Light Mode
        boxShadow: isLight
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aksi Cepat',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface, // Teks judul
            ),
          ),
          const SizedBox(height: 16),

          // --- STATUS CUTI/SAKIT ---
          if (isOnLeave)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: statusColor
                    .withOpacity(0.1), // Transparan sesuai warna status
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(statusTitle,
                            style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(statusMessage,
                            style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            )

          // --- TOMBOL ABSEN ---
          else
            Row(
              children: [
                if (showClockIn)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onClockIn,
                      icon: const Icon(Icons.login_rounded),
                      label: const Text('Absen Masuk'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                if (showClockOut)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: canClockOut ? onClockOut : null,
                      icon: Icon(canClockOut
                          ? Icons.logout_rounded
                          : Icons.lock_clock),
                      label: Text(canClockOut
                          ? 'Absen Pulang'
                          : 'Plg Jam $workEndTime'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canClockOut
                            ? AppThemes.warningColor
                            : colorScheme.surfaceContainerHigh,
                        foregroundColor: canClockOut
                            ? Colors.white
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                if (!showClockIn && !showClockOut)
                  Expanded(child: _buildDoneState(colorScheme)),
              ],
            ),

          if (!isClockedIn && !isOnLeave) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onRequestLeave,
                icon: const Icon(Icons.assignment_late_outlined, size: 18),
                label: const Text('Pengajuan Izin / Sakit'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.onSurfaceVariant,
                  side: BorderSide(color: colorScheme.outline),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDoneState(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppThemes.successColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppThemes.successColor),
      ),
      child: const Center(
        child: Text(
          'Absensi Hari Ini Selesai',
          style: TextStyle(
            color: AppThemes.successColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
