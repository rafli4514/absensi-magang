import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/activity.dart';
import '../../models/logbook.dart';
import '../../models/timeline_activity.dart';
import '../../navigation/route_names.dart';
import '../../providers/theme_provider.dart';
import '../../themes/app_themes.dart';
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

  // Dummy Data LogBook
  final List<LogBook> _allLogBooks = [
    LogBook(
      id: '1',
      title: 'Pemasangan Kabel Fiber (Minggu 1)',
      content: 'Membantu teknisi senior memasang jalur baru.',
      location: 'Perumahan Griya Indah',
      mentorName: 'Pak Budi',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    // ... data dummy lainnya
  ];

  List<LogBook> _filteredLogBooks = [];
  final List<Activity> _activities = [];
  final List<TimelineActivity> _timelineActivities = [
    TimelineActivity(
      time: '08:15',
      activity: 'Check-in pagi hari',
      status: 'Selesai',
      location: 'Kantor PLN UID',
    ),
    // ... timeline dummy
  ];

  @override
  void initState() {
    super.initState();
    _startDateMagang = DateTime.now().subtract(const Duration(days: 21));
    _selectedWeekIndex = 3;
    _filterLogBooks();
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
        return log.createdAt.isAfter(
              weekStartDate.subtract(const Duration(seconds: 1)),
            ) &&
            log.createdAt.isBefore(weekEndDate);
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
                child: ActivitiesStatistics(isMobile: true),
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
                  const ActivitiesStatistics(isMobile: false),
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
      return _activities.isEmpty
          ? _buildEmptyState(isDark, 'No activities found')
          : SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: InkWell(
                    onTap: () => _showActivityForm(context, _activities[index]),
                    borderRadius: BorderRadius.circular(12),
                    child: ActivityCard(
                      activity: _activities[index],
                      isDark: isDark,
                    ),
                  ),
                ),
                childCount: _activities.length,
              ),
            );
    } else {
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

  void _showLogBookForm(BuildContext context, LogBook? existingLog) {
    showDialog(
      context: context,
      builder: (context) => LogBookFormDialog(
        existingLog: existingLog,
        onSave: (title, location, mentor, content) {
          setState(() {
            if (existingLog != null) {
              final index = _allLogBooks.indexWhere(
                (log) => log.id == existingLog.id,
              );
              if (index != -1) {
                _allLogBooks[index] = existingLog.copyWith(
                  title: title,
                  location: location,
                  mentorName: mentor,
                  content: content,
                );
              }
            } else {
              _allLogBooks.insert(
                0,
                LogBook(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: title,
                  location: location,
                  mentorName: mentor,
                  content: content,
                  createdAt: DateTime.now(),
                ),
              );
              _selectedTabIndex = 1;
            }
            _filterLogBooks();
          });

          // NOTIFIKASI BARU: SUKSES
          GlobalSnackBar.show(
            existingLog == null
                ? 'Logbook berhasil ditambahkan'
                : 'Logbook berhasil diperbarui',
            title: 'Berhasil',
            isSuccess: true,
          );
        },
      ),
    );
  }

  void _showActivityForm(BuildContext context, Activity? existingActivity) {
    showDialog(
      context: context,
      builder: (context) => ActivityFormDialog(
        existingActivity: existingActivity,
        onSave: (kegiatan, deskripsi, date, type, status) {
          setState(() {
            if (existingActivity != null) {
              final index = _activities.indexWhere(
                (a) => a.id == existingActivity.id,
              );
              if (index != -1) {
                _activities[index] = Activity(
                  id: existingActivity.id,
                  pesertaMagangId: existingActivity.pesertaMagangId,
                  tanggal: DateFormat('yyyy-MM-dd').format(date),
                  kegiatan: kegiatan,
                  deskripsi: deskripsi,
                  type: type,
                  status: status,
                  createdAt: existingActivity.createdAt,
                  updatedAt: DateTime.now(),
                );
              }
            } else {
              _activities.insert(
                0,
                Activity(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  pesertaMagangId: '1',
                  tanggal: DateFormat('yyyy-MM-dd').format(date),
                  kegiatan: kegiatan,
                  deskripsi: deskripsi,
                  type: type,
                  status: status,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
              );
              _selectedTabIndex = 0;
            }
          });

          // NOTIFIKASI BARU: SUKSES
          GlobalSnackBar.show(
            existingActivity == null
                ? 'Aktivitas berhasil ditambahkan'
                : 'Aktivitas berhasil diperbarui',
            title: 'Berhasil',
            isSuccess: true,
          );
        },
      ),
    );
  }

  void _confirmDeleteLog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: 'Hapus Log?',
        content: 'Data yang dihapus tidak dapat dikembalikan.',
        primaryButtonText: 'Hapus',
        primaryButtonColor: AppThemes.errorColor,
        secondaryButtonText: 'Batal',
        onPrimaryButtonPressed: () {
          final itemToDelete = _filteredLogBooks[index];
          setState(() {
            _allLogBooks.removeWhere(
              (element) => element.id == itemToDelete.id,
            );
            _filterLogBooks();
          });
          Navigator.pop(context);

          // NOTIFIKASI BARU: DELETE SUKSES
          GlobalSnackBar.show(
            'Logbook berhasil dihapus',
            title: 'Dihapus',
            isSuccess: true,
          );
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
