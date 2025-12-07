import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../navigation/route_names.dart';
import '../providers/theme_provider.dart';
import '../themes/app_themes.dart';
import '../utils/indonesian_time.dart';

class AttendanceCard extends StatefulWidget {
  final VoidCallback onClockIn;
  final VoidCallback onClockOut;
  final bool isClockedIn;
  final bool isClockedOut;

  const AttendanceCard({
    super.key,
    required this.onClockIn,
    required this.onClockOut,
    required this.isClockedIn,
    required this.isClockedOut,
  });

  @override
  State<AttendanceCard> createState() => _AttendanceCardState();
}

class _AttendanceCardState extends State<AttendanceCard> {
  late StreamSubscription<DateTime> _timeSubscription;

  @override
  void initState() {
    super.initState();
    // Subscribe ke stream waktu
    _timeSubscription = IndonesianTime.nowStream.listen((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timeSubscription.cancel();
    super.dispose();
  }

  // Fungsi untuk cek apakah sudah waktunya clock out (setelah jam 17:00)
  bool _isClockOutTime() {
    return IndonesianTime.now.hour >= 17;
  }

  // Fungsi untuk cek apakah sudah waktunya clock in (setelah jam 08:00)
  bool _isClockInTime() {
    return IndonesianTime.now.hour >= 8;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    final canClockOut = _isClockOutTime();
    final canClockIn = _isClockInTime();

    final bool showClockIn =
        !widget.isClockedIn || (widget.isClockedIn && widget.isClockedOut);
    final bool showClockOut =
        widget.isClockedIn && !widget.isClockedOut && canClockOut;

    return Card(
      elevation: isDarkMode ? 4 : 2,
      color: isDarkMode ? AppThemes.darkSurface : theme.cardTheme.color,
      shadowColor: Colors.black.withOpacity(isDarkMode ? 0.4 : 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isDarkMode
            ? const BorderSide(color: AppThemes.darkOutline, width: 0.5)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: isDarkMode
                    ? AppThemes.darkTextPrimary
                    : AppThemes.onSurfaceColor,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Clock In Button
                if (showClockIn) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: canClockIn ? widget.onClockIn : null,
                      icon: const Icon(Icons.login_rounded),
                      label: const Text('Clock In'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canClockIn
                            ? AppThemes.primaryColor
                            : AppThemes.primaryColor.withOpacity(0.5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: canClockIn ? 2 : 0,
                        shadowColor: Colors.black.withOpacity(
                          isDarkMode ? 0.3 : 0.1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                // Clock Out Button
                if (showClockOut) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: widget.onClockOut,
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Clock Out'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppThemes.primaryDark,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 2,
                        shadowColor: Colors.black.withOpacity(
                          isDarkMode ? 0.3 : 0.1,
                        ),
                      ),
                    ),
                  ),
                ],
                // Jika kedua button tidak tampil, tampilkan status
                if (!showClockIn && !showClockOut) ...[
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppThemes.successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppThemes.successColor.withOpacity(0.3),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Attendance Complete',
                          style: TextStyle(
                            color: AppThemes.successColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),

            // Info waktu saat ini - StreamBuilder untuk update otomatis
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppThemes.darkOutline.withOpacity(0.3)
                    : AppThemes.backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: StreamBuilder<DateTime>(
                stream: IndonesianTime.nowStream,
                builder: (context, snapshot) {
                  final currentTime = snapshot.data ?? IndonesianTime.now;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: isDarkMode
                            ? AppThemes.darkTextSecondary
                            : AppThemes.hintColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Current Time: ${IndonesianTime.formatTime(currentTime)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode
                              ? AppThemes.darkTextSecondary
                              : AppThemes.hintColor,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, RouteNames.report);
              },
              style: TextButton.styleFrom(
                foregroundColor: isDarkMode
                    ? AppThemes.darkAccentBlue
                    : AppThemes.primaryColor,
              ),
              child: const Center(child: Text('View Attendance Report')),
            ),
          ],
        ),
      ),
    );
  }
}
