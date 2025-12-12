import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../models/enum/attendance_record.dart';
import '../../models/enum/attendance_status.dart';
import '../../navigation/route_names.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/attendance_service.dart';
import '../../services/storage_service.dart';
import '../../themes/app_themes.dart';
import '../../utils/constants.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/ui_utils.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/floating_bottom_nav.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  DateTime _selectedMonth = DateTime.now();
  
  // State to hold the data for the UI
  List<AttendanceRecord> _attendanceRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Method to fetch data from service and map it to UI model
  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // 1. Calculate Start and End Date for the selected month
    final start = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final end = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0, 23, 59, 59);

    try {
      // 2. Get current user's pesertaMagangId from auth provider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;

      if (user == null) {
        _showError('User data not found. Please login again.');
        return;
      }

      // Get pesertaMagangId from multiple sources
      String? pesertaMagangId;
      
      try {
        // Method 1: Try from stored user data (pesertaMagang.id)
        final userDataStr = await StorageService.getString(AppConstants.userDataKey);
        if (userDataStr != null) {
          final userData = jsonDecode(userDataStr);
          pesertaMagangId = userData['pesertaMagang']?['id']?.toString();
          if (kDebugMode && pesertaMagangId != null) {
            debugPrint('✅ Got pesertaMagangId from stored data: $pesertaMagangId');
          }
        }
        
        // Method 2: If not found, refresh profile from API (most reliable)
        if ((pesertaMagangId == null || pesertaMagangId.isEmpty) && mounted) {
          if (kDebugMode) {
            debugPrint('🔄 Refreshing profile to get pesertaMagangId...');
          }
          await authProvider.refreshProfile();
          final refreshedUserDataStr = await StorageService.getString(AppConstants.userDataKey);
          if (refreshedUserDataStr != null) {
            final refreshedUserData = jsonDecode(refreshedUserDataStr);
            pesertaMagangId = refreshedUserData['pesertaMagang']?['id']?.toString();
            if (kDebugMode && pesertaMagangId != null) {
              debugPrint('✅ Got pesertaMagangId from refreshed profile: $pesertaMagangId');
            }
          }
        }
        
        // Method 3: If still not found, try to get from API using userId endpoint
        if ((pesertaMagangId == null || pesertaMagangId.isEmpty) && user.id.isNotEmpty) {
          try {
            if (kDebugMode) {
              debugPrint('🔄 Trying to get pesertaMagangId from API endpoint...');
            }
            final token = await StorageService.getString(AppConstants.tokenKey);
            if (token != null) {
              final headers = {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              };
              
              final response = await http.get(
                Uri.parse('${AppConstants.baseUrl}/peserta-magang/user/${user.id}'),
                headers: headers,
              ).timeout(const Duration(seconds: 10));
              
              if (response.statusCode == 200) {
                final responseData = jsonDecode(response.body);
                if (responseData['success'] == true && responseData['data'] != null) {
                  pesertaMagangId = responseData['data']['id']?.toString();
                  if (kDebugMode && pesertaMagangId != null) {
                    debugPrint('✅ Got pesertaMagangId from API endpoint: $pesertaMagangId');
                  }
                }
              } else if (kDebugMode) {
                debugPrint('⚠️ API returned status ${response.statusCode}: ${response.body}');
              }
            }
          } catch (apiError) {
            if (kDebugMode) {
              debugPrint('⚠️ Error fetching pesertaMagangId from API: $apiError');
            }
          }
        }
        
        // Method 4: Last resort - try to get from first attendance record
        if ((pesertaMagangId == null || pesertaMagangId.isEmpty)) {
          if (kDebugMode) {
            debugPrint('🔄 Trying to get pesertaMagangId from attendance records...');
          }
          final tempResponse = await AttendanceService.getAllAttendance(
            limit: 1,
          );
          
          if (tempResponse.success && 
              tempResponse.data != null && 
              tempResponse.data!.isNotEmpty) {
            pesertaMagangId = tempResponse.data!.first.pesertaMagangId;
            if (kDebugMode && pesertaMagangId != null) {
              debugPrint('✅ Got pesertaMagangId from attendance: $pesertaMagangId');
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Error getting pesertaMagangId: $e');
        }
      }

      if (pesertaMagangId == null || pesertaMagangId.isEmpty) {
        if (mounted) {
          _showError('Peserta magang ID not found. Please ensure you are logged in as a student and have completed registration. If the issue persists, please contact support.');
          if (kDebugMode) {
            debugPrint('❌ Final check: pesertaMagangId is still null or empty');
            debugPrint('User ID: ${user.id}');
            debugPrint('User Role: ${user.role}');
          }
        }
        return;
      }

      // 3. Fetch all attendance records for the user
      final response = await AttendanceService.getAllAttendance(
        pesertaMagangId: pesertaMagangId,
        limit: 500, // Fetch enough records to cover the month
      );

      if (response.success && response.data != null) {
        // 4. Filter by date range (client-side since backend doesn't support it)
        final filteredData = response.data!.where((item) {
          final itemDate = item.timestamp;
          return itemDate.isAfter(start.subtract(const Duration(days: 1))) &&
                 itemDate.isBefore(end.add(const Duration(days: 1)));
        }).toList();

        // 5. Group attendance by date and combine MASUK/KELUAR
        final Map<String, AttendanceRecord> recordsByDate = {};

        for (final item in filteredData) {
          final dateKey = '${item.timestamp.year}-${item.timestamp.month.toString().padLeft(2, '0')}-${item.timestamp.day.toString().padLeft(2, '0')}';
          
          if (!recordsByDate.containsKey(dateKey)) {
            // Create new record for this date
            final dateOnly = DateTime(item.timestamp.year, item.timestamp.month, item.timestamp.day);
            recordsByDate[dateKey] = AttendanceRecord(
              id: item.id,
              userId: user?.id ?? '',
              pesertaMagangId: item.pesertaMagangId,
              tipe: item.tipe,
              date: dateOnly,
              timestamp: item.timestamp,
              checkIn: null,
              checkOut: null,
              status: _mapStatus(item.status),
              catatan: item.catatan,
              lokasi: item.lokasi,
              selfieUrl: item.selfieUrl,
              qrCodeData: item.qrCodeData,
              ipAddress: item.ipAddress,
              device: item.device,
              createdAt: item.createdAt,
              updatedAt: item.updatedAt,
              pesertaMagang: item.pesertaMagang,
            );
          }

          final record = recordsByDate[dateKey]!;
          
          // Set check-in or check-out based on tipe
          if (item.tipe.toUpperCase() == 'MASUK') {
            recordsByDate[dateKey] = AttendanceRecord(
              id: record.id,
              userId: record.userId,
              pesertaMagangId: record.pesertaMagangId,
              tipe: record.tipe,
              date: record.date,
              timestamp: record.timestamp,
              checkIn: item.timestamp,
              checkOut: record.checkOut,
              status: _mapStatus(item.status), // Use status from MASUK record
              catatan: record.catatan,
              lokasi: record.lokasi,
              selfieUrl: record.selfieUrl,
              qrCodeData: record.qrCodeData,
              ipAddress: record.ipAddress,
              device: record.device,
              createdAt: record.createdAt,
              updatedAt: record.updatedAt,
              pesertaMagang: record.pesertaMagang,
            );
          } else if (item.tipe.toUpperCase() == 'KELUAR') {
            recordsByDate[dateKey] = AttendanceRecord(
              id: record.id,
              userId: record.userId,
              pesertaMagangId: record.pesertaMagangId,
              tipe: record.tipe,
              date: record.date,
              timestamp: record.timestamp,
              checkIn: record.checkIn,
              checkOut: item.timestamp,
              status: record.status, // Keep status from MASUK
              catatan: record.catatan,
              lokasi: record.lokasi,
              selfieUrl: record.selfieUrl,
              qrCodeData: record.qrCodeData,
              ipAddress: record.ipAddress,
              device: record.device,
              createdAt: record.createdAt,
              updatedAt: record.updatedAt,
              pesertaMagang: record.pesertaMagang,
            );
          }
        }

        // 6. Convert map to sorted list
        final mappedRecords = recordsByDate.values.toList()
          ..sort((a, b) => b.date.compareTo(a.date));

        setState(() {
          _attendanceRecords = mappedRecords;
        });
      } else {
        _showError(response.message ?? 'Failed to load data');
      }
    } catch (e) {
      _showError('Error loading attendance: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  AttendanceStatus _mapStatus(String status) {
    final upperStatus = status.toUpperCase();
    switch (upperStatus) {
      case 'VALID':
        return AttendanceStatus.valid;
      case 'TERLAMBAT':
        return AttendanceStatus.terlambat;
      case 'INVALID':
        return AttendanceStatus.invalid;
      default:
        return AttendanceStatus.pending;
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppThemes.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }
  
  
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
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                color: isDarkMode
                    ? AppThemes.darkAccentBlue
                    : AppThemes.primaryColor,
              ),
            )
          else
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                // Summary Cards - Modern Style
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
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatMonth(_selectedMonth),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDarkMode
                                    ? AppThemes.darkTextPrimary
                                    : theme.textTheme.bodyMedium?.color,
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
    final DateTime now = DateTime.now();
    final DateTime maxDate = DateTime(now.year + 1, 12, 31);
    final DateTime minDate = DateTime(2023, 1, 1);
    
    // Ensure initialDate is within valid range
    DateTime initialDate = _selectedMonth;
    if (initialDate.isAfter(maxDate)) {
      initialDate = maxDate;
    } else if (initialDate.isBefore(minDate)) {
      initialDate = minDate;
    }
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: minDate,
      lastDate: maxDate, // Allow up to next year
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
    if (picked != null) {
      final newMonth = DateTime(picked.year, picked.month);
      if (newMonth.year != _selectedMonth.year || 
          newMonth.month != _selectedMonth.month) {
        setState(() {
          _selectedMonth = newMonth;
        });
        _loadData(); // Reload data for the new month
      }
    }
  }

  String _formatMonth(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  void _exportReport() {
    // Simulasi export report
    // NOTIFIKASI BARU: SUKSES
    GlobalSnackBar.show(
      'Laporan berhasil diexport ke PDF',
      title: 'Export Berhasil',
      isSuccess: true,
    );
  }
}
