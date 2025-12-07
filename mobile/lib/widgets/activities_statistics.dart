import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../themes/app_themes.dart';

class ActivitiesStatistics extends StatelessWidget {
  final bool isMobile;

  const ActivitiesStatistics({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final dailyChart = _ChartCard(
      title: 'Daily Distribution',
      isDark: isDark,
      height: 250,
      child: _buildPieChart(),
    );

    final monthlyChart = _ChartCard(
      title: 'Monthly Performance',
      isDark: isDark,
      height: 250,
      child: _buildLineChart(isDark),
    );

    if (isMobile) {
      return Column(
        children: [dailyChart, const SizedBox(height: 16), monthlyChart],
      );
    } else {
      return Column(
        children: [dailyChart, const SizedBox(height: 16), monthlyChart],
      );
    }
  }

  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 30,
        sections: [
          _section(35, AppThemes.primaryColor),
          _section(25, AppThemes.successColor),
          _section(20, AppThemes.warningColor),
          _section(20, AppThemes.secondaryColor),
        ],
      ),
    );
  }

  PieChartSectionData _section(double val, Color color) {
    return PieChartSectionData(
      color: color,
      value: val,
      title: '${val.toInt()}%',
      radius: 45,
      titleStyle: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildLineChart(bool isDark) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: isDark ? AppThemes.darkOutline : Colors.grey.shade200,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, _) {
                const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                if (val.toInt() >= 0 && val.toInt() < months.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      months[val.toInt()],
                      style: TextStyle(
                        fontSize: 10,
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
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 5,
        minY: 0,
        maxY: 6,
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 3),
              FlSpot(1, 1),
              FlSpot(2, 4),
              FlSpot(3, 2),
              FlSpot(4, 5),
              FlSpot(5, 3),
            ],
            isCurved: true,
            color: AppThemes.primaryColor,
            barWidth: 3,
            dotData: const FlDotData(show: false),
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
