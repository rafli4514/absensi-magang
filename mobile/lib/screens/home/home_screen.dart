import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../navigation/route_names.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/auth_provider.dart';
import '../../themes/app_themes.dart';
import '../../utils/navigation_helper.dart';
import '../../widgets/announcement_card.dart';
import '../../widgets/attendance_card.dart';
import '../../widgets/attendance_status_card.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/detail_dialog.dart';
import '../../widgets/download_dialog.dart';
import '../../widgets/floating_bottom_nav.dart';
import '../../widgets/performance_card.dart';
import '../../widgets/welcome_header_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Method untuk handle attendance result - PERBAIKI TYPE CASTING
  void _handleAttendanceResult(BuildContext context, dynamic result) {
    if (result != null && result is Map<String, dynamic> && mounted) {
      if (kDebugMode) {
        print('🏠 HOME: Received result from QR: $result');
      }

      final attendanceProvider = Provider.of<AttendanceProvider>(
        context,
        listen: false,
      );
      final attendanceType = result['type'] as String;
      final time = result['time'] as String;

      if (kDebugMode) {
        print('🏠 HOME: Calling provider.$attendanceType($time)');
        print(
          '🏠 HOME: Before - isClockedIn: ${attendanceProvider.isClockedIn}, clockInTime: ${attendanceProvider.clockInTime}',
        );
      }

      if (attendanceType == 'CLOCK_IN') {
        attendanceProvider.clockIn(time);
      } else if (attendanceType == 'CLOCK_OUT') {
        attendanceProvider.clockOut(time);
      }

      if (kDebugMode) {
        print(
          '🏠 HOME: After - isClockedIn: ${attendanceProvider.isClockedIn}, clockInTime: ${attendanceProvider.clockInTime}',
        );
      }
    } else {
      if (kDebugMode) {
        print('🏠 HOME: No result received or result is invalid');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
              // Navigate to notifications
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
                    // Header Section dengan WelcomeHeaderWidget
                    const WelcomeHeaderWidget(),
                    const SizedBox(height: 24),

                    // Attendance Card dengan provider
                    AttendanceCard(
                      onClockIn: () async {
                        final result = await Navigator.pushNamed(
                          context,
                          RouteNames.qrScan,
                          arguments: {'type': 'CLOCK_IN'},
                        );
                        _handleAttendanceResult(
                          context,
                          result,
                        ); // HAPUS CASTING DI SINI
                      },
                      onClockOut: () async {
                        final result = await Navigator.pushNamed(
                          context,
                          RouteNames.qrScan,
                          arguments: {'type': 'CLOCK_OUT'},
                        );
                        _handleAttendanceResult(
                          context,
                          result,
                        ); // HAPUS CASTING DI SINI
                      },
                      isClockedIn: attendanceProvider.isClockedIn,
                      isClockedOut: attendanceProvider.isClockedOut,
                    ),
                    const SizedBox(height: 16),

                    // Attendance Status Card dengan provider
                    AttendanceStatusCard(
                      clockInTime: attendanceProvider.clockInTime,
                      clockOutTime: attendanceProvider.clockOutTime,
                      isClockedIn: attendanceProvider.isClockedIn,
                      isClockedOut: attendanceProvider.isClockedOut,
                    ),
                    const SizedBox(height: 24),

                    // Performance
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
                    const PerformanceCard(presentDays: 18, totalDays: 22),
                    const SizedBox(height: 24),

                    // Announcements
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
                            horizontal: 12,
                            vertical: 6,
                          ),
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

                    // Announcement Cards
                    AnnouncementCard(
                      onDownload: (item) {
                        showDialog(
                          context: context,
                          builder: (context) => DownloadDialog(
                            fileName: item.title,
                            onDownload: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  // 1. Background menggunakan warna Surface (bukan hijau solid) agar Border terlihat
                                  backgroundColor: isDark
                                      ? AppThemes.darkSurfaceElevated
                                      : AppThemes.surfaceColor,

                                  // 2. Behavior Floating dengan margin
                                  behavior: SnackBarBehavior.floating,
                                  margin: const EdgeInsets.all(16),
                                  elevation:
                                      4, // Tambahkan sedikit bayangan agar pop-up

                                  // 3. Shape dengan BORDER berwarna Success (Seperti Badge)
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(
                                      color: AppThemes
                                          .successColor, // Warna border hijau
                                      width: 1.5, // Ketebalan border
                                    ),
                                  ),

                                  // 4. Konten Custom dengan Icon
                                  content: Row(
                                    children: [
                                      // Indikator Icon (Bulat hijau transparan)
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppThemes.successColor
                                              .withOpacity(0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check_circle_rounded,
                                          color: AppThemes.successColor,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      // Teks Pesan
                                      Expanded(
                                        child: Text(
                                          '${item.title} berhasil didownload',
                                          style: TextStyle(
                                            // Warna teks menyesuaikan tema (bukan putih fix)
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
                                ),
                              );
                            },
                          ),
                        );
                      },
                      onViewDetail: (item) {
                        showDialog(
                          context: context,
                          builder: (context) => DetailDialog(
                            title: item.title,
                            description: item.body,
                          ),
                        );
                      },
                    ),

                    // Extra padding untuk memberikan space untuk floating bottom nav
                    const SizedBox(height: 80),
                  ],
                ),
              ),

              // Floating Bottom Navigation
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: FloatingBottomNav(
                  currentRoute: RouteNames.home,
                  onQRScanTap: () {
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
