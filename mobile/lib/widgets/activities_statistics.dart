import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/attendance.dart';
import '../../models/logbook.dart';
import '../../themes/app_themes.dart';

class ActivitiesStatistics extends StatelessWidget {
  final bool isMobile;
  final List<LogBook> logbooks;
  final List<Attendance> attendanceList;
  final DateTime currentWeekStart;
  final DateTime currentWeekEnd;

  const ActivitiesStatistics({
    super.key,
    required this.isMobile,
    required this.logbooks,
    required this.attendanceList,
    required this.currentWeekStart,
    required this.currentWeekEnd,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // CHART 1: PIE CHART KOMPOSISI MINGGUAN (Tetap, karena request line chart yang diubah)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Statistik Minggu Ini',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${DateFormat('d MMM').format(currentWeekStart)} - ${DateFormat('d MMM yyyy').format(currentWeekEnd)}',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 200,
                child: _buildAttendancePieChart(colorScheme),
              ),
              const SizedBox(height: 16),
              _buildPieChartLegend(colorScheme),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // CHART 2: LINE CHART KEHADIRAN BULANAN (YANG DIPERBAIKI)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Performa Bulanan', // Judul Diperbaiki
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Total Hadir per Bulan', // Subjudul Diperbaiki
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 200,
                child: _buildAttendanceLineChart(colorScheme), // Fungsi Baru
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- PIE CHART LOGIC (MINGGUAN) ---
  Widget _buildAttendancePieChart(ColorScheme colorScheme) {
    // Filter data minggu ini
    final weeklyAttendance = attendanceList.where((att) {
      final date = att.timestamp;
      return date
              .isAfter(currentWeekStart.subtract(const Duration(seconds: 1))) &&
          date.isBefore(currentWeekEnd.add(const Duration(seconds: 1)));
    }).toList();

    // Hitung status
    int hadir = 0;
    int sakit = 0;
    int izin = 0;
    int alpha = 0;

    for (var att in weeklyAttendance) {
      final status = att.status.toUpperCase();
      if (['VALID', 'TERLAMBAT', 'HADIR'].contains(status))
        hadir++;
      else if (status == 'SAKIT')
        sakit++;
      else if (status == 'IZIN')
        izin++;
      else
        alpha++; // Alpha, Invalid, dll
    }

    final total = hadir + sakit + izin + alpha;
    if (total == 0) {
      return Center(
        child: Text(
          'Belum ada data minggu ini',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
      );
    }

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: [
          if (hadir > 0)
            PieChartSectionData(
              color: AppThemes.successColor,
              value: hadir.toDouble(),
              title: '${(hadir / total * 100).round()}%',
              radius: 50,
              titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          if (sakit > 0)
            PieChartSectionData(
              color: AppThemes.infoColor,
              value: sakit.toDouble(),
              title: '${(sakit / total * 100).round()}%',
              radius: 50,
              titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          if (izin > 0)
            PieChartSectionData(
              color: AppThemes.warningColor,
              value: izin.toDouble(),
              title: '${(izin / total * 100).round()}%',
              radius: 50,
              titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          if (alpha > 0)
            PieChartSectionData(
              color: AppThemes.errorColor,
              value: alpha.toDouble(),
              title: '${(alpha / total * 100).round()}%',
              radius: 50,
              titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
        ],
      ),
    );
  }

  Widget _buildPieChartLegend(ColorScheme colorScheme) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _buildLegendItem('Hadir', AppThemes.successColor, colorScheme),
        _buildLegendItem('Sakit', AppThemes.infoColor, colorScheme),
        _buildLegendItem('Izin', AppThemes.warningColor, colorScheme),
        _buildLegendItem('Alpha', AppThemes.errorColor, colorScheme),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, ColorScheme colorScheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // --- LINE CHART LOGIC (BULANAN - KEHADIRAN) ---
  Widget _buildAttendanceLineChart(ColorScheme colorScheme) {
    if (attendanceList.isEmpty) {
      return Center(
        child: Text(
          'Belum ada riwayat kehadiran',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
      );
    }

    // 1. Inisialisasi Map 6 Bulan Terakhir
    final now = DateTime.now();
    final Map<int, int> monthlyPresence = {}; // Key: Month Index (1-12)

    // Set default 0 untuk 6 bulan ke belakang
    for (int i = 5; i >= 0; i--) {
      // Logic mundur bulan: jika month - i <= 0, handle tahun lalu (simple logic: DateTime handle otomatis)
      final d = DateTime(now.year, now.month - i, 1);
      monthlyPresence[d.month] = 0;
    }

    // 2. Hitung Data Real dari attendanceList
    // Kita filter hanya yang VALID/HADIR/TERLAMBAT
    for (var att in attendanceList) {
      try {
        final date = att.timestamp;
        // Cek apakah masuk range 6 bulan terakhir
        // Batas bawah: Tanggal 1 pada 5 bulan lalu
        final cutoffDate = DateTime(now.year, now.month - 5, 1);

        if (date.isAfter(cutoffDate.subtract(const Duration(days: 1)))) {
          final status = att.status.toUpperCase();
          if (['VALID', 'TERLAMBAT', 'HADIR'].contains(status)) {
            // Tambahkan counter di bulan tersebut
            // Pastikan bulan ada di map inisialisasi (agar tidak menghitung bulan depan/jauh lampau)
            if (monthlyPresence.containsKey(date.month)) {
              monthlyPresence[date.month] =
                  (monthlyPresence[date.month] ?? 0) + 1;
            }
          }
        }
      } catch (_) {}
    }

    // 3. Konversi ke FlSpot untuk Chart
    final spots = <FlSpot>[];
    // Urutkan key agar grafik urut waktu
    // Kita harus urutkan berdasarkan urutan 6 bulan terakhir, bukan index bulan kalender 1-12
    // Contoh: [Nov, Dec, Jan, Feb, Mar, Apr] -> urutannya harus dijaga

    final List<String> bottomTitles = [];
    int xIndex = 0;

    for (int i = 5; i >= 0; i--) {
      final d = DateTime(now.year, now.month - i, 1);
      final monthKey = d.month;

      // Label Bawah (Jan, Feb, ...)
      bottomTitles.add(DateFormat('MMM').format(d));

      // Nilai Y (Jumlah Hadir)
      final count = monthlyPresence[monthKey] ?? 0;
      spots.add(FlSpot(xIndex.toDouble(), count.toDouble()));

      xIndex++;
    }

    // Cari nilai Max Y untuk padding atas
    double maxY = 0;
    for (var spot in spots) {
      if (spot.y > maxY) maxY = spot.y;
    }
    // Tambah padding, minimal 5 (biar ga gepeng kalau 0 semua)
    maxY = (maxY < 5) ? 5 : maxY + 2;

    // 4. Build Chart Widget
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 5, // Garis bantu tiap kelipatan 5 hari
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: colorScheme.outline.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < bottomTitles.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      bottomTitles[index],
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 5, // Interval angka di kiri (0, 5, 10, 15...)
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                if (value % 1 != 0)
                  return const SizedBox(); // Hanya tampilkan integer
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (bottomTitles.length - 1).toDouble(),
        minY: 0,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppThemes.primaryColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppThemes.primaryColor.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}
