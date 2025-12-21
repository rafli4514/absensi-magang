import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/performance_stats.dart';
import '../../navigation/route_names.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/attendance_service.dart';
import '../../services/dashboard_service.dart';
import '../../services/location_service.dart';
import '../../services/permission_service.dart';
import '../../services/storage_service.dart';
import '../../themes/app_themes.dart';
import '../../utils/constants.dart';
import '../../utils/indonesian_time.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/ui_utils.dart'; // Pastikan import ini ada
import '../../widgets/announcement_card.dart';
import '../../widgets/attendance_card.dart';
import '../../widgets/attendance_status_card.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/floating_bottom_nav.dart';
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

  @override
  void initState() {
    super.initState();
    _loadPerformanceData();
    // Pastikan status absensi hari ini selalu di-refresh saat masuk Home,
    // terutama setelah login dengan akun berbeda.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final attendanceProvider =
            Provider.of<AttendanceProvider>(context, listen: false);

        // Jika sudah login (ada user), refresh status absensi hari ini dari backend
        // TANPA mereset paksa state lokal (biarkan backend yang menentukan).
        if (authProvider.user != null) {
          attendanceProvider.refreshTodayAttendance(preserveLocalState: true);
        }
      }
    });
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

      // Get pesertaMagangId
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
        // Try to refresh profile
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
          // [FIXED] Tambahkan notifikasi warning/error jika gagal load performa
          if (mounted) {
            setState(() {
              _performanceStats = PerformanceStats.empty();
              _isLoadingPerformance = false;
            });
            GlobalSnackBar.show(
              'Gagal memuat statistik performa',
              isWarning: true,
            );
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
      // [FIXED] Tambahkan notifikasi error koneksi
      if (mounted) {
        setState(() {
          _performanceStats = PerformanceStats.empty();
          _isLoadingPerformance = false;
        });
        GlobalSnackBar.show(
          'Koneksi error saat memuat statistik',
          isError: true,
        );
      }
    }
  }

  // Method untuk handle attendance result
  Future<void> _handleAttendanceResult(
      BuildContext context, dynamic result) async {
    if (result != null && result is Map<String, dynamic> && mounted) {
      if (kDebugMode) {
        print('匠 HOME: Received result from QR: $result');
      }

      final attendanceProvider =
          Provider.of<AttendanceProvider>(context, listen: false);
      final attendanceType = result['type'] as String? ?? '';
      final time = result['time'] as String? ?? '';

      if (kDebugMode) {
        print(
            '匠 HOME: Processing attendance type: $attendanceType, time: $time');
      }

      if (attendanceType == 'CLOCK_IN' && time.isNotEmpty) {
        attendanceProvider.clockIn(time);

        if (kDebugMode) {
          print('匠 HOME: Clock in processed, waiting before refresh...');
        }

        // Wait a bit for backend to process
        await Future.delayed(const Duration(milliseconds: 500));

        // Refresh today attendance after clock in, preserve local state if API doesn't have it yet
        await attendanceProvider.refreshTodayAttendance(
            preserveLocalState: true);

        if (kDebugMode) {
          print('匠 HOME: Clock in processed successfully');
        }

        // Menampilkan notifikasi sukses di Home juga (optional, karena QR screen mungkin sudah close)
        GlobalSnackBar.show(
          'Berhasil melakukan Clock In pada $time',
          title: 'Presensi Sukses',
          isSuccess: true,
        );
      } else if (attendanceType.isEmpty) {
        if (kDebugMode) {
          print(
              '匠 HOME: Warning - attendance type is empty in result, refreshing from API...');
        }
        // Wait a bit for backend to process
        await Future.delayed(const Duration(milliseconds: 500));
        // Try to refresh from API anyway
        await attendanceProvider.refreshTodayAttendance(
            preserveLocalState: true);
      }

      if (kDebugMode) {
        print(
          '匠 HOME: After - isClockedIn: ${attendanceProvider.isClockedIn}, clockInTime: ${attendanceProvider.clockInTime}',
        );
      }
    }
  }

  // Method untuk handle clock out langsung tanpa scan QR
  Future<void> _handleClockOut(BuildContext context) async {
    if (!mounted) return;

    // Tampilkan dialog konfirmasi terlebih dahulu (User Decision -> Tetap Dialog)
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => CustomDialog(
        title: 'Konfirmasi Clock Out',
        content: 'Apakah Anda yakin ingin melakukan clock out?',
        primaryButtonText: 'Ya, Clock Out',
        secondaryButtonText: 'Batal',
        primaryButtonColor: AppThemes.warningColor,
        onPrimaryButtonPressed: () => Navigator.pop(context, true),
        onSecondaryButtonPressed: () => Navigator.pop(context, false),
        icon: Icons.logout_rounded,
      ),
    );

    // Jika user membatalkan, return tanpa melakukan apa-apa
    if (confirmed != true || !mounted) {
      return;
    }

    // Tampilkan loading indicator (bisa pakai AppLoadingOverlay atau Dialog sederhana)
    // Disini kita pakai Dialog simple agar memblokir interaksi
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Request location permission
      final hasPermission = await PermissionService.requestLocationPermission();
      if (!hasPermission) {
        if (mounted) {
          Navigator.pop(context); // Close loading
          // REPLACED: CustomDialog -> GlobalSnackBar
          GlobalSnackBar.show(
            'Harap berikan akses lokasi untuk melakukan presensi.',
            title: 'Izin Diperlukan',
            isWarning: true,
          );
        }
        return;
      }

      // Get current location
      final currentLocation = await LocationService.getCurrentLocation();
      if (currentLocation == null) {
        if (mounted) {
          Navigator.pop(context); // Close loading
          // REPLACED: CustomDialog -> GlobalSnackBar
          GlobalSnackBar.show(
            'Tidak dapat mendeteksi lokasi Anda. Pastikan GPS aktif.',
            title: 'Lokasi Tidak Ditemukan',
            isError: true,
          );
        }
        return;
      }

      // Get pesertaMagangId
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;

      if (user == null) {
        if (mounted) {
          Navigator.pop(context); // Close loading
          // REPLACED: CustomDialog -> GlobalSnackBar
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
        // Try to refresh profile
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
          Navigator.pop(context); // Close loading
          // REPLACED: CustomDialog -> GlobalSnackBar
          GlobalSnackBar.show(
            'ID Peserta Magang tidak ditemukan. Hubungi admin.',
            title: 'Data Tidak Lengkap',
            isError: true,
          );
        }
        return;
      }

      // Submit clock out
      final nowTime = IndonesianTime.now; // Use Indonesian time
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
        Navigator.pop(context); // Close loading

        if (attendanceResponse.success) {
          final attendanceProvider =
              Provider.of<AttendanceProvider>(context, listen: false);
          final time = IndonesianTime.formatTime(IndonesianTime.now);
          attendanceProvider.clockOut(time);
          await attendanceProvider.refreshTodayAttendance(
              preserveLocalState: true);

          // SUKSES
          GlobalSnackBar.show(
            'Clock out berhasil dilakukan',
            title: 'Berhasil',
            isSuccess: true,
            icon: Icons.check_circle_outline_rounded,
          );
        } else {
          // REPLACED: CustomDialog -> GlobalSnackBar (API Error)
          GlobalSnackBar.show(
            attendanceResponse.message,
            title: 'Gagal Clock Out',
            isError: true,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        // REPLACED: CustomDialog -> GlobalSnackBar (Exception)
        GlobalSnackBar.show(
          'Terjadi kesalahan: ${e.toString()}',
          title: 'System Error',
          isError: true,
        );
      }
    }
  }

  // Helper untuk notifikasi "Sudah Absen" (digunakan di tombol & FAB)
  void _showAlreadyClockedInNotification() {
    GlobalSnackBar.show(
      'Anda sudah melakukan clock in hari ini.',
      title: 'Info Presensi',
      isWarning: true, // Warning kuning lebih cocok daripada dialog blocking
      icon: Icons.info_outline_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // DETEKSI KEYBOARD
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
                  children: [
                    const WelcomeHeaderWidget(),
                    const SizedBox(height: 24),
                    AttendanceCard(
                      onClockIn: () async {
                        // Jika sudah pernah clock in hari ini, jangan izinkan scan lagi
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
                      isClockedIn: attendanceProvider.isClockedIn,
                      isClockedOut: attendanceProvider.isClockedOut,
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
                      'Performance',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppThemes.darkTextPrimary
                            : AppThemes.onSurfaceColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Performance Card - data dari API
                    _isLoadingPerformance
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : PerformanceCard(
                            presentDays: _performanceStats?.presentDays ?? 0,
                            totalDays: _performanceStats?.totalDays ?? 0,
                          ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Announcements',
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
                            'Documents',
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
                    AnnouncementCard(
                      onDownload: (item) {
                        showDialog(
                          context: context,
                          builder: (context) => CustomDialog.download(
                            fileName: item.title,
                            onDownload: () {
                              Navigator.pop(context);
                              GlobalSnackBar.show(
                                '${item.title} berhasil didownload',
                                title: 'Download Selesai',
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
                    // Beri padding bawah ekstra JIKA keyboard tidak buka (untuk navbar)
                    SizedBox(height: isKeyboardOpen ? 20 : 100),
                  ],
                ),
              ),

              // HANYA TAMPILKAN NAVBAR JIKA KEYBOARD TERTUTUP
              if (!isKeyboardOpen)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: FloatingBottomNav(
                    currentRoute: RouteNames.home,
                    onQRScanTap: () {
                      // Cegah scan langsung dari FAB jika sudah clock in hari ini
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
