import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../themes/app_themes.dart';
import '../utils/indonesian_time.dart';

class WelcomeHeaderWidget extends StatefulWidget {
  const WelcomeHeaderWidget({super.key});

  @override
  State<WelcomeHeaderWidget> createState() => _WelcomeHeaderWidgetState();
}

class _WelcomeHeaderWidgetState extends State<WelcomeHeaderWidget> {
  late StreamSubscription<DateTime> _timeSubscription;
  String _currentGreeting = '';
  String _currentTime = '';
  String _currentDay = '';
  String _currentDate = '';
  double _progress = 0.0;
  String _workStatus = '';

  @override
  void initState() {
    super.initState();
    _updateDisplay();

    // Update setiap menit (tidak perlu setiap detik untuk hemat baterai)
    _timeSubscription = IndonesianTime.nowStream.listen((_) {
      if (mounted) {
        _updateDisplay();
      }
    });
  }

  void _updateDisplay() {
    setState(() {
      final now = IndonesianTime.now;
      final hour = now.hour;

      _currentGreeting = IndonesianTime.getGreeting();
      _currentTime = IndonesianTime.formatTime(now);
      _currentDay = IndonesianTime.getDayName(now.weekday);
      _currentDate =
          '${now.day} ${IndonesianTime.getMonthName(now.month)} ${now.year}';

      // Hitung progress hari (8:00 - 17:00 = 9 jam kerja)
      if (hour >= 8 && hour <= 17) {
        final totalMinutes = 9 * 60; // 9 jam dalam menit
        final currentMinutes = (hour - 8) * 60 + now.minute;
        _progress = currentMinutes / totalMinutes;
      } else if (hour < 8) {
        _progress = 0.0;
      } else {
        _progress = 1.0;
      }

      // Tentukan status kerja berdasarkan jam
      if (hour < 8) {
        _workStatus = 'Belum mulai kerja';
      } else if (hour >= 8 && hour < 12) {
        _workStatus = 'Waktu kerja pagi';
      } else if (hour >= 12 && hour < 13) {
        _workStatus = 'Istirahat siang';
      } else if (hour >= 13 && hour < 17) {
        _workStatus = 'Waktu kerja siang';
      } else if (hour >= 17 && hour < 18) {
        _workStatus = 'Waktu pulang';
      } else {
        _workStatus = 'Waktu istirahat';
      }
    });
  }

  @override
  void dispose() {
    _timeSubscription.cancel();
    super.dispose();
  }

  // Get appropriate icon based on time
  IconData _getTimeIcon(int hour) {
    if (hour >= 5 && hour < 12) return Icons.wb_sunny_outlined;
    if (hour >= 12 && hour < 15) return Icons.wb_twilight_outlined;
    if (hour >= 15 && hour < 18) return Icons.nights_stay_outlined;
    return Icons.bedtime_outlined;
  }

  // Get appropriate color based on time and theme
  Color _getTimeColor(int hour, bool isDark) {
    if (hour >= 5 && hour < 12) {
      return isDark ? AppThemes.darkAccentBlue : AppThemes.primaryColor;
    }
    if (hour >= 12 && hour < 15) {
      return isDark ? AppThemes.darkAccentCyan : AppThemes.primaryLight;
    }
    if (hour >= 15 && hour < 18) {
      return isDark
          ? AppThemes.darkAccentCyan.withOpacity(0.8)
          : AppThemes.primaryDark;
    }
    return isDark
        ? AppThemes.darkAccentBlue.withOpacity(0.7)
        : AppThemes.secondaryColor;
  }

  // Get progress bar color based on theme
  Color _getProgressColor(bool isDark) {
    return isDark ? AppThemes.darkAccentBlue : AppThemes.primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = authProvider.user;
    final isDark = themeProvider.isDarkMode;
    final hour = DateTime.now().hour;
    final timeColor = _getTimeColor(hour, isDark);
    final progressColor = _getProgressColor(isDark);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppThemes.darkSurface : AppThemes.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppThemes.darkOutline.withOpacity(0.1)
              : Colors.grey.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.08 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First Row: Greeting and Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting and Name Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting with icon - more subtle
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: timeColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: timeColor.withOpacity(0.1),
                              width: 0.5,
                            ),
                          ),
                          child: Icon(
                            _getTimeIcon(hour),
                            size: 16,
                            color: timeColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _currentGreeting,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppThemes.darkTextSecondary
                                : AppThemes.hintColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // User Name - clean and prominent
                    Text(
                      user?.displayName ?? 'Pengguna',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppThemes.darkTextPrimary
                            : AppThemes.onSurfaceColor,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Position if available
                    if (user?.position != null &&
                        user!.position!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        user.position!,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppThemes.darkTextTertiary
                              : AppThemes.neutralColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Time Display - Clean and minimal
              Container(
                constraints: const BoxConstraints(minWidth: 70),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Time with minimal styling
                    Text(
                      _currentTime,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppThemes.darkTextPrimary
                            : AppThemes.onSurfaceColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Day with subtle styling
                    Text(
                      _currentDay,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppThemes.darkTextTertiary
                            : AppThemes.neutralColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Date Display - subtle
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 12),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: isDark
                      ? AppThemes.darkTextTertiary
                      : AppThemes.neutralColor,
                ),
                const SizedBox(width: 8),
                Text(
                  _currentDate,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppThemes.darkTextTertiary
                        : AppThemes.neutralColor,
                  ),
                ),
              ],
            ),
          ),

          // Progress Bar for Work Day - with minimal glow
          if (_progress > 0 && _progress < 1)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      _getWorkStatusIcon(_workStatus),
                      size: 14,
                      color: isDark
                          ? AppThemes.darkTextTertiary
                          : AppThemes.neutralColor,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _workStatus,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppThemes.darkTextTertiary
                              : AppThemes.neutralColor,
                        ),
                      ),
                    ),
                    Text(
                      '${(_progress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: progressColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 5,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppThemes.darkOutline.withOpacity(0.2)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: progressColor,
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '8:00',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark
                            ? AppThemes.darkTextTertiary
                            : AppThemes.neutralColor,
                      ),
                    ),
                    Text(
                      'Working Time Progress',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark
                            ? AppThemes.darkTextTertiary
                            : AppThemes.neutralColor,
                      ),
                    ),
                    Text(
                      '17:00',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark
                            ? AppThemes.darkTextTertiary
                            : AppThemes.neutralColor,
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(
                    _getWorkStatusIcon(_workStatus),
                    size: 14,
                    color: isDark
                        ? AppThemes.darkTextTertiary
                        : AppThemes.neutralColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _workStatus,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppThemes.darkTextTertiary
                          : AppThemes.neutralColor,
                    ),
                  ),
                ],
              ),
            ),

          // Quick Stats (Department & Location) - minimal badges
          if (user?.department != null && user!.department!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Department Badge - minimal
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppThemes.darkOutline.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? AppThemes.darkOutline.withOpacity(0.3)
                            : Colors.grey.withOpacity(0.1),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.business_center_outlined,
                          size: 12,
                          color: isDark
                              ? AppThemes.darkTextTertiary
                              : AppThemes.neutralColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          user.department!,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppThemes.darkTextSecondary
                                : AppThemes.onSurfaceColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Location Badge - minimal
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppThemes.darkOutline.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? AppThemes.darkOutline.withOpacity(0.3)
                            : Colors.grey.withOpacity(0.1),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: isDark
                              ? AppThemes.darkTextTertiary
                              : AppThemes.neutralColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'On-site',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppThemes.darkTextTertiary
                                : AppThemes.neutralColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Helper method to get work status icon
  IconData _getWorkStatusIcon(String status) {
    if (status.contains('kerja')) {
      return Icons.work_outline;
    } else if (status.contains('istirahat')) {
      return Icons.coffee_outlined;
    } else if (status.contains('pulang')) {
      return Icons.home_outlined;
    } else {
      return Icons.schedule_outlined;
    }
  }
}
