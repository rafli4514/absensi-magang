import 'package:flutter/material.dart';

import '../themes/app_themes.dart';

class AttendanceCard extends StatelessWidget {
  final VoidCallback onClockIn;
  final VoidCallback onClockOut;
  final VoidCallback onRequestLeave;
  final bool isClockedIn;
  final bool isClockedOut;

  // Parameter Baru untuk Validasi Jam Pulang
  final bool canClockOut;
  final String workEndTime;

  const AttendanceCard({
    super.key,
    required this.onClockIn,
    required this.onClockOut,
    required this.onRequestLeave,
    required this.isClockedIn,
    required this.isClockedOut,
    this.canClockOut =
        true, // Default true agar tidak nge-bug jika data belum load
    this.workEndTime = "17:00",
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Logic tampilan tombol
    final showClockIn = !isClockedIn;
    // Tampilkan tombol pulang HANYA jika sudah absen masuk DAN belum absen pulang
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
            'Aksi Cepat',
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
              // --- TOMBOL ABSEN MASUK ---
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

              // --- TOMBOL ABSEN PULANG (DENGAN VALIDASI) ---
              if (showClockOut)
                Expanded(
                  child: ElevatedButton.icon(
                    // Jika canClockOut false, onPressed jadi null (tombol disable)
                    onPressed: canClockOut ? onClockOut : null,
                    icon: Icon(
                        canClockOut ? Icons.logout_rounded : Icons.lock_clock),
                    // Ubah teks jika belum jamnya
                    label: Text(
                        canClockOut ? 'Absen Pulang' : 'Plg Jam $workEndTime'),
                    style: ElevatedButton.styleFrom(
                      // Warna berubah jadi abu-abu jika disable
                      backgroundColor:
                          canClockOut ? AppThemes.warningColor : Colors.grey,
                      // Styling untuk state disabled
                      disabledBackgroundColor:
                          isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                      disabledForegroundColor: Colors.grey.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),

              // --- STATUS JIKA SUDAH SELESAI SEMUA ---
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

          // --- TOMBOL PENGAJUAN IZIN (Hanya muncul jika belum absen masuk) ---
          if (!isClockedIn) ...[
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
