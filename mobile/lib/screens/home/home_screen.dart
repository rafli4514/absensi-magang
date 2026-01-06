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
import '../../services/notification_service.dart';
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
  String _workEndTime = "17:00";
  bool _canClockOut = false;
  Timer? _realtimeTimer;
  bool _stopRealtimeCheck = false;
  String? _todayLeaveStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialDataLoad();
    });

    _realtimeTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_stopRealtimeCheck && mounted) {
        _checkClockOutTime();
        _checkStatusUpdatesBackground();
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _realtimeTimer?.cancel();
    super.dispose();
  }

  Future<void> _initialDataLoad() async {
    if (!mounted) return;
    setState(() {
      _stopRealtimeCheck = false;
    });

    if (_realtimeTimer != null && !_realtimeTimer!.isActive) {
      _realtimeTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (!_stopRealtimeCheck && mounted) {
          _checkClockOutTime();
          _checkStatusUpdatesBackground();
        } else {
          timer.cancel();
        }
      });
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final attendanceProvider =
        Provider.of<AttendanceProvider>(context, listen: false);

    await authProvider.refreshProfile();

    await Future.wait([
      _loadSettings(),
      _checkStatusUpdatesBackground(),
      _loadPerformanceData(),
      attendanceProvider.refreshTodayAttendance(preserveLocalState: false),
    ]);
  }

  Future<String?> _getPesertaId() async {
    try {
      final userDataStr =
          await StorageService.getString(AppConstants.userDataKey);
      if (userDataStr != null) {
        final userData = jsonDecode(userDataStr);
        return userData['pesertaMagang']?['id']?.toString() ??
            userData['idPesertaMagang']?.toString();
      }
    } catch (_) {}
    return null;
  }

  Future<void> _checkStatusUpdatesBackground() async {
    try {
      String? pesertaId = await _getPesertaId();
      if (pesertaId == null && mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.refreshProfile();
        pesertaId = await _getPesertaId();
      }

      if (pesertaId == null) return;

      final status = await LeaveService.getTodayLeaveStatus(pesertaId);

      if (mounted) {
        if (_todayLeaveStatus != status) {
          setState(() {
            _todayLeaveStatus = status;
          });
        }

        if (status != null) {
          final now = DateTime.now();
          final dateKey = '${now.year}-${now.month}-${now.day}';
          final storageKey = 'notif_seen_${dateKey}_APPROVED';
          final hasSeen = await StorageService.getBool(storageKey) ?? false;

          if (!hasSeen) {
            final title = status == 'SAKIT'
                ? 'Izin Sakit Disetujui'
                : 'Permohonan Izin Disetujui';
            await NotificationService().showNotification(
              id: 200,
              title: title,
              body: 'Pengajuan $status Anda telah disetujui.',
            );
            await StorageService.setBool(storageKey, true);
          }
        }
      }

      if (status == null) {
        await _checkRejectedLeave(pesertaId);
      }
    } catch (e) {
      if (kDebugMode) print("Error check status: $e");
    }
  }

  void _stopRealtimeChecking() {
    if (mounted && !_stopRealtimeCheck) {
      setState(() {
        _stopRealtimeCheck = true;
      });
    }
  }

  Future<void> _checkRejectedLeave(String pesertaId) async {
    try {
      final response = await LeaveService.getLeaves(
          pesertaMagangId: pesertaId, status: 'DITOLAK');
      if (response.success && response.data != null) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final dateKey = '${now.year}-${now.month}-${now.day}';

        for (var leave in response.data!) {
          DateTime? tglMulai;
          try {
            tglMulai = DateTime.parse(leave['tanggalMulai']);
          } catch (_) {}

          if (tglMulai != null) {
            final tglIzin =
                DateTime(tglMulai.year, tglMulai.month, tglMulai.day);
            if (tglIzin.isAtSameMomentAs(today)) {
              final leaveId = leave['id'].toString();
              final storageKey = 'notif_seen_${dateKey}_REJECTED_$leaveId';
              final hasSeen = await StorageService.getBool(storageKey) ?? false;

              if (!hasSeen) {
                await NotificationService().showNotification(
                  id: 201,
                  title: 'Pengajuan Izin Ditolak',
                  body: 'Maaf, pengajuan izin Anda ditolak.',
                );
                await StorageService.setBool(storageKey, true);
                _stopRealtimeChecking();
              } else {
                _stopRealtimeChecking();
              }
              break;
            }
          }
        }
      }
    } catch (_) {}
  }

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
    final canOut = AttendanceService.isClockOutTimeReached(_workEndTime);
    if (mounted && _canClockOut != canOut) {
      setState(() {
        _canClockOut = canOut;
      });
    }
  }

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

      if (pesertaMagangId != null) {
        final response = await DashboardService.getCurrentMonthPerformance(
          pesertaMagangId: pesertaMagangId,
        );

        if (mounted) {
          setState(() {
            if (response.success && response.data != null) {
              _performanceStats = response.data;
            } else {
              _performanceStats = PerformanceStats.empty();
            }
            _isLoadingPerformance = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _performanceStats = PerformanceStats.empty();
            _isLoadingPerformance = false;
          });
        }
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
        await _initialDataLoad();
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
          await _initialDataLoad();
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
                await _initialDataLoad();
                setState(() {
                  _stopRealtimeCheck = false;
                });
                if (_realtimeTimer != null && !_realtimeTimer!.isActive) {
                  _realtimeTimer =
                      Timer.periodic(const Duration(seconds: 3), (timer) {
                    if (!_stopRealtimeCheck && mounted) {
                      _checkStatusUpdatesBackground();
                    } else {
                      timer.cancel();
                    }
                  });
                }
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
              color: !_stopRealtimeCheck
                  ? AppThemes.successColor
                  : (isDark
                      ? AppThemes.darkTextPrimary
                      : AppThemes.onSurfaceColor),
            ),
            onPressed: () {
              final status = !_stopRealtimeCheck ? "Aktif" : "Selesai/Nonaktif";
              GlobalSnackBar.show('Monitoring Real-time: $status',
                  title: 'Info', isInfo: true);
            },
          ),
        ],
      ),
      body: Consumer<AttendanceProvider>(
        builder: (context, attendanceProvider, child) {
          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: _initialDataLoad,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const WelcomeHeaderWidget(),
                      const SizedBox(height: 24),
                      AttendanceCard(
                        isClockedIn: attendanceProvider.isClockedIn,
                        isClockedOut: attendanceProvider.isClockedOut,
                        canClockOut: _canClockOut,
                        workEndTime: _workEndTime,
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
                                presentDays:
                                    _performanceStats?.presentDays ?? 0,
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
