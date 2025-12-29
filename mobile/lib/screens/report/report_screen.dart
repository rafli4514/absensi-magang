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

        // Fallback fetch manual jika storage kosong
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
          _showError('ID Peserta Magang tidak ditemukan.');
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
            recordsByDate[dateKey] = record.copyWith(
              checkIn: item.timestamp,
              status: _mapStatus(item.status),
            );
          } else if (item.tipe.toUpperCase() == 'KELUAR') {
            recordsByDate[dateKey] = record.copyWith(
              checkOut: item.timestamp,
            );
          } else {
            recordsByDate[dateKey] = record.copyWith(
              status: _mapStatus(item.status),
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
      case 'SAKIT':
        return AttendanceStatus.sakit;
      case 'IZIN':
        return AttendanceStatus.izin;
      case 'ALPHA':
      case 'ABSENT':
      case 'TANPA KETERANGAN':
        return AttendanceStatus.alpha;
      default:
        return AttendanceStatus.pending;
    }
  }

  void _showError(String message) {
    if (mounted) {
      GlobalSnackBar.show(message, title: 'Gagal Memuat', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final validCount = _attendanceRecords
        .where((r) => r.status == AttendanceStatus.valid)
        .length;
    final terlambatCount = _attendanceRecords
        .where((r) => r.status == AttendanceStatus.terlambat)
        .length;
    final sakitCount = _attendanceRecords
        .where((r) => r.status == AttendanceStatus.sakit)
        .length;
    final izinCount = _attendanceRecords
        .where((r) => r.status == AttendanceStatus.izin)
        .length;
    final alphaCount = _attendanceRecords
        .where((r) => r.status == AttendanceStatus.alpha)
        .length;
    final invalidCount = _attendanceRecords
        .where((r) => r.status == AttendanceStatus.invalid)
        .length;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Laporan Absensi',
        showBackButton: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: isDark
                            ? AppThemes.darkAccentBlue
                            : AppThemes.primaryColor,
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final itemWidth = (constraints.maxWidth - 24) / 3;
                              return Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  _buildSummaryItem(
                                      'Hadir',
                                      validCount.toString(),
                                      AppThemes.successColor,
                                      Icons.check_circle_rounded,
                                      isDark,
                                      itemWidth),
                                  _buildSummaryItem(
                                      'Terlambat',
                                      terlambatCount.toString(),
                                      AppThemes.warningColor,
                                      Icons.schedule_rounded,
                                      isDark,
                                      itemWidth),
                                  _buildSummaryItem(
                                      'Sakit',
                                      sakitCount.toString(),
                                      AppThemes.infoColor,
                                      Icons.medical_services_rounded,
                                      isDark,
                                      itemWidth),
                                  _buildSummaryItem(
                                      'Izin',
                                      izinCount.toString(),
                                      Colors.orange,
                                      Icons.assignment_turned_in_rounded,
                                      isDark,
                                      itemWidth),
                                  _buildSummaryItem(
                                      'Tanpa Ket.',
                                      alphaCount.toString(),
                                      AppThemes.errorColor,
                                      Icons.person_off_rounded,
                                      isDark,
                                      itemWidth),
                                  _buildSummaryItem(
                                      'Invalid',
                                      invalidCount.toString(),
                                      Colors.grey,
                                      Icons.cancel_rounded,
                                      isDark,
                                      itemWidth),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 24),

                          // Date Filter
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppThemes.darkSurface
                                  : AppThemes.surfaceColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark
                                    ? AppThemes.darkOutline
                                    : Colors.grey.withOpacity(0.2),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(isDark ? 0.2 : 0.05),
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
                                    color: (isDark
                                            ? AppThemes.darkAccentBlue
                                            : AppThemes.primaryColor)
                                        .withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.calendar_today_outlined,
                                    size: 20,
                                    color: isDark
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
                                        'Pilih Tanggal',
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: isDark
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
                                          color: isDark
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
                                    color: isDark
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
                                  'Riwayat Absensi',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppThemes.darkTextPrimary
                                        : theme.textTheme.titleLarge?.color,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: (isDark
                                            ? AppThemes.darkAccentBlue
                                            : AppThemes.primaryColor)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${_attendanceRecords.length} Data',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: isDark
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
                                    color: isDark
                                        ? AppThemes.darkTextSecondary
                                            .withOpacity(0.5)
                                        : AppThemes.hintColor.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Tidak ada riwayat absensi',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: isDark
                                          ? AppThemes.darkTextSecondary
                                          : AppThemes.hintColor,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ..._attendanceRecords.map(
                              (record) =>
                                  _buildModernAttendanceItem(record, isDark),
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
                    context, RouteNames.qrScan);
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildSummaryItem(
    String title,
    String value,
    Color color,
    IconData icon,
    bool isDarkMode,
    double width,
  ) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? color.withOpacity(0.15) : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDarkMode
                  ? AppThemes.darkTextSecondary
                  : AppThemes.hintColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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

                // Logic Perbaikan Error: Cek Null sebelum akses .isNotEmpty
                if (record.status == AttendanceStatus.sakit ||
                    record.status == AttendanceStatus.izin ||
                    record.status == AttendanceStatus.alpha)
                  _buildTimeRow(
                    Icons.info_outline_rounded,
                    (record.catatan != null && record.catatan!.isNotEmpty)
                        ? record.catatan!
                        : 'Tidak ada keterangan', // <--- FIX ERROR DI SINI
                    isDarkMode ? AppThemes.darkTextPrimary : Colors.black87,
                    isDarkMode,
                  )
                else ...[
                  if (record.checkIn != null)
                    _buildTimeRow(
                      Icons.login_rounded,
                      'Masuk: ${_formatTime(record.checkIn!)}',
                      record.status == AttendanceStatus.terlambat
                          ? AppThemes.warningColor
                          : AppThemes.successColor,
                      isDarkMode,
                    ),
                  if (record.checkOut != null)
                    _buildTimeRow(
                      Icons.logout_rounded,
                      'Keluar: ${_formatTime(record.checkOut!)}',
                      AppThemes.infoColor,
                      isDarkMode,
                    ),
                  if (record.checkIn == null && record.checkOut == null)
                    _buildTimeRow(
                      Icons.close_rounded,
                      'Belum Absen',
                      AppThemes.errorColor,
                      isDarkMode,
                    ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRow(
      IconData icon, String text, Color color, bool isDarkMode) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDarkMode
                    ? AppThemes.darkTextSecondary
                    : theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernStatusChip(AttendanceStatus status, bool isDarkMode) {
    final Map<AttendanceStatus, Map<String, dynamic>> statusData = {
      AttendanceStatus.valid: {
        'label': 'Hadir',
        'color': AppThemes.successColor,
        'lightColor': AppThemes.successLight,
      },
      AttendanceStatus.terlambat: {
        'label': 'Terlambat',
        'color': AppThemes.warningColor,
        'lightColor': AppThemes.warningLight,
      },
      AttendanceStatus.sakit: {
        'label': 'Sakit',
        'color': AppThemes.infoColor,
        'lightColor': AppThemes.infoLight,
      },
      AttendanceStatus.izin: {
        'label': 'Izin',
        'color': Colors.orange,
        'lightColor': Colors.orange.shade100,
      },
      AttendanceStatus.alpha: {
        'label': 'Alpha',
        'color': AppThemes.errorColor,
        'lightColor': AppThemes.errorLight,
      },
      AttendanceStatus.invalid: {
        'label': 'Invalid',
        'color': Colors.grey,
        'lightColor': Colors.grey.shade200,
      },
      AttendanceStatus.pending: {
        'label': 'Proses',
        'color': Colors.blueGrey,
        'lightColor': Colors.blueGrey.shade100,
      },
    };

    final data = statusData[status] ?? statusData[AttendanceStatus.pending]!;

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
      'MEI',
      'JUN',
      'JUL',
      'AGU',
      'SEP',
      'OKT',
      'NOV',
      'DES'
    ];
    return months[month - 1];
  }

  String _getDayName(int weekday) {
    const days = ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'];
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
    if (initialDate.isAfter(maxDate)) initialDate = maxDate;
    if (initialDate.isBefore(minDate)) initialDate = minDate;

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
              onSurface: isDark ? AppThemes.darkTextPrimary : Colors.black,
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
      'Desember'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

// Extension sederhana untuk copyWith di AttendanceRecord agar coding lebih bersih
extension AttendanceRecordExtension on AttendanceRecord {
  AttendanceRecord copyWith({
    DateTime? checkIn,
    DateTime? checkOut,
    AttendanceStatus? status,
  }) {
    return AttendanceRecord(
      id: id,
      userId: userId,
      pesertaMagangId: pesertaMagangId,
      tipe: tipe,
      date: date,
      timestamp: timestamp,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      status: status ?? this.status,
      catatan: catatan,
      lokasi: lokasi,
      selfieUrl: selfieUrl,
      qrCodeData: qrCodeData,
      ipAddress: ipAddress,
      device: device,
      createdAt: createdAt,
      updatedAt: updatedAt,
      pesertaMagang: pesertaMagang,
    );
  }
}
