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

    // Update setiap menit (hemat baterai dibanding detik)
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

      // Hitung progress hari kerja (08:00 - 17:00 = 9 jam)
      if (hour >= 8 && hour <= 17) {
        final totalMinutes = 9 * 60; // 540 menit
        final currentMinutes = (hour - 8) * 60 + now.minute;
        _progress = currentMinutes / totalMinutes;
      } else if (hour < 8) {
        _progress = 0.0;
      } else {
        _progress = 1.0;
      }

      // Tentukan status kerja
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

  IconData _getTimeIcon(int hour) {
    if (hour >= 5 && hour < 12) return Icons.wb_sunny_outlined;
    if (hour >= 12 && hour < 15) return Icons.wb_twilight_outlined;
    if (hour >= 15 && hour < 18) return Icons.nights_stay_outlined;
    return Icons.bedtime_outlined;
  }

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

  Color _getProgressColor(bool isDark) {
    return isDark ? AppThemes.darkAccentBlue : AppThemes.primaryColor;
  }

  IconData _getWorkStatusIcon(String status) {
    final s = status.toLowerCase();
    if (s.contains('kerja')) return Icons.work_outline;
    if (s.contains('istirahat')) return Icons.coffee_outlined;
    if (s.contains('pulang')) return Icons.home_outlined;
    return Icons.schedule_outlined;
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
        // Integrasi Theme: Background Card
        color: isDark ? AppThemes.darkSurface : AppThemes.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          // Integrasi Theme: Border halus
          color: isDark ? AppThemes.darkOutline : Colors.grey.withOpacity(0.1),
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
          // Row 1: Greeting & Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kolom Kiri: Greeting + Nama
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: timeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
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
                            // Integrasi Theme: Text Secondary
                            color: isDark
                                ? AppThemes.darkTextSecondary
                                : AppThemes.hintColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user?.displayName ?? 'Pengguna',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        // Integrasi Theme: Text Primary
                        color: isDark
                            ? AppThemes.darkTextPrimary
                            : AppThemes.onSurfaceColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (user?.position != null &&
                        user!.position!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        user.position!,
                        style: TextStyle(
                          fontSize: 13,
                          // Integrasi Theme: Text Tertiary
                          color: isDark
                              ? AppThemes.darkTextTertiary
                              : AppThemes.neutralColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Kolom Kanan: Jam Digital & Hari
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppThemes.darkSurfaceElevated
                      : AppThemes.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      isDark ? Border.all(color: AppThemes.darkOutline) : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _currentTime,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppThemes.darkAccentBlue
                            : AppThemes.primaryColor,
                      ),
                    ),
                    Text(
                      _currentDay,
                      style: TextStyle(
                        fontSize: 11,
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

          const SizedBox(height: 16),
          Divider(
            color: isDark ? AppThemes.darkOutline : Colors.grey.shade200,
          ),
          const SizedBox(height: 12),

          // Date Display
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color:
                    isDark ? AppThemes.darkTextSecondary : AppThemes.hintColor,
              ),
              const SizedBox(width: 8),
              Text(
                _currentDate,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppThemes.darkTextSecondary
                      : AppThemes.onSurfaceColor,
                ),
              ),
            ],
          ),

          // Work Progress Bar
          if (_progress > 0 && _progress < 1) ...[
            const SizedBox(height: 16),
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
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor:
                    isDark ? AppThemes.darkOutline : Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 6,
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
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
                Text(
                  _workStatus,
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: isDark
                        ? AppThemes.darkTextTertiary
                        : AppThemes.neutralColor,
                  ),
                ),
              ],
            ),
          ],

          // Quick Stats (Department & Location Badges)
          if (user?.department != null && user!.department!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildBadge(
                    icon: Icons.business_center_outlined,
                    label: user!.department!,
                    isDark: isDark,
                  ),
                  _buildBadge(
                    icon: Icons.location_on_outlined,
                    label: 'On-site',
                    isDark: isDark,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Helper Widget untuk Badge
  Widget _buildBadge({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark
            ? AppThemes.darkSurfaceElevated
            : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppThemes.darkOutline : Colors.grey.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: isDark ? AppThemes.darkTextTertiary : AppThemes.neutralColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
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
    );
  }
}
