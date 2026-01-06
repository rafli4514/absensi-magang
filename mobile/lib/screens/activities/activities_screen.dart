import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
import '../../utils/ui_utils.dart';
import '../../widgets/activities_header.dart';
import '../../widgets/activities_statistics.dart';
import '../../widgets/activities_timeline.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/floating_bottom_nav.dart';
import '../../widgets/loading_indicator.dart';
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

  List<LogBook> _allLogBooks = [];
  List<LogBook> _filteredLogBooks = [];
  final List<TimelineActivity> _timelineActivities = [];
  bool _isLoadingLogbooks = false;

  @override
  void initState() {
    super.initState();
    _initializeStartDate();
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
        _startDateMagang = DateTime.now().subtract(const Duration(days: 21));
      }
    } else {
      _startDateMagang = DateTime.now().subtract(const Duration(days: 21));
    }

    final now = DateTime.now();
    final daysDiff = now.difference(_startDateMagang).inDays;
    _selectedWeekIndex =
        (daysDiff / 7).floor().clamp(0, _totalWeeksDuration - 1);
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
        final response = await LogbookService.getAllLogbook(
          pesertaMagangId: pesertaMagangId,
          limit: 500,
        );

        if (mounted && response.success && response.data != null) {
          final sortedLogbooks = List<LogBook>.from(response.data!);
          sortedLogbooks.sort((a, b) {
            try {
              final dateA = DateTime.parse(a.tanggal);
              final dateB = DateTime.parse(b.tanggal);
              return dateB.compareTo(dateA);
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
          if (mounted) {
            setState(() {
              _allLogBooks = [];
              _isLoadingLogbooks = false;
            });
            _filterLogBooks();
            GlobalSnackBar.show(
              response.message ?? 'Gagal memuat data logbook',
              title: 'Gagal Memuat',
              isError: true,
            );
          }
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
        GlobalSnackBar.show(
          'Gagal terhubung ke server',
          title: 'Koneksi Error',
          isError: true,
          icon: Icons.wifi_off_rounded,
        );
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
        try {
          final logDate = DateTime.parse(log.tanggal);
          return logDate.isAfter(
            weekStartDate.subtract(const Duration(seconds: 1)),
          ) &&
              logDate.isBefore(weekEndDate);
        } catch (e) {
          return log.createdAt.isAfter(
            weekStartDate.subtract(const Duration(seconds: 1)),
          ) &&
              log.createdAt.isBefore(weekEndDate);
        }
      }).toList();
    });
  }

  // --- HELPER UNTUK NAVIGASI QR ---
  Future<void> _handleQRScan() async {
    // Gunakan pushNamed agar bisa 'Back', bukan pushReplacement
    final result = await Navigator.pushNamed(context, RouteNames.qrScan);

    // Jika result sukses (ada data absensi), pindah ke Home
    if (result != null && result is Map && result['success'] == true) {
      if (mounted) {
        // Pindah ke Home tanpa animasi (seperti tab switch)
        NavigationHelper.navigateWithoutAnimation(context, RouteNames.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor:
      isDark ? AppThemes.darkBackground : AppThemes.backgroundColor,
      appBar: CustomAppBar(
        title: 'Aktivitas',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {
              GlobalSnackBar.show(
                'Fitur filter segera hadir',
                title: 'Info',
                isInfo: true,
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // CONTENT LAYER
          ResponsiveLayout(
            mobileBody: _buildMobileLayout(isDark),
            tabletBody: _buildTabletLayout(isDark),
          ),

          // NAVIGATION LAYER
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingBottomNav(
              currentRoute: RouteNames.activities,
              onQRScanTap: _handleQRScan, // MENGGUNAKAN LOGIKA BARU
            ),
          ),
        ],
      ),
    );
  }

  // === LAYOUT BUILDERS ===
  Widget _buildMobileLayout(bool isDark) {
    return CustomScrollView(
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
                          title: 'Aktivitas Terbaru',
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
      height: 60,
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
                  const SizedBox(height: 2),
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
      final activityLogbooks = _allLogBooks
          .where((log) => log.type != null || log.status != null)
          .toList();

      final displayLogbooks = (activityLogbooks.isNotEmpty
          ? activityLogbooks
          : _allLogBooks)
          .toList()
        ..sort((a, b) {
          try {
            final dateA = DateTime.parse(a.tanggal);
            final dateB = DateTime.parse(b.tanggal);
            return dateB.compareTo(dateA);
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
          ? _buildEmptyState(
          isDark, 'Tidak ada aktivitas ditemukan')
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
                  final deleteIndex =
                  _allLogBooks.indexWhere((l) => l.id == logbook.id);
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
          ? _buildEmptyState(
          isDark, 'Belum ada Log Book di Minggu ini')
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

  void _showLogBookForm(BuildContext context, LogBook? existingLog) async {
    await showDialog(
      context: context,
      builder: (context) => LogBookFormDialog(
        existingLog: existingLog,
        onSave:
            (tanggal, kegiatan, deskripsi, durasi, type, status, foto) async {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: LoadingIndicator()),
          );

          try {
            final authProvider =
            Provider.of<AuthProvider>(context, listen: false);
            final user = authProvider.user;

            if (user == null) {
              if (mounted) {
                Navigator.pop(context); // Tutup loading
                GlobalSnackBar.show(
                  'User tidak ditemukan. Silakan login kembali.',
                  title: 'Auth Error',
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
              if (pesertaMagangId == null && user.id.isNotEmpty) {
                await authProvider.refreshProfile(); // Refresh if missing
                final refreshedUserDataStr =
                await StorageService.getString(AppConstants.userDataKey);
                if (refreshedUserDataStr != null) {
                  final refreshedUserData = jsonDecode(refreshedUserDataStr);
                  pesertaMagangId =
                      refreshedUserData['pesertaMagang']?['id']?.toString();
                }
              }
            } catch (e) {}

            if (pesertaMagangId == null) {
              if (mounted) {
                Navigator.pop(context); // Tutup loading
                GlobalSnackBar.show(
                  'ID Peserta tidak ditemukan',
                  title: 'Error',
                  isError: true,
                );
              }
              return;
            }

            final response = await LogbookService.createLogbook(
              pesertaMagangId: pesertaMagangId,
              tanggal: tanggal,
              kegiatan: kegiatan,
              deskripsi: deskripsi,
              durasi: durasi,
              type: type?.value,
              status: status?.value,
              foto: foto,
            );

            if (mounted) {
              Navigator.pop(context); // Tutup loading
              if (response.success) {
                _loadLogbooks(); // Refresh data
                GlobalSnackBar.show(
                  'Logbook berhasil disimpan',
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
              Navigator.pop(context); // Tutup loading
              GlobalSnackBar.show('Terjadi kesalahan: $e',
                  title: 'Error', isError: true);
            }
          }
        },
      ),
    );
  }

  void _showActivityForm(BuildContext context, Activity? existingActivity) {
    LogBook? logBook;
    if (existingActivity != null) {
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
          Navigator.pop(context);

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: LoadingIndicator()),
          );

          final response = await LogbookService.deleteLogbook(itemToDelete.id);

          if (mounted) {
            Navigator.pop(context); // Tutup loading
            if (response.success) {
              await _loadLogbooks();
              GlobalSnackBar.show(
                'Logbook berhasil dihapus',
                title: 'Sukses',
                isSuccess: true,
              );
            } else {
              GlobalSnackBar.show(
                response.message ?? 'Gagal menghapus logbook',
                title: 'Gagal',
                isError: true,
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
              title: 'Aktivitas Terbaru',
              isActive: selectedIndex == 0,
              onTap: () => onTabSelected(0),
              isDark: isDark,
            ),
            const SizedBox(width: 12),
            _TabButton(
              title: 'Log Book',
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