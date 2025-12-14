import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/performance_stats.dart';
import '../../navigation/route_names.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/dashboard_service.dart';
import '../../services/storage_service.dart';
import '../../themes/app_themes.dart';
import '../../utils/constants.dart';
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
  PerformanceStats? _performanceStats;
  bool _isLoadingPerformance = false;

  @override
  void initState() {
    super.initState();
    _loadPerformanceData();
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
        final userDataStr = await StorageService.getString(AppConstants.userDataKey);
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
        final refreshedUserDataStr = await StorageService.getString(AppConstants.userDataKey);
        if (refreshedUserDataStr != null) {
          final refreshedUserData = jsonDecode(refreshedUserDataStr);
          pesertaMagangId = refreshedUserData['pesertaMagang']?['id']?.toString();
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
          setState(() {
            _performanceStats = PerformanceStats.empty();
            _isLoadingPerformance = false;
          });
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
      }
    }
  }
  // Method untuk handle attendance result - PERBAIKI TYPE CASTING
  Future<void> _handleAttendanceResult(BuildContext context, dynamic result) async {
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
        // Refresh today attendance after clock in
        await attendanceProvider.refreshTodayAttendance();
      } else if (attendanceType == 'CLOCK_OUT') {
        attendanceProvider.clockOut(time);
        // Refresh today attendance after clock out
        await attendanceProvider.refreshTodayAttendance();
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
      backgroundColor: isDark
          ? AppThemes.darkBackground
          : AppThemes.backgroundColor,
      appBar: CustomAppBar(
        title: 'Home',
        showBackButton: false,
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: isDark
                  ? AppThemes.darkTextPrimary
                  : AppThemes.onSurfaceColor,
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
                                  content: Text(
                                    '${item.title} berhasil didownload',
                                  ),
                                  backgroundColor: AppThemes.successColor,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
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
