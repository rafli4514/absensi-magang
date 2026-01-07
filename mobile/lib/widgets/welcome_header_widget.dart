import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../themes/app_themes.dart';
import '../utils/indonesian_time.dart';

class WelcomeHeaderWidget extends StatefulWidget {
  const WelcomeHeaderWidget({super.key});

  @override
  State<WelcomeHeaderWidget> createState() => _WelcomeHeaderWidgetState();
}

class _WelcomeHeaderWidgetState extends State<WelcomeHeaderWidget> {
  // ... Logic state sama ...
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
    _timeSubscription = IndonesianTime.nowStream.listen((_) {
      if (mounted) _updateDisplay();
    });
  }

  void _updateDisplay() {
    // ... Logic update display sama ...
    setState(() {
      final now = IndonesianTime.now;
      final hour = now.hour;
      _currentGreeting = IndonesianTime.getGreeting();
      _currentTime = IndonesianTime.formatTime(now);
      _currentDay = IndonesianTime.getDayName(now.weekday);
      _currentDate =
          '${now.day} ${IndonesianTime.getMonthName(now.month)} ${now.year}';

      if (hour >= 8 && hour <= 17) {
        final totalMinutes = 9 * 60;
        final currentMinutes = (hour - 8) * 60 + now.minute;
        _progress = currentMinutes / totalMinutes;
      } else if (hour < 8) {
        _progress = 0.0;
      } else {
        _progress = 1.0;
      }

      if (hour < 8)
        _workStatus = 'Belum mulai kerja';
      else if (hour >= 8 && hour < 12)
        _workStatus = 'Waktu kerja pagi';
      else if (hour >= 12 && hour < 13)
        _workStatus = 'Istirahat siang';
      else if (hour >= 13 && hour < 17)
        _workStatus = 'Waktu kerja siang';
      else if (hour >= 17 && hour < 18)
        _workStatus = 'Waktu pulang';
      else
        _workStatus = 'Waktu istirahat';
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
    final user = authProvider.user;
    final colorScheme = Theme.of(context).colorScheme;
    final hour = DateTime.now().hour;

    // Gunakan warna tema otomatis
    final timeColor = AppThemes.primaryColor;
    final progressColor = AppThemes.primaryColor;
    final userDepartment = user?.divisi ?? user?.instansi;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                          child: Icon(_getTimeIcon(hour),
                              size: 16, color: timeColor),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _currentGreeting,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurfaceVariant,
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
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (user?.displayRole != null)
                      Text(
                        user!.displayRole,
                        style: TextStyle(
                            fontSize: 13, color: colorScheme.onSurfaceVariant),
                      ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppThemes.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _currentTime,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppThemes.primaryColor,
                      ),
                    ),
                    Text(
                      _currentDay,
                      style: TextStyle(
                          fontSize: 11, color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: colorScheme.outline.withOpacity(0.2)),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded,
                  size: 16, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                _currentDate,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface),
              ),
            ],
          ),
          if (_progress > 0 && _progress < 1) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(_getWorkStatusIcon(_workStatus),
                    size: 14, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _workStatus,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurfaceVariant),
                  ),
                ),
                Text(
                  '${(_progress * 100).toInt()}%',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: progressColor),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor: colorScheme.surfaceContainerHigh,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 6,
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(_getWorkStatusIcon(_workStatus),
                    size: 14, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  _workStatus,
                  style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
