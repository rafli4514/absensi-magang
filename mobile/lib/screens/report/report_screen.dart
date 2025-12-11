import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/enum/attendance_record.dart';
import '../../models/enum/attendance_status.dart';
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

  // Dummy Data
  final List<AttendanceRecord> _attendanceRecords = [
    AttendanceRecord(
      id: '1',
      userId: '1',
      pesertaMagangId: '1',
      tipe: 'CHECK_IN',
      date: DateTime(2024, 1, 15),
      timestamp: DateTime(2024, 1, 15, 8, 30),
      checkIn: DateTime(2024, 1, 15, 8, 30),
      checkOut: DateTime(2024, 1, 15, 17, 15),
      status: AttendanceStatus.valid,
      createdAt: DateTime(2024, 1, 15),
      updatedAt: DateTime(2024, 1, 15),
    ),
    AttendanceRecord(
      id: '2',
      userId: '1',
      pesertaMagangId: '1',
      tipe: 'CHECK_IN',
      date: DateTime(2024, 1, 14),
      timestamp: DateTime(2024, 1, 14, 9, 15),
      checkIn: DateTime(2024, 1, 14, 9, 15),
      checkOut: DateTime(2024, 1, 14, 17, 0),
      status: AttendanceStatus.terlambat,
      createdAt: DateTime(2024, 1, 14),
      updatedAt: DateTime(2024, 1, 14),
    ),
    AttendanceRecord(
      id: '3',
      userId: '1',
      pesertaMagangId: '1',
      tipe: 'CHECK_IN',
      date: DateTime(2024, 1, 13),
      timestamp: DateTime(2024, 1, 13, 8, 45),
      checkIn: DateTime(2024, 1, 13, 8, 45),
      checkOut: DateTime(2024, 1, 13, 16, 45),
      status: AttendanceStatus.valid,
      createdAt: DateTime(2024, 1, 13),
      updatedAt: DateTime(2024, 1, 13),
    ),
    AttendanceRecord(
      id: '4',
      userId: '1',
      pesertaMagangId: '1',
      tipe: 'CHECK_IN',
      date: DateTime(2024, 1, 12),
      timestamp: DateTime(2024, 1, 12),
      checkIn: null,
      checkOut: null,
      status: AttendanceStatus.invalid,
      createdAt: DateTime(2024, 1, 12),
      updatedAt: DateTime(2024, 1, 12),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // Definisikan warna primary yang konsisten
    final primaryColor =
        isDark ? AppThemes.darkAccentBlue : AppThemes.primaryColor;
    final onSurfaceColor =
        isDark ? AppThemes.darkTextPrimary : AppThemes.onSurfaceColor;
    final hintColor =
        isDark ? AppThemes.darkTextSecondary : AppThemes.hintColor;

    final validCount = _attendanceRecords
        .where((r) => r.status == AttendanceStatus.valid)
        .length;
    final terlambatCount = _attendanceRecords
        .where((r) => r.status == AttendanceStatus.terlambat)
        .length;
    final invalidCount = _attendanceRecords
        .where((r) => r.status == AttendanceStatus.invalid)
        .length;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Attendance Report',
        showBackButton: false,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 1. Summary Cards Section
                Row(
                  children: [
                    Expanded(
                      child: _buildSimpleSummaryCard(
                        'Valid',
                        validCount.toString(),
                        AppThemes.successColor,
                        Icons.check_circle_rounded,
                        isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSimpleSummaryCard(
                        'Terlambat',
                        terlambatCount.toString(),
                        AppThemes.warningColor,
                        Icons.schedule_rounded,
                        isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSimpleSummaryCard(
                        'Invalid',
                        invalidCount.toString(),
                        AppThemes.errorColor,
                        Icons.cancel_rounded,
                        isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 2. Filter & Action Section (PROFESIONAL CONTROL PANEL)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color:
                        isDark ? AppThemes.darkSurface : AppThemes.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? AppThemes.darkOutline
                          : Colors.grey.withOpacity(0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(
                          isDark ? 0.2 : 0.05,
                        ),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Icon Calendar Stylish
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.calendar_month_rounded,
                          size: 20,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Date Selector (Clickable Area)
                      Expanded(
                        child: InkWell(
                          onTap: _selectDate,
                          borderRadius: BorderRadius.circular(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Selected Period',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: hintColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Text(
                                    _formatDate(_selectedDate),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: onSurfaceColor,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 18,
                                    color: primaryColor,
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Divider Vertical
                      Container(
                        height: 32,
                        width: 1,
                        color: isDark
                            ? AppThemes.darkOutline
                            : Colors.grey.shade300,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                      ),

                      // Download Button (Warna sudah diperbaiki)
                      IconButton(
                        icon: Icon(
                          Icons.download_rounded,
                          color: primaryColor, // Menggunakan warna Primary
                        ),
                        tooltip: 'Download Report',
                        onPressed: _exportReport,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // 3. List Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Attendance History',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: onSurfaceColor,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_attendanceRecords.length} Records',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Attendance List Cards
                ..._attendanceRecords.map(
                  (record) => _buildModernAttendanceItem(record, isDark),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),

          // Floating Nav
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

  // --- HELPER WIDGETS ---

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
    final primaryColor =
        isDarkMode ? AppThemes.darkAccentBlue : AppThemes.primaryColor;

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
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  record.date.day.toString(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
                Text(
                  _getMonthAbbreviation(record.date.month),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: primaryColor,
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
                            : AppThemes.hintColor,
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
                    record.status == AttendanceStatus.terlambat
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
      AttendanceStatus.valid: {
        'label': 'Valid',
        'color': AppThemes.successColor,
        'lightColor': AppThemes.successLight,
      },
      AttendanceStatus.terlambat: {
        'label': 'Terlambat',
        'color': AppThemes.warningColor,
        'lightColor': AppThemes.warningLight,
      },
      AttendanceStatus.invalid: {
        'label': 'Invalid',
        'color': AppThemes.errorColor,
        'lightColor': AppThemes.errorLight,
      },
      AttendanceStatus.pending: {
        'label': 'Pending',
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
      'DEC'
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
              primary:
                  isDark ? AppThemes.darkAccentBlue : AppThemes.primaryColor,
              onPrimary: Colors.white,
              surface: isDark ? AppThemes.darkSurface : theme.cardColor,
              onSurface: isDark
                  ? AppThemes.darkTextPrimary
                  : theme.textTheme.bodyLarge?.color ?? Colors.black,
            ),
            dialogBackgroundColor:
                isDark ? AppThemes.darkSurface : theme.cardColor,
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
    final isDark =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor:
            isDark ? AppThemes.darkSurfaceElevated : AppThemes.surfaceColor,
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppThemes.successColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppThemes.successColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Report exported successfully!',
                style: TextStyle(
                  color: isDark
                      ? AppThemes.darkTextPrimary
                      : AppThemes.onSurfaceColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: AppThemes.successColor,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
