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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isOnLeave = leaveStatus != null && leaveStatus!.isNotEmpty;
    final isSakit = leaveStatus?.toUpperCase() == 'SAKIT';

    final statusColor = isSakit ? AppThemes.infoColor : AppThemes.warningColor;
    final statusIcon = isSakit
        ? Icons.medical_services_outlined
        : Icons.assignment_ind_outlined;

    // Judul Status
    final statusTitle =
        isSakit ? 'Izin Sakit Disetujui' : 'Permohonan Izin Disetujui';

    // Pesan Ucapan
    final statusMessage = isSakit
        ? 'Semoga lekas sembuh! Istirahat yang cukup agar bisa kembali beraktivitas.'
        : 'Semoga urusan Anda hari ini berjalan lancar. Hati-hati di jalan!';

    final showClockIn = !isClockedIn && !isOnLeave;
    final showClockOut = isClockedIn && !isClockedOut && !isOnLeave;

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
            'Aksi Cepat',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color:
                  isDark ? AppThemes.darkTextPrimary : AppThemes.onSurfaceColor,
            ),
          ),
          const SizedBox(height: 16),

          // --- TAMPILAN STATUS IZIN / SAKIT ---
          if (isOnLeave)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                // HAPUS background color agar tidak abu-abu/keruh
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                // Tetap gunakan border agar status terlihat jelas
                border: Border.all(color: statusColor.withOpacity(0.5)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon tanpa background circle putih agar lebih clean
                  Icon(statusIcon, color: statusColor, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          statusTitle,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          statusMessage,
                          style: TextStyle(
                            color: isDark ? Colors.grey[300] : Colors.black87,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )

          // --- TAMPILAN TOMBOL ABSEN NORMAL ---
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
                      onPressed: canClockOut ? onClockOut : null,
                      icon: Icon(canClockOut
                          ? Icons.logout_rounded
                          : Icons.lock_clock),
                      label: Text(canClockOut
                          ? 'Absen Pulang'
                          : 'Plg Jam $workEndTime'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            canClockOut ? AppThemes.warningColor : Colors.grey,
                        disabledBackgroundColor: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade600,
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

          if (!isClockedIn && !isOnLeave) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onRequestLeave,
                icon: const Icon(Icons.assignment_late_outlined, size: 18),
                label: const Text('Pengajuan Izin / Sakit'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark
                      ? AppThemes.darkTextSecondary
                      : AppThemes.hintColor,
                  side: BorderSide(
                    color:
                        isDark ? AppThemes.darkOutline : Colors.grey.shade300,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
