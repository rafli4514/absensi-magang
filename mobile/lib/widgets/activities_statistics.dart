import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../themes/app_themes.dart';
import '../../models/logbook.dart';

class ActivitiesStatistics extends StatelessWidget {
  final bool isMobile;
  final List<LogBook> logbooks;

  const ActivitiesStatistics({
    super.key,
    required this.isMobile,
    this.logbooks = const [],
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final dailyChart = _ChartCard(
      title: 'Distribusi Aktivitas', // Translate
      isDark: isDark,
      height: 250,
      child: _buildPieChart(isDark),
    );

    final weeklyChart = _ChartCard(
      title: 'Performa Mingguan', // Translate
      isDark: isDark,
      height: 250,
      child: _buildLineChart(isDark),
    );

    return Column(
      children: [dailyChart, const SizedBox(height: 16), weeklyChart],
    );
  }

  Widget _buildPieChart(bool isDark) {
    if (logbooks.isEmpty) {
      return _buildEmptyState(isDark);
    }

    // Hitung distribusi berdasarkan tipe
    final typeDistribution = <String, int>{};
    for (final logbook in logbooks) {
      String? category;
      if (logbook.type != null) {
        category = logbook.type!.displayName;
      } else if (logbook.status != null) {
        category = logbook.status!.displayName;
      } else {
        category = 'Lainnya';
      }

      typeDistribution[category] = (typeDistribution[category] ?? 0) + 1;
    }

    if (typeDistribution.isEmpty) {
      return _buildEmptyState(isDark);
    }

    final pieChartData = typeDistribution.entries.toList();
    final totalWithType = typeDistribution.values.reduce((a, b) => a + b);
    final colors = [
      AppThemes.primaryColor,
      AppThemes.successColor,
      AppThemes.warningColor,
      AppThemes.errorColor,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
    ];

    return PieChart(
      PieChartData(
        sections: pieChartData.asMap().entries.map((entry) {
          final index = entry.key;
          final entryData = entry.value;
          final percentage = (entryData.value / totalWithType * 100);
          return PieChartSectionData(
            value: entryData.value.toDouble(),
            title: '${entryData.key}\n${percentage.toStringAsFixed(0)}%',
            color: colors[index % colors.length],
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }

  Widget _buildLineChart(bool isDark) {
    if (logbooks.isEmpty) {
      return _buildEmptyState(isDark);
    }

    // Cek range tanggal
    DateTime? minDate;
    DateTime? maxDate;

    for (final logbook in logbooks) {
      try {
        final logDate = DateTime.parse(logbook.tanggal);
        if (minDate == null || logDate.isBefore(minDate)) minDate = logDate;
        if (maxDate == null || logDate.isAfter(maxDate)) maxDate = logDate;
      } catch (e) {
        // Skip invalid dates
      }
    }

    if (minDate == null || maxDate == null) {
      return _buildEmptyState(isDark);
    }

    final now = DateTime.now();
    final weeklyData = <String, int>{};
    final weekRanges = <String, List<DateTime>>{};

    // Hitung 8 minggu ke belakang
    for (int i = 7; i >= 0; i--) {
      final weekDate = now.subtract(Duration(days: i * 7));
      final daysFromMonday = weekDate.weekday - 1;
      final weekStart = DateTime(weekDate.year, weekDate.month, weekDate.day)
          .subtract(Duration(days: daysFromMonday));
      final weekEnd = weekStart.add(const Duration(days: 6));

      final weekKey =
          '${DateFormat('dd MMM').format(weekStart)} - ${DateFormat('dd MMM').format(weekEnd)}';
      weeklyData[weekKey] = 0;
      weekRanges[weekKey] = [weekStart, weekEnd];
    }

    // Hitung logbook per minggu
    for (final logbook in logbooks) {
      try {
        final logDate = DateTime.parse(logbook.tanggal);
        final logDateOnly = DateTime(logDate.year, logDate.month, logDate.day);

        for (final entry in weekRanges.entries) {
          final weekStart = entry.value[0];
          final weekEnd = entry.value[1];

          if (logDateOnly
                  .isAfter(weekStart.subtract(const Duration(seconds: 1))) &&
              logDateOnly.isBefore(weekEnd.add(const Duration(days: 1)))) {
            weeklyData[entry.key] = (weeklyData[entry.key] ?? 0) + 1;
            break;
          }
        }
      } catch (e) {
        // Skip
      }
    }

    final weeklyEntries = weeklyData.entries.toList();
    weeklyEntries.sort((a, b) {
      final aStart = weekRanges[a.key]?[0] ?? DateTime.now();
      final bStart = weekRanges[b.key]?[0] ?? DateTime.now();
      return aStart.compareTo(bStart);
    });

    final hasData = weeklyEntries.any((entry) => entry.value > 0);

    if (!hasData || weeklyEntries.isEmpty) {
      return _buildEmptyState(isDark);
    }

    final maxValue =
        weeklyEntries.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          verticalInterval: 1,
          horizontalInterval:
              maxValue > 5 ? (maxValue / 5).ceil().toDouble() : 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: isDark
                ? AppThemes.darkOutline.withOpacity(0.2)
                : Colors.grey.withOpacity(0.2),
            strokeWidth: 1,
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: isDark
                ? AppThemes.darkOutline.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30, // Diperkecil agar rapi
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: TextStyle(
                  fontSize: 10,
                  color: isDark
                      ? AppThemes.darkTextSecondary
                      : AppThemes.hintColor,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < weeklyEntries.length &&
                    value.toInt() >= 0) {
                  final label = weeklyEntries[value.toInt()].key;
                  final firstDate = label.split(' - ').first;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      firstDate,
                      style: TextStyle(
                        fontSize: 9,
                        color: isDark
                            ? AppThemes.darkTextSecondary
                            : AppThemes.hintColor,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: isDark
                ? AppThemes.darkOutline.withOpacity(0.3)
                : Colors.grey.withOpacity(0.3),
          ),
        ),
        minX: 0,
        maxX: weeklyEntries.isNotEmpty
            ? (weeklyEntries.length - 1).toDouble()
            : 1,
        minY: 0,
        maxY: maxValue > 0 ? maxValue.toDouble() + 1 : 1,
        lineBarsData: [
          LineChartBarData(
            spots: weeklyEntries.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.value.toDouble());
            }).toList(),
            isCurved: true,
            color: AppThemes.primaryColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppThemes.primaryColor.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart_rounded,
            size: 48,
            color: isDark
                ? AppThemes.darkTextSecondary.withOpacity(0.5)
                : AppThemes.hintColor.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'Belum ada data tersedia',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppThemes.darkTextSecondary : AppThemes.hintColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;
  final bool isDark;
  final double height;

  const _ChartCard({
    required this.title,
    required this.child,
    required this.isDark,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppThemes.darkSurface : AppThemes.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppThemes.darkOutline : Colors.grey.shade200,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color:
                  isDark ? AppThemes.darkTextPrimary : AppThemes.onSurfaceColor,
            ),
          ),
          const Divider(height: 24),
          Expanded(child: child),
        ],
      ),
    );
  }
}
