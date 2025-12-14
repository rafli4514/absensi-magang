import 'package:flutter/material.dart';

import '../themes/app_themes.dart';

class PerformanceCard extends StatelessWidget {
  final int presentDays;
  final int totalDays;

  const PerformanceCard({
    super.key,
    required this.presentDays,
    required this.totalDays,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Handle empty state
    if (totalDays == 0) {
      return Card(
        elevation: isDark ? 4 : 2,
        color: isDark ? AppThemes.darkSurface : theme.cardTheme.color,
        shadowColor: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isDark
              ? const BorderSide(color: AppThemes.darkOutline, width: 0.5)
              : BorderSide.none,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Performa Bulanan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppThemes.darkTextPrimary
                          : AppThemes.onSurfaceColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.trending_up_rounded,
                    size: 20,
                    color: isDark
                        ? AppThemes.darkAccentBlue
                        : AppThemes.primaryColor,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.bar_chart_outlined,
                      size: 48,
                      color: isDark
                          ? AppThemes.darkTextSecondary.withOpacity(0.5)
                          : AppThemes.hintColor.withOpacity(0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Belum ada data performa',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? AppThemes.darkTextSecondary
                            : AppThemes.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    double percentage = (presentDays / totalDays * 100);
    bool targetAchieved = percentage >= 85;

    return Card(
      elevation: isDark ? 4 : 2,
      color: isDark ? AppThemes.darkSurface : theme.cardTheme.color,
      shadowColor: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isDark
            ? const BorderSide(color: AppThemes.darkOutline, width: 0.5)
            : BorderSide.none,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Performa Bulanan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppThemes.darkTextPrimary
                            : AppThemes.onSurfaceColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.trending_up_rounded,
                      size: 20,
                      color: isDark
                          ? AppThemes.darkAccentBlue
                          : AppThemes.primaryColor,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (isDark
                                ? AppThemes.darkAccentBlue
                                : AppThemes.primaryColor)
                            .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          (isDark
                                  ? AppThemes.darkAccentBlue
                                  : AppThemes.primaryColor)
                              .withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${percentage.round()}% Hadir',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppThemes.darkAccentBlue
                          : AppThemes.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Main stats section
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 20,
                            color: isDark
                                ? AppThemes.darkAccentBlue
                                : AppThemes.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$presentDays hari hadir',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppThemes.darkTextPrimary
                                  : AppThemes.onSurfaceColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 28),
                        child: Text(
                          '$totalDays total hari kerja',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? AppThemes.darkTextSecondary
                                : AppThemes.hintColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Circular progress indicator
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        value: percentage / 100,
                        strokeWidth: 6,
                        backgroundColor: isDark
                            ? AppThemes.darkOutline
                            : AppThemes.hintColor.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark
                              ? AppThemes.darkAccentBlue
                              : AppThemes.primaryColor,
                        ),
                      ),
                    ),
                    Text(
                      '${percentage.round()}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppThemes.darkAccentBlue
                            : AppThemes.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Monthly target progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Target Bulanan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppThemes.darkTextSecondary
                        : AppThemes.hintColor,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 8,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppThemes.darkOutline
                        : AppThemes.hintColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width:
                          (percentage / 100) *
                          (MediaQuery.of(context).size.width - 80),
                      height: 8,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppThemes.darkAccentBlue
                            : AppThemes.primaryColor,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          if (isDark)
                            BoxShadow(
                              color: AppThemes.darkAccentBlue.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Target: 85%',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppThemes.darkTextSecondary
                            : AppThemes.hintColor,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: targetAchieved
                              ? AppThemes.successColor
                              : (isDark
                                    ? AppThemes.darkTextTertiary
                                    : AppThemes.hintColor.withOpacity(0.4)),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Target Tercapai',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: targetAchieved
                                ? AppThemes.successColor
                                : (isDark
                                      ? AppThemes.darkTextSecondary
                                      : AppThemes.hintColor),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
