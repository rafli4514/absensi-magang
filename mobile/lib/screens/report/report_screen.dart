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
  List<AttendanceRecord> _attendanceRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final start = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final end =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0, 23, 59, 59);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;

      if (user == null) {
        _showError('Data user tidak ditemukan. Silakan login ulang.');
        return;
      }

      String? pesertaMagangId;
      try {
        final userDataStr =
            await StorageService.getString(AppConstants.userDataKey);
        if (userDataStr != null) {
          final userData = jsonDecode(userDataStr);
          pesertaMagangId = userData['pesertaMagang']?['id']?.toString();
        }

        if ((pesertaMagangId == null || pesertaMagangId.isEmpty) && mounted) {
          await authProvider.refreshProfile();
          final refreshedUserDataStr =
              await StorageService.getString(AppConstants.userDataKey);
          if (refreshedUserDataStr != null) {
            final refreshedUserData = jsonDecode(refreshedUserDataStr);
            pesertaMagangId =
                refreshedUserData['pesertaMagang']?['id']?.toString();
          }
        }

        if ((pesertaMagangId == null || pesertaMagangId.isEmpty) &&
            user.id.isNotEmpty) {
          try {
            final token = await StorageService.getString(AppConstants.tokenKey);
            if (token != null) {
              final headers = {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              };

              final response = await http
                  .get(
                    Uri.parse(
                        '${AppConstants.baseUrl}/peserta-magang/user/${user.id}'),
                    headers: headers,
                  )
                  .timeout(const Duration(seconds: 10));

              if (response.statusCode == 200) {
                final responseData = jsonDecode(response.body);
                if (responseData['success'] == true &&
                    responseData['data'] != null) {
                  pesertaMagangId = responseData['data']['id']?.toString();
                }
              }
            }
          } catch (_) {}
        }
      } catch (e) {
        if (kDebugMode) print('Error getting pesertaMagangId: $e');
      }

      if (pesertaMagangId == null || pesertaMagangId.isEmpty) {
        if (mounted) {
          _showError(
              'ID Peserta Magang tidak ditemukan. Pastikan Anda terdaftar sebagai peserta magang.');
        }
        return;
      }

      final response = await AttendanceService.getAllAttendance(
        pesertaMagangId: pesertaMagangId,
        limit: 500,
      );

      if (response.success && response.data != null) {
        final filteredData = response.data!.where((item) {
          final itemDate = item.timestamp;
          return itemDate.isAfter(start.subtract(const Duration(days: 1))) &&
              itemDate.isBefore(end.add(const Duration(days: 1)));
        }).toList();

        final Map<String, AttendanceRecord> recordsByDate = {};

        for (final item in filteredData) {
          final dateKey =
              '${item.timestamp.year}-${item.timestamp.month.toString().padLeft(2, '0')}-${item.timestamp.day.toString().padLeft(2, '0')}';

          if (!recordsByDate.containsKey(dateKey)) {
            final dateOnly = DateTime(
                item.timestamp.year, item.timestamp.month, item.timestamp.day);
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
              status: _mapStatus(item.status),
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
              status: record.status,
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

        final mappedRecords = recordsByDate.values.toList()
          ..sort((a, b) => b.date.compareTo(a.date));

        setState(() {
          _attendanceRecords = mappedRecords;
        });
      } else {
        _showError(response.message ?? 'Gagal memuat data');
      }
    } catch (e) {
      _showError('Terjadi kesalahan: ${e.toString()}');
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
      GlobalSnackBar.show(
        message,
        title: 'Gagal Memuat',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final isDarkMode = isDark;

    final primaryColor =
        isDark ? AppThemes.darkAccentBlue : AppThemes.primaryColor;

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
        title: 'Laporan Absensi', // Translate
        showBackButton: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: isDarkMode
                            ? AppThemes.darkAccentBlue
                            : AppThemes.primaryColor,
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildSimpleSummaryCard(
                                  'Hadir', // Translate
                                  validCount.toString(),
                                  AppThemes.successColor,
                                  Icons.check_circle_rounded,
                                  isDarkMode,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSimpleSummaryCard(
                                  'Terlambat', // Translate
                                  terlambatCount.toString(),
                                  AppThemes.warningColor,
                                  Icons.schedule_rounded,
                                  isDarkMode,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSimpleSummaryCard(
                                  'Invalid', // Translate
                                  invalidCount.toString(),
                                  AppThemes.errorColor,
                                  Icons.cancel_rounded,
                                  isDarkMode,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Date Filter
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
                                    color: (isDarkMode
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Pilih Tanggal', // Translate
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: isDarkMode
                                              ? AppThemes.darkTextSecondary
                                              : theme.hintColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _formatMonth(_selectedMonth),
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: isDarkMode
                                              ? AppThemes.darkTextPrimary
                                              : theme
                                                  .textTheme.bodyMedium?.color,
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
                                  'Riwayat Absensi', // Translate
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
                                    color: (isDarkMode
                                            ? AppThemes.darkAccentBlue
                                            : AppThemes.primaryColor)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${_attendanceRecords.length} Data', // Translate
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

                          if (_attendanceRecords.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.history_toggle_off_rounded,
                                    size: 48,
                                    color: isDarkMode
                                        ? AppThemes.darkTextSecondary
                                            .withOpacity(0.5)
                                        : AppThemes.hintColor.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Tidak ada riwayat absensi',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: isDarkMode
                                          ? AppThemes.darkTextSecondary
                                          : AppThemes.hintColor,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ..._attendanceRecords.map(
                              (record) => _buildModernAttendanceItem(
                                  record, isDarkMode),
                            ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
            ),
            FloatingBottomNav(
              currentRoute: RouteNames.report,
              onQRScanTap: () {
                NavigationHelper.navigateWithoutAnimation(
                  context,
                  RouteNames.qrScan,
                );
              },
            ),
          ],
        ),
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
                    'Masuk: ${_formatTime(record.checkIn!)}', // Translate
                    record.status == AttendanceStatus.terlambat
                        ? AppThemes.warningColor
                        : AppThemes.successColor,
                    isDarkMode,
                  ),
                if (record.checkOut != null)
                  _buildTimeRow(
                    Icons.logout_rounded,
                    'Keluar: ${_formatTime(record.checkOut!)}', // Translate
                    AppThemes.infoColor,
                    isDarkMode,
                  ),
                if (record.checkIn == null && record.checkOut == null)
                  _buildTimeRow(
                    Icons.close_rounded,
                    'Tidak ada catatan', // Translate
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
        'label': 'Proses',
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
      'MEI', // Translate
      'JUN',
      'JUL',
      'AGU', // Translate
      'SEP',
      'OKT', // Translate
      'NOV',
      'DES' // Translate
    ];
    return months[month - 1];
  }

  String _getDayName(int weekday) {
    const days = ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN']; // Translate
    return days[weekday - 1];
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectDate() async {
    final DateTime now = DateTime.now();
    final DateTime maxDate = DateTime(now.year + 1, 12, 31);
    final DateTime minDate = DateTime(2023, 1, 1);

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
      lastDate: maxDate,
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
        _loadData();
      }
    }
  }

  String _formatMonth(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
