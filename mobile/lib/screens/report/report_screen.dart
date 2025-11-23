import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/attendance.dart';
import '../../navigation/route_names.dart';
import '../../providers/theme_provider.dart';
import '../../themes/app_themes.dart';
import '../../utils/navigation_helper.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/floating_bottom_nav.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  DateTime _selectedDate = DateTime.now();
  final List<AttendanceRecord> _attendanceRecords = [
    AttendanceRecord(
      id: '1',
      date: DateTime(2024, 1, 15),
      checkIn: DateTime(2024, 1, 15, 8, 30),
      checkOut: DateTime(2024, 1, 15, 17, 15),
      status: AttendanceStatus.present,
    ),
    AttendanceRecord(
      id: '2',
      date: DateTime(2024, 1, 14),
      checkIn: DateTime(2024, 1, 14, 9, 15),
      checkOut: DateTime(2024, 1, 14, 17, 0),
      status: AttendanceStatus.late,
    ),
    AttendanceRecord(
      id: '3',
      date: DateTime(2024, 1, 13),
      checkIn: DateTime(2024, 1, 13, 8, 45),
      checkOut: DateTime(2024, 1, 13, 16, 45),
      status: AttendanceStatus.present,
    ),
    AttendanceRecord(
      id: '4',
      date: DateTime(2024, 1, 12),
      checkIn: null,
      checkOut: null,
      status: AttendanceStatus.absent,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    final presentCount = _attendanceRecords
        .where((r) => r.status == AttendanceStatus.present)
        .length;
    final lateCount = _attendanceRecords
        .where((r) => r.status == AttendanceStatus.late)
        .length;
    final absentCount = _attendanceRecords
        .where((r) => r.status == AttendanceStatus.absent)
        .length;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Attendance Report',
        showBackButton: false,
        actions: [
          IconButton(
            icon: Icon(
              Icons.calendar_today_outlined,
              color: isDarkMode
                  ? AppThemes.darkTextPrimary
                  : theme.iconTheme.color,
            ),
            onPressed: _selectDate,
          ),
          IconButton(
            icon: Icon(
              Icons.download_rounded,
              color: isDarkMode
                  ? AppThemes.darkTextPrimary
                  : theme.iconTheme.color,
            ),
            onPressed: _exportReport,
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Summary Cards - Modern Style
                Row(
                  children: [
                    Expanded(
                      child: _buildSimpleSummaryCard(
                        'Present',
                        presentCount.toString(),
                        AppThemes.successColor,
                        Icons.check_circle_rounded,
                        isDarkMode,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSimpleSummaryCard(
                        'Late',
                        lateCount.toString(),
                        AppThemes.warningColor,
                        Icons.schedule_rounded,
                        isDarkMode,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSimpleSummaryCard(
                        'Absent',
                        absentCount.toString(),
                        AppThemes.errorColor,
                        Icons.cancel_rounded,
                        isDarkMode,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Date Filter - Modern Style
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? AppThemes.darkSurface
                        : AppThemes.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDarkMode
                          ? AppThemes.darkOutline
                          : Colors.grey.withOpacity(0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(
                          isDarkMode ? 0.2 : 0.05,
                        ),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              (isDarkMode
                                      ? AppThemes.darkAccentBlue
                                      : AppThemes.primaryColor)
                                  .withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.calendar_today_outlined,
                          size: 20,
                          color: isDarkMode
                              ? AppThemes.darkAccentBlue
                              : AppThemes.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selected Date',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDarkMode
                                    ? AppThemes.darkTextSecondary
                                    : theme.hintColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatDate(_selectedDate),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDarkMode
                                    ? AppThemes.darkTextPrimary
                                    : theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.arrow_drop_down_rounded,
                          color: isDarkMode
                              ? AppThemes.darkTextPrimary
                              : theme.iconTheme.color,
                          size: 24,
                        ),
                        onPressed: _selectDate,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Attendance List Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Attendance History',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDarkMode
                              ? AppThemes.darkTextPrimary
                              : theme.textTheme.titleLarge?.color,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (isDarkMode
                                      ? AppThemes.darkAccentBlue
                                      : AppThemes.primaryColor)
                                  .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_attendanceRecords.length} Records',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDarkMode
                                ? AppThemes.darkAccentBlue
                                : AppThemes.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Attendance List - Modern Cards
                ..._attendanceRecords.map(
                  (record) => _buildModernAttendanceItem(record, isDarkMode),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingBottomNav(
              currentRoute: RouteNames.report,
              onQRScanTap: () {
                NavigationHelper.navigateWithoutAnimation(
                  context,
                  RouteNames.qrScan,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleSummaryCard(
    String title,
    String value,
    Color color,
    IconData icon,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? color.withOpacity(0.15) : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDarkMode
                  ? AppThemes.darkTextSecondary
                  : AppThemes.hintColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernAttendanceItem(AttendanceRecord record, bool isDarkMode) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? AppThemes.darkSurface : AppThemes.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode
              ? AppThemes.darkOutline
              : Colors.grey.withOpacity(0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Date Circle
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color:
                  (isDarkMode
                          ? AppThemes.darkAccentBlue
                          : AppThemes.primaryColor)
                      .withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  record.date.day.toString(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDarkMode
                        ? AppThemes.darkAccentBlue
                        : AppThemes.primaryColor,
                  ),
                ),
                Text(
                  _getMonthAbbreviation(record.date.month),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDarkMode
                        ? AppThemes.darkAccentBlue
                        : AppThemes.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Attendance Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _getDayName(record.date.weekday),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDarkMode
                            ? AppThemes.darkTextSecondary
                            : theme.hintColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    _buildModernStatusChip(record.status, isDarkMode),
                  ],
                ),
                const SizedBox(height: 8),
                if (record.checkIn != null)
                  _buildTimeRow(
                    Icons.login_rounded,
                    'Clock In: ${_formatTime(record.checkIn!)}',
                    record.status == AttendanceStatus.late
                        ? AppThemes.warningColor
                        : AppThemes.successColor,
                    isDarkMode,
                  ),
                if (record.checkOut != null)
                  _buildTimeRow(
                    Icons.logout_rounded,
                    'Clock Out: ${_formatTime(record.checkOut!)}',
                    AppThemes.infoColor,
                    isDarkMode,
                  ),
                if (record.checkIn == null && record.checkOut == null)
                  _buildTimeRow(
                    Icons.close_rounded,
                    'No attendance record',
                    AppThemes.errorColor,
                    isDarkMode,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRow(
    IconData icon,
    String text,
    Color color,
    bool isDarkMode,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDarkMode
                  ? AppThemes.darkTextSecondary
                  : theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernStatusChip(AttendanceStatus status, bool isDarkMode) {
    final Map<AttendanceStatus, Map<String, dynamic>> statusData = {
      AttendanceStatus.present: {
        'label': 'Present',
        'color': AppThemes.successColor,
        'lightColor': AppThemes.successLight,
      },
      AttendanceStatus.late: {
        'label': 'Late',
        'color': AppThemes.warningColor,
        'lightColor': AppThemes.warningLight,
      },
      AttendanceStatus.absent: {
        'label': 'Absent',
        'color': AppThemes.errorColor,
        'lightColor': AppThemes.errorLight,
      },
      AttendanceStatus.halfDay: {
        'label': 'Half Day',
        'color': AppThemes.infoColor,
        'lightColor': AppThemes.infoLight,
      },
    };

    final data = statusData[status]!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDarkMode ? data['color'].withOpacity(0.2) : data['lightColor'],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: data['color'].withOpacity(0.3), width: 1),
      ),
      child: Text(
        data['label'],
        style: TextStyle(
          color: data['color'],
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _getMonthAbbreviation(int month) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return months[month - 1];
  }

  String _getDayName(int weekday) {
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return days[weekday - 1];
  }

  String _formatDate(DateTime date) {
    return '${_getDayName(date.weekday)}, ${date.day} ${_getMonthAbbreviation(date.month)} ${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2025),
      builder: (context, child) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: isDark
                  ? AppThemes.darkAccentBlue
                  : AppThemes.primaryColor,
              onPrimary: Colors.white,
              surface: isDark ? AppThemes.darkSurface : theme.cardColor,
              onSurface: isDark
                  ? AppThemes.darkTextPrimary
                  : theme.textTheme.bodyLarge?.color ?? Colors.black,
            ),
            dialogBackgroundColor: isDark
                ? AppThemes.darkSurface
                : theme.cardColor,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _exportReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Report exported successfully!'),
        backgroundColor: AppThemes.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
