import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/performance_stats.dart';
import '../../navigation/route_names.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/attendance_service.dart';
import '../../services/dashboard_service.dart';
import '../../services/leave_service.dart';
import '../../services/location_service.dart';
import '../../services/permission_service.dart';
import '../../services/settings_service.dart';
import '../../services/storage_service.dart';
import '../../themes/app_themes.dart';
import '../../utils/constants.dart';
import '../../utils/indonesian_time.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/ui_utils.dart';
import '../../widgets/announcement_card.dart';
import '../../widgets/attendance_card.dart';
import '../../widgets/attendance_status_card.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/floating_bottom_nav.dart';
import '../../widgets/leave_form_dialog.dart';
import '../../widgets/performance_card.dart';
import '../../widgets/welcome_header_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PerformanceStats? _performanceStats;
  bool _isLoadingPerformance = false;

  // Variabel Jam Pulang
  String _workEndTime = "17:00";
  bool _canClockOut = false;
  Timer? _timer;

  // Variabel Status Izin Hari Ini
  String? _todayLeaveStatus; // 'IZIN', 'SAKIT', atau null

  @override
  void initState() {
    super.initState();
    _loadPerformanceData();
    _loadSettings();
    _checkTodayLeaveStatus(); // <--- CEK STATUS IZIN SAAT INIT

    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkClockOutTime();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final attendanceProvider =
            Provider.of<AttendanceProvider>(context, listen: false);

        if (authProvider.user != null) {
          attendanceProvider.refreshTodayAttendance(preserveLocalState: true);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // --- LOGIC 1: Ambil Peserta ID Helper ---
  Future<String?> _getPesertaId() async {
    try {
      final userDataStr =
          await StorageService.getString(AppConstants.userDataKey);
      if (userDataStr != null) {
        final userData = jsonDecode(userDataStr);
        return userData['pesertaMagang']?['id']?.toString();
      }
    } catch (_) {}
    return null;
  }

  // --- LOGIC 2: Cek Status Izin Hari Ini ---
  Future<void> _checkTodayLeaveStatus() async {
    try {
      final pesertaId = await _getPesertaId();
      if (pesertaId == null) return;

      // Ambil semua izin yang DISETUJUI milik user ini
      final response = await LeaveService.getLeaves(
          pesertaMagangId: pesertaId, status: 'DISETUJUI');

      if (response.success && response.data != null) {
        final now = DateTime.now();
        // Cek apakah hari ini (now) berada dalam rentang tanggalMulai - tanggalSelesai
        for (var leave in response.data!) {
          final start = DateTime.parse(leave['tanggalMulai']);
          final end = DateTime.parse(leave['tanggalSelesai']);

          // Normalisasi tanggal (abaikan jam) agar akurat
          final dateNow = DateTime(now.year, now.month, now.day);
          final dateStart = DateTime(start.year, start.month, start.day);
          final dateEnd = DateTime(end.year, end.month, end.day);

          if ((dateNow.isAtSameMomentAs(dateStart) ||
                  dateNow.isAfter(dateStart)) &&
              (dateNow.isAtSameMomentAs(dateEnd) ||
                  dateNow.isBefore(dateEnd))) {
            if (mounted) {
              setState(() {
                _todayLeaveStatus = leave['tipe']; // 'IZIN' atau 'SAKIT'
              });
            }
            break; // Ketemu satu sudah cukup
          }
        }
      }
    } catch (e) {
      if (kDebugMode) print("Error check leave status: $e");
    }
  }

  // --- LOGIC 3: Load Settings & Jam Pulang ---
  Future<void> _loadSettings() async {
    try {
      final response = await SettingsService.getSettings();
      if (response.success && response.data != null) {
        if (mounted) {
          setState(() {
            final schedule = response.data!['schedule'];
            if (schedule != null && schedule['workEndTime'] != null) {
              _workEndTime = schedule['workEndTime'];
            }
            _checkClockOutTime();
          });
        }
      }
    } catch (e) {
      if (kDebugMode) print("Gagal load settings: $e");
    }
  }

  void _checkClockOutTime() {
    final now = DateTime.now();
    final parts = _workEndTime.split(':');
    if (parts.length == 2) {
      final endHour = int.parse(parts[0]);
      final endMinute = int.parse(parts[1]);
      final endTime =
          DateTime(now.year, now.month, now.day, endHour, endMinute);

      final canOut = now.isAfter(endTime) || now.isAtSameMomentAs(endTime);

      if (mounted && _canClockOut != canOut) {
        setState(() {
          _canClockOut = canOut;
        });
      }
    }
  }

  // --- LOGIC 4: Load Performance ---
  Future<void> _loadPerformanceData() async {
    if (!mounted) return;
    setState(() => _isLoadingPerformance = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user == null) {
        setState(() => _isLoadingPerformance = false);
        return;
      }

      String? pesertaMagangId = await _getPesertaId();

      // Jika ID tidak ada, coba refresh profile
      if (pesertaMagangId == null) {
        await authProvider.refreshProfile();
        pesertaMagangId = await _getPesertaId();
      }

      if (pesertaMagangId != null) {
        final response = await DashboardService.getCurrentMonthPerformance(
          pesertaMagangId: pesertaMagangId,
        );

        if (mounted && response.success && response.data != null) {
          setState(() {
            _performanceStats = response.data;
            _isLoadingPerformance = false;
          });
        } else {
          if (mounted) {
            setState(() {
              _performanceStats = PerformanceStats.empty();
              _isLoadingPerformance = false;
            });
          }
        }
      } else {
        setState(() {
          _performanceStats = PerformanceStats.empty();
          _isLoadingPerformance = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _performanceStats = PerformanceStats.empty();
          _isLoadingPerformance = false;
        });
      }
    }
  }

  Future<void> _handleAttendanceResult(
      BuildContext context, dynamic result) async {
    if (result != null && result is Map<String, dynamic> && mounted) {
      final attendanceProvider =
          Provider.of<AttendanceProvider>(context, listen: false);
      final attendanceType = result['type'] as String? ?? '';
      final time = result['time'] as String? ?? '';

      if (attendanceType == 'CLOCK_IN' && time.isNotEmpty) {
        attendanceProvider.clockIn(time);
        await Future.delayed(const Duration(milliseconds: 500));
        await attendanceProvider.refreshTodayAttendance(
            preserveLocalState: true);

        GlobalSnackBar.show('Berhasil melakukan Absen Masuk pada $time',
            isSuccess: true);
      } else if (attendanceType.isEmpty) {
        await Future.delayed(const Duration(milliseconds: 500));
        await attendanceProvider.refreshTodayAttendance(
            preserveLocalState: true);
      }
    }
  }

  Future<void> _handleClockOut(BuildContext context) async {
    if (!_canClockOut) {
      GlobalSnackBar.show('Belum waktunya absen pulang (Jadwal: $_workEndTime)',
          isWarning: true);
      return;
    }

    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => CustomDialog(
        title: 'Konfirmasi Pulang',
        content: 'Apakah Anda yakin ingin melakukan absen pulang?',
        primaryButtonText: 'Ya, Pulang',
        secondaryButtonText: 'Batal',
        primaryButtonColor: AppThemes.warningColor,
        onPrimaryButtonPressed: () => Navigator.pop(context, true),
        onSecondaryButtonPressed: () => Navigator.pop(context, false),
        icon: Icons.logout_rounded,
      ),
    );

    if (confirmed != true || !mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final hasPermission = await PermissionService.requestLocationPermission();
      if (!hasPermission) {
        if (mounted) {
          Navigator.pop(context);
          GlobalSnackBar.show('Izin lokasi diperlukan.', isWarning: true);
        }
        return;
      }

      final currentLocation = await LocationService.getCurrentLocation();
      if (currentLocation == null) {
        if (mounted) {
          Navigator.pop(context);
          GlobalSnackBar.show('Lokasi tidak ditemukan.', isError: true);
        }
        return;
      }

      final pesertaMagangId = await _getPesertaId();
      if (pesertaMagangId == null) {
        if (mounted) {
          Navigator.pop(context);
          GlobalSnackBar.show('ID Peserta tidak ditemukan.', isError: true);
        }
        return;
      }

      final nowTime = IndonesianTime.now;
      final attendanceResponse = await AttendanceService.createAttendance(
        pesertaMagangId: pesertaMagangId,
        tipe: 'KELUAR',
        timestamp: nowTime,
        lokasi: {
          'latitude': currentLocation['latitude'],
          'longitude': currentLocation['longitude'],
          'address': currentLocation['address'] ?? '',
        },
        qrCodeData: 'direct_clockout_${nowTime.millisecondsSinceEpoch}',
        device: 'Mobile App',
      );

      if (mounted) {
        Navigator.pop(context);

        if (attendanceResponse.success) {
          final attendanceProvider =
              Provider.of<AttendanceProvider>(context, listen: false);
          final time = IndonesianTime.formatTime(IndonesianTime.now);
          attendanceProvider.clockOut(time);
          await attendanceProvider.refreshTodayAttendance(
              preserveLocalState: true);

          GlobalSnackBar.show('Absen pulang berhasil dilakukan',
              isSuccess: true);
        } else {
          GlobalSnackBar.show(attendanceResponse.message, isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        GlobalSnackBar.show('Terjadi kesalahan: ${e.toString()}',
            isError: true);
      }
    }
  }

  void _showAlreadyClockedInNotification() {
    GlobalSnackBar.show('Anda sudah melakukan absen masuk hari ini.',
        isWarning: true);
  }

  void _handleRequestLeave() {
    showDialog(
      context: context,
      builder: (context) => LeaveFormDialog(
        onSubmit: (tipe, alasan, start, end) async {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );

          try {
            final pesertaMagangId = await _getPesertaId();
            if (pesertaMagangId == null) {
              if (mounted) {
                Navigator.pop(context);
                GlobalSnackBar.show('ID Peserta tidak ditemukan.',
                    isError: true);
              }
              return;
            }

            final dateFormat = DateFormat('yyyy-MM-dd');
            final startDateStr = dateFormat.format(start);
            final endDateStr = dateFormat.format(end);

            final response = await LeaveService.createLeave(
              pesertaMagangId: pesertaMagangId,
              tipe: tipe,
              alasan: alasan,
              tanggalMulai: startDateStr,
              tanggalSelesai: endDateStr,
            );

            if (mounted) {
              Navigator.pop(context);
              if (response.success) {
                GlobalSnackBar.show('Pengajuan berhasil dikirim.',
                    isSuccess: true);
              } else {
                GlobalSnackBar.show(response.message, isError: true);
              }
            }
          } catch (e) {
            if (mounted) {
              Navigator.pop(context);
              GlobalSnackBar.show('Terjadi kesalahan: $e', isError: true);
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor:
          isDark ? AppThemes.darkBackground : AppThemes.backgroundColor,
      appBar: CustomAppBar(
        title: 'Home',
        showBackButton: false,
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color:
                  isDark ? AppThemes.darkTextPrimary : AppThemes.onSurfaceColor,
            ),
            onPressed: () {
              GlobalSnackBar.show('Tidak ada notifikasi baru',
                  title: 'Info', isInfo: true);
            },
          ),
        ],
      ),
      body: Consumer<AttendanceProvider>(
        builder: (context, attendanceProvider, child) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const WelcomeHeaderWidget(),
                    const SizedBox(height: 24),

                    // --- ATTENDANCE CARD dengan Parameter Baru ---
                    AttendanceCard(
                      isClockedIn: attendanceProvider.isClockedIn,
                      isClockedOut: attendanceProvider.isClockedOut,

                      canClockOut: _canClockOut,
                      workEndTime: _workEndTime,

                      // Inject Status Izin (Izin/Sakit) jika ada
                      leaveStatus: _todayLeaveStatus,

                      onClockIn: () async {
                        if (attendanceProvider.isClockedIn) {
                          _showAlreadyClockedInNotification();
                          return;
                        }
                        final result = await Navigator.pushNamed(
                          context,
                          RouteNames.qrScan,
                          arguments: {'type': 'CLOCK_IN'},
                        );
                        _handleAttendanceResult(context, result);
                      },
                      onClockOut: () async {
                        await _handleClockOut(context);
                      },
                      onRequestLeave: _handleRequestLeave,
                    ),

                    const SizedBox(height: 16),
                    AttendanceStatusCard(
                      clockInTime: attendanceProvider.clockInTime,
                      clockOutTime: attendanceProvider.clockOutTime,
                      isClockedIn: attendanceProvider.isClockedIn,
                      isClockedOut: attendanceProvider.isClockedOut,
                    ),
                    // ... sisa widget (Performa, Pengumuman, dll) tetap sama ...
                    const SizedBox(height: 24),
                    Text(
                      'Performa',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppThemes.darkTextPrimary
                            : AppThemes.onSurfaceColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _isLoadingPerformance
                        ? const Center(child: CircularProgressIndicator())
                        : SizedBox(
                            width: double.infinity,
                            child: PerformanceCard(
                              presentDays: _performanceStats?.presentDays ?? 0,
                              totalDays: _performanceStats?.totalDays ?? 0,
                            ),
                          ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: AnnouncementCard(
                        onDownload: (item) {},
                        onViewDetail: (item) {},
                      ),
                    ),
                    SizedBox(height: isKeyboardOpen ? 20 : 100),
                  ],
                ),
              ),
              if (!isKeyboardOpen)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: FloatingBottomNav(
                    currentRoute: RouteNames.home,
                    onQRScanTap: () {
                      if (attendanceProvider.isClockedIn) {
                        _showAlreadyClockedInNotification();
                        return;
                      }
                      NavigationHelper.navigateWithoutAnimation(
                        context,
                        RouteNames.qrScan,
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
