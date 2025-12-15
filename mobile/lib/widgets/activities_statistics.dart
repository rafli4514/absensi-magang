import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/logbook.dart';
import '../../../themes/app_themes.dart';

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
      title: 'Daily Distribution',
      isDark: isDark,
      height: 250,
      child: _buildPieChart(isDark),
    );

    final weeklyChart = _ChartCard(
      title: 'Weekly Performance',
      isDark: isDark,
      height: 250,
      child: _buildLineChart(isDark),
    );

    if (isMobile) {
      return Column(
        children: [dailyChart, const SizedBox(height: 16), weeklyChart],
      );
    } else {
      return Column(
        children: [dailyChart, const SizedBox(height: 16), weeklyChart],
      );
    }
  }

  Widget _buildPieChart(bool isDark) {
    if (logbooks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 48,
              color: isDark
                  ? AppThemes.darkTextSecondary.withOpacity(0.5)
                  : AppThemes.hintColor.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'No data available',
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppThemes.darkTextSecondary
                    : AppThemes.hintColor,
              ),
            ),
          ],
        ),
      );
    }

    // Calculate distribution by type (prioritize type, fallback to status)
    final typeDistribution = <String, int>{};
    for (final logbook in logbooks) {
      String? category;
      if (logbook.type != null) {
        category = logbook.type!.displayName;
      } else if (logbook.status != null) {
        category = logbook.status!.displayName;
      } else {
        category = 'Other';
      }
      
      typeDistribution[category] = (typeDistribution[category] ?? 0) + 1;
    }

    if (typeDistribution.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 48,
              color: isDark
                  ? AppThemes.darkTextSecondary.withOpacity(0.5)
                  : AppThemes.hintColor.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'No data available',
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppThemes.darkTextSecondary
                    : AppThemes.hintColor,
              ),
            ),
          ],
        ),
      );
    }

    // Convert to pie chart data
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart_outlined,
              size: 48,
              color: isDark
                  ? AppThemes.darkTextSecondary.withOpacity(0.5)
                  : AppThemes.hintColor.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'No data available',
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppThemes.darkTextSecondary
                    : AppThemes.hintColor,
              ),
            ),
          ],
        ),
      );
    }

    // Get date range from logbooks
    DateTime? minDate;
    DateTime? maxDate;
    
    for (final logbook in logbooks) {
      try {
        final logDate = DateTime.parse(logbook.tanggal);
        if (minDate == null || logDate.isBefore(minDate)) {
          minDate = logDate;
        }
        if (maxDate == null || logDate.isAfter(maxDate)) {
          maxDate = logDate;
        }
      } catch (e) {
        // Skip invalid dates
      }
    }

    if (minDate == null || maxDate == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart_outlined,
              size: 48,
              color: isDark
                  ? AppThemes.darkTextSecondary.withOpacity(0.5)
                  : AppThemes.hintColor.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'No data available',
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppThemes.darkTextSecondary
                    : AppThemes.hintColor,
              ),
            ),
          ],
        ),
      );
    }

    // Calculate last 8 weeks from now (backwards)
    final now = DateTime.now();
    final weeklyData = <String, int>{};
    final weekRanges = <String, List<DateTime>>{};
    
    // Calculate 8 weeks backwards from now
    for (int i = 7; i >= 0; i--) {
      // Calculate the date i weeks ago
      final weekDate = now.subtract(Duration(days: i * 7));
      
      // Get Monday of that week (weekday: 1 = Monday, 7 = Sunday)
      final daysFromMonday = weekDate.weekday - 1; // 0 = Monday, 6 = Sunday
      final weekStart = DateTime(
        weekDate.year,
        weekDate.month,
        weekDate.day,
      ).subtract(Duration(days: daysFromMonday));
      
      final weekEnd = weekStart.add(const Duration(days: 6));
      
      // Format: "dd MMM" - "dd MMM"
      final weekKey = '${DateFormat('dd MMM').format(weekStart)} - ${DateFormat('dd MMM').format(weekEnd)}';
      weeklyData[weekKey] = 0;
      weekRanges[weekKey] = [
        weekStart,
        weekEnd,
      ];
    }

    // Count logbooks by week
    for (final logbook in logbooks) {
      try {
        final logDate = DateTime.parse(logbook.tanggal);
        final logDateOnly = DateTime(logDate.year, logDate.month, logDate.day);
        
        // Find which week this logbook belongs to
        for (final entry in weekRanges.entries) {
          final weekStart = entry.value[0];
          final weekEnd = entry.value[1];
          
          // Check if logbook date falls within this week (inclusive)
          // weekStart is the Monday (00:00:00), weekEnd is the Sunday (23:59:59)
          if (logDateOnly.isAfter(weekStart.subtract(const Duration(seconds: 1))) &&
              logDateOnly.isBefore(weekEnd.add(const Duration(days: 1)))) {
            weeklyData[entry.key] = (weeklyData[entry.key] ?? 0) + 1;
            break; // Only count once
          }
        }
      } catch (e) {
        // Skip invalid dates
      }
    }

    // Sort all weeks by date (include weeks with 0 entries for complete chart)
    final weeklyEntries = weeklyData.entries.toList();
    weeklyEntries.sort((a, b) {
      final aStart = weekRanges[a.key]?[0] ?? DateTime.now();
      final bStart = weekRanges[b.key]?[0] ?? DateTime.now();
      return aStart.compareTo(bStart);
    });
    
    // Check if there's any data
    final hasData = weeklyEntries.any((entry) => entry.value > 0);
    
    if (!hasData || weeklyEntries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart_outlined,
              size: 48,
              color: isDark
                  ? AppThemes.darkTextSecondary.withOpacity(0.5)
                  : AppThemes.hintColor.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'No data available',
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppThemes.darkTextSecondary
                    : AppThemes.hintColor,
              ),
            ),
          ],
        ),
      );
    }

    final maxValue = weeklyEntries.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          verticalInterval: 1,
          horizontalInterval: maxValue > 5 ? (maxValue / 5).ceil().toDouble() : 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: isDark
                  ? AppThemes.darkOutline.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: isDark
                  ? AppThemes.darkOutline.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark
                        ? AppThemes.darkTextSecondary
                        : AppThemes.hintColor,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < weeklyEntries.length && value.toInt() >= 0) {
                  final label = weeklyEntries[value.toInt()].key;
                  // Show only first date of the week range for cleaner display
                  final firstDate = label.split(' - ').first;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      firstDate,
                      style: TextStyle(
                        fontSize: 8,
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
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
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
        maxX: weeklyEntries.isNotEmpty ? (weeklyEntries.length - 1).toDouble() : 1,
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
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
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
              color: isDark
                  ? AppThemes.darkTextPrimary
                  : AppThemes.onSurfaceColor,
            ),
          ),
          const Divider(height: 24),
          Expanded(child: child),
        ],
      ),
    );
  }
}