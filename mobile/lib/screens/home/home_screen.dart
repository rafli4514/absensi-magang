import 'dart:async'; // PENTING: Untuk Timer
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal
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
import '../../services/settings_service.dart'; // PENTING: Import SettingsService
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

  // VARIABEL BARU UNTUK VALIDASI JAM PULANG
  String _workEndTime = "17:00"; // Default fallback
  bool _canClockOut = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadPerformanceData();
    _loadSettings(); // Ambil jam pulang dari backend

    // Cek waktu setiap 1 menit agar tombol otomatis aktif saat jamnya tiba
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
    _timer?.cancel(); // Bersihkan timer saat widget didestroy
    super.dispose();
  }

  // --- LOGIC BARU: Ambil Setting & Cek Waktu ---
  Future<void> _loadSettings() async {
    try {
      final response = await SettingsService.getSettings();
      if (response.success && response.data != null) {
        if (mounted) {
          setState(() {
            // Ambil workEndTime dari JSON backend (sesuai struktur controller backend)
            // Struktur: { schedule: { workEndTime: "17:00", ... }, ... }
            final schedule = response.data!['schedule'];
            if (schedule != null && schedule['workEndTime'] != null) {
              _workEndTime = schedule['workEndTime'];
            }
            // Panggil cek waktu segera setelah data didapat
            _checkClockOutTime();
          });
        }
      }
    } catch (e) {
      if (kDebugMode) print("Gagal load settings: $e");
    }
  }

  void _checkClockOutTime() {
    // Gunakan IndonesianTime.now jika sudah ada utilitasnya, atau DateTime.now()
    final now = DateTime.now();

    // Parsing jam pulang (Format HH:mm dari backend)
    final parts = _workEndTime.split(':');
    if (parts.length == 2) {
      final endHour = int.parse(parts[0]);
      final endMinute = int.parse(parts[1]);

      // Buat DateTime hari ini dengan jam pulang target
      final endTime =
          DateTime(now.year, now.month, now.day, endHour, endMinute);

      // Bandingkan: Apakah sekarang >= jam pulang?
      final canOut = now.isAfter(endTime) || now.isAtSameMomentAs(endTime);

      if (mounted && _canClockOut != canOut) {
        setState(() {
          _canClockOut = canOut;
        });
      }
    }
  }

  Future<void> _loadPerformanceData() async {
    if (!mounted) return;

    setState(() => _isLoadingPerformance = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;

      if (user == null) {
        setState(() => _isLoadingPerformance = false);
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
      } catch (e) {
        if (kDebugMode) print('Error getting pesertaMagangId: $e');
      }

      if (pesertaMagangId == null || pesertaMagangId.isEmpty) {
        await authProvider.refreshProfile();
        final refreshedUserDataStr =
            await StorageService.getString(AppConstants.userDataKey);
        if (refreshedUserDataStr != null) {
          final refreshedUserData = jsonDecode(refreshedUserDataStr);
          pesertaMagangId =
              refreshedUserData['pesertaMagang']?['id']?.toString();
        }
      }

      if (pesertaMagangId != null && pesertaMagangId.isNotEmpty) {
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
            GlobalSnackBar.show('Gagal memuat statistik performa',
                isWarning: true);
          }
        }
      } else {
        setState(() {
          _performanceStats = PerformanceStats.empty();
          _isLoadingPerformance = false;
        });
      }
    } catch (e) {
      if (kDebugMode) print('Error loading performance: $e');
      if (mounted) {
        setState(() {
          _performanceStats = PerformanceStats.empty();
          _isLoadingPerformance = false;
        });
        GlobalSnackBar.show('Koneksi error saat memuat statistik',
            isError: true);
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

        GlobalSnackBar.show(
          'Berhasil melakukan Absen Masuk pada $time',
          title: 'Presensi Sukses',
          isSuccess: true,
        );
      } else if (attendanceType.isEmpty) {
        await Future.delayed(const Duration(milliseconds: 500));
        await attendanceProvider.refreshTodayAttendance(
            preserveLocalState: true);
      }
    }
  }

  Future<void> _handleClockOut(BuildContext context) async {
    // VALIDASI TAMBAHAN: Cek lagi saat tombol ditekan
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

    if (confirmed != true || !mounted) {
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final hasPermission = await PermissionService.requestLocationPermission();
      if (!hasPermission) {
        if (mounted) {
          Navigator.pop(context);
          GlobalSnackBar.show(
            'Harap berikan akses lokasi untuk melakukan presensi.',
            title: 'Izin Diperlukan',
            isWarning: true,
          );
        }
        return;
      }

      final currentLocation = await LocationService.getCurrentLocation();
      if (currentLocation == null) {
        if (mounted) {
          Navigator.pop(context);
          GlobalSnackBar.show(
            'Tidak dapat mendeteksi lokasi Anda. Pastikan GPS aktif.',
            title: 'Lokasi Tidak Ditemukan',
            isError: true,
          );
        }
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;

      if (user == null) {
        if (mounted) {
          Navigator.pop(context);
          GlobalSnackBar.show(
            'Data user tidak ditemukan. Silakan login ulang.',
            title: 'Sesi Invalid',
            isError: true,
          );
        }
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
      } catch (e) {
        if (kDebugMode) print('Error getting pesertaMagangId: $e');
      }

      if (pesertaMagangId == null || pesertaMagangId.isEmpty) {
        await authProvider.refreshProfile();
        final refreshedUserDataStr =
            await StorageService.getString(AppConstants.userDataKey);
        if (refreshedUserDataStr != null) {
          final refreshedUserData = jsonDecode(refreshedUserDataStr);
          pesertaMagangId =
              refreshedUserData['pesertaMagang']?['id']?.toString();
        }
      }

      if (pesertaMagangId == null || pesertaMagangId.isEmpty) {
        if (mounted) {
          Navigator.pop(context);
          GlobalSnackBar.show(
            'ID Peserta Magang tidak ditemukan. Hubungi admin.',
            title: 'Data Tidak Lengkap',
            isError: true,
          );
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

          GlobalSnackBar.show(
            'Absen pulang berhasil dilakukan',
            title: 'Berhasil',
            isSuccess: true,
            icon: Icons.check_circle_outline_rounded,
          );
        } else {
          GlobalSnackBar.show(
            attendanceResponse.message,
            title: 'Gagal Absen Pulang',
            isError: true,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        GlobalSnackBar.show(
          'Terjadi kesalahan: ${e.toString()}',
          title: 'System Error',
          isError: true,
        );
      }
    }
  }

  void _showAlreadyClockedInNotification() {
    GlobalSnackBar.show(
      'Anda sudah melakukan absen masuk hari ini.',
      title: 'Info Presensi',
      isWarning: true,
      icon: Icons.info_outline_rounded,
    );
  }

  // --- LOGIC PENGAJUAN IZIN ---
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
            final authProvider =
                Provider.of<AuthProvider>(context, listen: false);
            final user = authProvider.user;

            String? pesertaMagangId;
            try {
              final userDataStr =
                  await StorageService.getString(AppConstants.userDataKey);
              if (userDataStr != null) {
                final userData = jsonDecode(userDataStr);
                pesertaMagangId = userData['pesertaMagang']?['id']?.toString();
              }
            } catch (_) {}

            if (pesertaMagangId == null && user != null) {
              await authProvider.refreshProfile();
              final updatedStr =
                  await StorageService.getString(AppConstants.userDataKey);
              if (updatedStr != null) {
                final u = jsonDecode(updatedStr);
                pesertaMagangId = u['pesertaMagang']?['id']?.toString();
              }
            }

            if (pesertaMagangId == null) {
              if (mounted) {
                Navigator.pop(context);
                GlobalSnackBar.show(
                    'ID Peserta tidak ditemukan. Hubungi admin.',
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
                GlobalSnackBar.show(
                  'Pengajuan berhasil dikirim. Menunggu persetujuan mentor.',
                  title: 'Sukses',
                  isSuccess: true,
                );
              } else {
                GlobalSnackBar.show(
                  response.message,
                  title: 'Gagal',
                  isError: true,
                );
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
                    AttendanceCard(
                      isClockedIn: attendanceProvider.isClockedIn,
                      isClockedOut: attendanceProvider.isClockedOut,

                      // --- PASSING DATA VALIDASI PULANG ---
                      canClockOut: _canClockOut,
                      workEndTime: _workEndTime,

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
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : SizedBox(
                            width: double.infinity,
                            child: PerformanceCard(
                              presentDays: _performanceStats?.presentDays ?? 0,
                              totalDays: _performanceStats?.totalDays ?? 0,
                            ),
                          ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pengumuman',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppThemes.darkTextPrimary
                                : AppThemes.onSurfaceColor,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppThemes.darkSurface
                                : AppThemes.backgroundColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Dokumen',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppThemes.darkTextSecondary
                                  : AppThemes.hintColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: AnnouncementCard(
                        onDownload: (item) {
                          showDialog(
                            context: context,
                            builder: (context) => CustomDialog.download(
                              fileName: item.title,
                              onDownload: () {
                                Navigator.pop(context);
                                GlobalSnackBar.show(
                                  '${item.title} berhasil diunduh',
                                  title: 'Unduhan Selesai',
                                  isSuccess: true,
                                  icon: Icons.file_download_done_rounded,
                                );
                              },
                            ),
                          );
                        },
                        onViewDetail: (item) {
                          showDialog(
                            context: context,
                            builder: (context) => CustomDialog.detail(
                              title: item.title,
                              description: item.body,
                              onClose: () => Navigator.pop(context),
                            ),
                          );
                        },
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
