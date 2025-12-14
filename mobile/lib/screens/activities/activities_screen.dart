import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/activity.dart';
import '../../models/logbook.dart';
import '../../models/timeline_activity.dart';
import '../../navigation/route_names.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/logbook_service.dart';
import '../../services/storage_service.dart';
import '../../themes/app_themes.dart';
import '../../utils/constants.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/responsive_layout.dart';
import '../../utils/ui_utils.dart'; // Import UI Utils Baru
import '../../widgets/activities_header.dart';
import '../../widgets/activities_statistics.dart';
import '../../widgets/activities_timeline.dart';
import '../../widgets/activity_card.dart';
import '../../widgets/activity_form_dialog.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/floating_bottom_nav.dart';
import '../../widgets/logbook_card.dart';
import '../../widgets/logbook_form_dialog.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  String? _errorMessage;
  int _selectedTabIndex = 0;

  // LOGIKA FILTER MINGGU
  int _selectedWeekIndex = 0;
  late DateTime _startDateMagang;
  final int _totalWeeksDuration = 12;

  // List LogBook (dari API/database)
  List<LogBook> _allLogBooks = [];

  List<LogBook> _filteredLogBooks = [];

  // List Activities (dari API/database)
  final List<Activity> _activities = [];

  // List Timeline Activities (dari API/database)
  final List<TimelineActivity> _timelineActivities = [];

  bool _isLoadingLogbooks = false;

  @override
  void initState() {
    super.initState();
    // Get tanggal mulai dari user data
    _initializeStartDate();
    
    // Set default selected week ke minggu saat ini
    _selectedWeekIndex = 0;

    _loadLogbooks();
  }

  void _initializeStartDate() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    if (user?.tanggalMulai != null) {
      try {
        _startDateMagang = DateTime.parse(user!.tanggalMulai!);
      } catch (e) {
        // Fallback: 3 minggu lalu jika parsing gagal
        _startDateMagang = DateTime.now().subtract(const Duration(days: 21));
      }
    } else {
      // Fallback: 3 minggu lalu jika tidak ada tanggal mulai
      _startDateMagang = DateTime.now().subtract(const Duration(days: 21));
    }
    
    // Update selected week index berdasarkan minggu saat ini
    final now = DateTime.now();
    final daysDiff = now.difference(_startDateMagang).inDays;
    _selectedWeekIndex = (daysDiff / 7).floor().clamp(0, _totalWeeksDuration - 1);
  }

  Future<void> _loadLogbooks() async {
    if (!mounted) return;
    
    setState(() => _isLoadingLogbooks = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;
      
      if (user == null) {
        setState(() => _isLoadingLogbooks = false);
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
        await authProvider.refreshProfile();
        final refreshedUserDataStr = await StorageService.getString(AppConstants.userDataKey);
        if (refreshedUserDataStr != null) {
          final refreshedUserData = jsonDecode(refreshedUserDataStr);
          pesertaMagangId = refreshedUserData['pesertaMagang']?['id']?.toString();
        }
      }

      if (pesertaMagangId != null && pesertaMagangId.isNotEmpty) {
        final response = await LogbookService.getAllLogbook(
          pesertaMagangId: pesertaMagangId,
          limit: 500,
        );

        if (mounted && response.success && response.data != null) {
          // Sort logbooks by tanggal (newest first)
          final sortedLogbooks = List<LogBook>.from(response.data!);
          sortedLogbooks.sort((a, b) {
            try {
              final dateA = DateTime.parse(a.tanggal);
              final dateB = DateTime.parse(b.tanggal);
              return dateB.compareTo(dateA); // Descending order
            } catch (e) {
              return b.createdAt.compareTo(a.createdAt);
            }
          });
          
          setState(() {
            _allLogBooks = sortedLogbooks;
            _isLoadingLogbooks = false;
          });
          _filterLogBooks();
        } else {
          setState(() {
            _allLogBooks = [];
            _isLoadingLogbooks = false;
          });
          _filterLogBooks();
        }
      } else {
        setState(() {
          _allLogBooks = [];
          _isLoadingLogbooks = false;
        });
        _filterLogBooks();
      }
    } catch (e) {
      if (kDebugMode) print('Error loading logbooks: $e');
      if (mounted) {
        setState(() {
          _allLogBooks = [];
          _isLoadingLogbooks = false;
        });
        _filterLogBooks();
      }
    }
  }

  void _filterLogBooks() {
    final weekStartDate = _startDateMagang.add(
      Duration(days: _selectedWeekIndex * 7),
    );
    final weekEndDate = weekStartDate.add(
      const Duration(days: 6, hours: 23, minutes: 59),
    );

    setState(() {
      _filteredLogBooks = _allLogBooks.where((log) {
        // Parse tanggal dari string format YYYY-MM-DD
        try {
          final logDate = DateTime.parse(log.tanggal);
          return logDate.isAfter(
                weekStartDate.subtract(const Duration(seconds: 1)),
              ) &&
              logDate.isBefore(weekEndDate);
        } catch (e) {
          // Jika parsing gagal, gunakan createdAt sebagai fallback
          return log.createdAt.isAfter(
                weekStartDate.subtract(const Duration(seconds: 1)),
              ) &&
              log.createdAt.isBefore(weekEndDate);
        }
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor:
          isDark ? AppThemes.darkBackground : AppThemes.backgroundColor,
      appBar: CustomAppBar(
        title: 'Activities',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {
              // Contoh Notifikasi Filter (Info)
              GlobalSnackBar.show(
                'Filter fitur akan segera tersedia',
                title: 'Info',
                isInfo: true,
              );
            },
          ),
        ],
      ),
      body: ResponsiveLayout(
        mobileBody: _buildMobileLayout(isDark),
        tabletBody: _buildTabletLayout(isDark),
      ),
    );
  }

  // === LAYOUT BUILDERS ===
  Widget _buildMobileLayout(bool isDark) {
    return Stack(
      children: [
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            if (_errorMessage != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: CustomErrorWidget(
                    message: _errorMessage!,
                    onDismiss: () => setState(() => _errorMessage = null),
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ActivitiesHeader(
                  onAddActivity: () => _showActivityForm(context, null),
                  onAddLogbook: () => _showLogBookForm(context, null),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ActivitiesStatistics(
                  isMobile: true,
                  logbooks: _allLogBooks,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ActivitiesTimeline(activities: _timelineActivities),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyTabDelegate(
                isDark: isDark,
                selectedIndex: _selectedTabIndex,
                onTabSelected: (index) =>
                    setState(() => _selectedTabIndex = index),
              ),
            ),
            if (_selectedTabIndex == 1)
              SliverToBoxAdapter(child: _buildWeekFilter(isDark)),
            _buildListContent(isDark),
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: FloatingBottomNav(
            currentRoute: RouteNames.activities,
            onQRScanTap: () => NavigationHelper.navigateWithoutAnimation(
              context,
              RouteNames.qrScan,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: CustomErrorWidget(
                        message: _errorMessage!,
                        onDismiss: () => setState(() => _errorMessage = null),
                      ),
                    ),
                  ActivitiesHeader(
                    onAddActivity: () => _showActivityForm(context, null),
                    onAddLogbook: () => _showLogBookForm(context, null),
                  ),
                  const SizedBox(height: 24),
                  ActivitiesStatistics(
                    isMobile: false,
                    logbooks: _allLogBooks,
                  ),
                  const SizedBox(height: 24),
                  ActivitiesTimeline(activities: _timelineActivities),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 4,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppThemes.darkSurface : AppThemes.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppThemes.darkOutline : Colors.grey.shade200,
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        _TabButton(
                          title: 'Activity',
                          isActive: _selectedTabIndex == 0,
                          onTap: () => setState(() => _selectedTabIndex = 0),
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _TabButton(
                          title: 'Log Book',
                          isActive: _selectedTabIndex == 1,
                          onTap: () => setState(() => _selectedTabIndex = 1),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                  if (_selectedTabIndex == 1)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildWeekFilter(isDark),
                    ),
                  const Divider(height: 1),
                  Expanded(
                    child: CustomScrollView(
                      slivers: [_buildListContent(isDark)],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekFilter(bool isDark) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 8, top: 8),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _totalWeeksDuration,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = index == _selectedWeekIndex;
          final weekStart = _startDateMagang.add(Duration(days: index * 7));
          final weekEnd = weekStart.add(const Duration(days: 6));
          final dateRange =
              "${DateFormat('dd MMM').format(weekStart)} - ${DateFormat('dd MMM').format(weekEnd)}";

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedWeekIndex = index;
                _filterLogBooks();
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppThemes.primaryColor
                    : (isDark ? AppThemes.darkSurfaceElevated : Colors.white),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected
                      ? AppThemes.primaryColor
                      : (isDark ? AppThemes.darkOutline : Colors.grey.shade300),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Minggu ${index + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : (isDark
                              ? AppThemes.darkTextPrimary
                              : AppThemes.onSurfaceColor),
                    ),
                  ),
                  Text(
                    dateRange,
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected
                          ? Colors.white.withOpacity(0.9)
                          : (isDark
                              ? AppThemes.darkTextSecondary
                              : AppThemes.hintColor),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListContent(bool isDark) {
    if (_selectedTabIndex == 0) {
      // --- TAB ACTIVITY (menggunakan Logbook dengan type/status) ---
      // Filter logbook yang memiliki type atau status (dianggap sebagai Activity)
      final activityLogbooks = _allLogBooks.where((log) => 
        log.type != null || log.status != null
      ).toList();
      
      // Jika tidak ada activity dengan type/status, tampilkan semua logbook (diurutkan terbaru)
      // Urutkan berdasarkan tanggal (terbaru dulu)
      final displayLogbooks = (activityLogbooks.isNotEmpty 
          ? activityLogbooks
          : _allLogBooks).toList()
        ..sort((a, b) {
          try {
            final dateA = DateTime.parse(a.tanggal);
            final dateB = DateTime.parse(b.tanggal);
            return dateB.compareTo(dateA); // Descending order (newest first)
          } catch (e) {
            return b.createdAt.compareTo(a.createdAt);
          }
        });
      
      if (_isLoadingLogbooks) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: CircularProgressIndicator(
              color: isDark ? AppThemes.darkAccentBlue : AppThemes.primaryColor,
            ),
          ),
        );
      }
      
      return displayLogbooks.isEmpty
          ? _buildEmptyState(isDark, 'No activities found')
          : SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final logbook = displayLogbooks[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: LogBookCard(
                      log: logbook,
                      isDark: isDark,
                      onEdit: () => _showLogBookForm(context, logbook),
                      onDelete: () {
                        final deleteIndex = _allLogBooks.indexWhere((l) => l.id == logbook.id);
                        if (deleteIndex != -1) {
                          _confirmDeleteLog(context, deleteIndex);
                        }
                      },
                                                          ),
                                                        );
                                                      },
                                                      childCount: displayLogbooks.length,
              ),
            );
    } else {
      // --- TAB LOG BOOK (Filtered) ---
      if (_isLoadingLogbooks) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: CircularProgressIndicator(
              color: isDark ? AppThemes.darkAccentBlue : AppThemes.primaryColor,
            ),
          ),
        );
      }
      
      return _filteredLogBooks.isEmpty
          ? _buildEmptyState(isDark, 'Belum ada Log Book di Minggu ini')
          : SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: LogBookCard(
                    log: _filteredLogBooks[index],
                    isDark: isDark,
                    onEdit: () =>
                        _showLogBookForm(context, _filteredLogBooks[index]),
                    onDelete: () => _confirmDeleteLog(context, index),
                  ),
                ),
                childCount: _filteredLogBooks.length,
              ),
            );
    }
  }

  // === CRUD LOGIC ===

  void _showLogBookForm(BuildContext context, LogBook? existingLog) async {
    await showDialog(
      context: context,
      builder: (context) => LogBookFormDialog(
        existingLog: existingLog,
        onSave: (tanggal, kegiatan, deskripsi, durasi, type, status) async {
          try {
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            final user = authProvider.user;
            
            if (user == null) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('User not found. Please login again.'),
                    backgroundColor: AppThemes.errorColor,
                  ),
                );
              }
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
                  print('✅ Got pesertaMagangId from stored data: $pesertaMagangId');
                }
              }
              
              // Method 2: If not found, refresh profile from API (most reliable)
              if ((pesertaMagangId == null || pesertaMagangId.isEmpty) && mounted) {
                if (kDebugMode) {
                  print('🔄 Refreshing profile to get pesertaMagangId...');
                }
                await authProvider.refreshProfile();
                final refreshedUserDataStr = await StorageService.getString(AppConstants.userDataKey);
                if (refreshedUserDataStr != null) {
                  final refreshedUserData = jsonDecode(refreshedUserDataStr);
                  pesertaMagangId = refreshedUserData['pesertaMagang']?['id']?.toString();
                  if (kDebugMode && pesertaMagangId != null) {
                    print('✅ Got pesertaMagangId from refreshed profile: $pesertaMagangId');
                  }
                }
              }
              
              // Method 3: If still not found, try to get from API using userId endpoint
              if ((pesertaMagangId == null || pesertaMagangId.isEmpty) && user.id.isNotEmpty) {
                try {
                  if (kDebugMode) {
                    print('🔄 Trying to get pesertaMagangId from API endpoint...');
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
                          print('✅ Got pesertaMagangId from API endpoint: $pesertaMagangId');
                        }
                      }
                    } else if (kDebugMode) {
                      print('⚠️ API returned status ${response.statusCode}: ${response.body}');
                    }
                  }
                } catch (apiError) {
                  if (kDebugMode) {
                    print('⚠️ Error fetching pesertaMagangId from API: $apiError');
                  }
                }
              }
            } catch (e) {
              if (kDebugMode) print('Error getting pesertaMagangId: $e');
            }

            if (pesertaMagangId == null || pesertaMagangId.isEmpty) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Peserta magang ID not found. Please ensure you are registered as a participant.'),
                    backgroundColor: AppThemes.errorColor,
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
              return;
            }

            if (existingLog != null) {
              // Update logbook
              final response = await LogbookService.updateLogbook(
                id: existingLog.id,
                tanggal: tanggal,
                kegiatan: kegiatan,
                deskripsi: deskripsi,
                durasi: durasi,
                type: type?.value,
                status: status?.value,
              );

              if (response.success && response.data != null && mounted) {
                await _loadLogbooks();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Logbook berhasil diperbarui'),
                    backgroundColor: AppThemes.successColor,
                  ),
                );
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(response.message ?? 'Gagal memperbarui logbook'),
                      backgroundColor: AppThemes.errorColor,
                    ),
                  );
                }
              }
            } else {
              // Create new logbook
              final response = await LogbookService.createLogbook(
                pesertaMagangId: pesertaMagangId,
                tanggal: tanggal,
                kegiatan: kegiatan,
                deskripsi: deskripsi,
                durasi: durasi,
                type: type?.value,
                status: status?.value,
              );

              if (response.success && response.data != null && mounted) {
                await _loadLogbooks();
                setState(() {
                  _selectedTabIndex = 1;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Logbook berhasil dibuat'),
                    backgroundColor: AppThemes.successColor,
                  ),
                );
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(response.message ?? 'Gagal membuat logbook'),
                      backgroundColor: AppThemes.errorColor,
                    ),
                  );
                }
              }
            }
          } catch (e) {
            if (kDebugMode) print('Error saving logbook: $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Terjadi kesalahan: ${e.toString()}'),
                  backgroundColor: AppThemes.errorColor,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showActivityForm(BuildContext context, Activity? existingActivity) {
    // Activity sekarang menggunakan Logbook, jadi redirect ke Logbook form
    // Convert Activity ke LogBook jika ada
    LogBook? logBook;
    if (existingActivity != null) {
      // Cari logbook dengan id yang sama (jika Activity adalah Logbook)
      logBook = _allLogBooks.firstWhere(
        (log) => log.id == existingActivity.id,
        orElse: () => LogBook(
          id: existingActivity.id,
          pesertaMagangId: existingActivity.pesertaMagangId,
          tanggal: existingActivity.tanggal,
          kegiatan: existingActivity.kegiatan,
          deskripsi: existingActivity.deskripsi,
          durasi: existingActivity.durasi?.toString(),
          type: existingActivity.type,
          status: existingActivity.status,
          createdAt: existingActivity.createdAt,
          updatedAt: existingActivity.updatedAt,
        ),
      );
    }
    _showLogBookForm(context, logBook);
  }

  void _confirmDeleteLog(BuildContext context, int index) async {
    await showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: 'Hapus Log?',
        content: 'Data yang dihapus tidak dapat dikembalikan.',
        primaryButtonText: 'Hapus',
        primaryButtonColor: AppThemes.errorColor,
        secondaryButtonText: 'Batal',
        onPrimaryButtonPressed: () async {
          final itemToDelete = _filteredLogBooks[index];
          Navigator.pop(context); // Close dialog first
          
          final response = await LogbookService.deleteLogbook(itemToDelete.id);
          
          if (response.success && mounted) {
            await _loadLogbooks();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Logbook berhasil dihapus'),
                backgroundColor: AppThemes.successColor,
              ),
            );
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(response.message ?? 'Gagal menghapus logbook'),
                  backgroundColor: AppThemes.errorColor,
                ),
              );
            }
          }
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, String message) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: AppThemes.hintColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color:
                    isDark ? AppThemes.darkTextSecondary : AppThemes.hintColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StickyTabDelegate extends SliverPersistentHeaderDelegate {
  final bool isDark;
  final int selectedIndex;
  final Function(int) onTabSelected;

  _StickyTabDelegate({
    required this.isDark,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(
      child: Container(
        color: isDark ? AppThemes.darkBackground : AppThemes.backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            _TabButton(
              title: 'Recent Activities',
              isActive: selectedIndex == 0,
              onTap: () => onTabSelected(0),
              isDark: isDark,
            ),
            const SizedBox(width: 12),
            _TabButton(
              title: 'Log Books',
              isActive: selectedIndex == 1,
              onTap: () => onTabSelected(1),
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  @override
  double get minExtent => 65.0;
  @override
  double get maxExtent => 65.0;
  @override
  bool shouldRebuild(_StickyTabDelegate oldDelegate) =>
      selectedIndex != oldDelegate.selectedIndex ||
      isDark != oldDelegate.isDark;
}

class _TabButton extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;
  final bool isDark;
  const _TabButton({
    required this.title,
    required this.isActive,
    required this.onTap,
    required this.isDark,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppThemes.primaryColor
              : (isDark ? AppThemes.darkSurface : Colors.transparent),
          borderRadius: BorderRadius.circular(20),
          border: isActive || isDark
              ? null
              : Border.all(color: AppThemes.hintColor.withOpacity(0.3)),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive
                ? Colors.white
                : (isDark ? AppThemes.darkTextSecondary : AppThemes.hintColor),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
