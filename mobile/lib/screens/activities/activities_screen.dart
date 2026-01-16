import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/activity.dart';
import '../../models/attendance.dart'; 
import '../../models/logbook.dart';
import '../../models/timeline_activity.dart';
import '../../navigation/route_names.dart';
import '../../providers/auth_provider.dart';
import '../../services/attendance_service.dart'; 
import '../../services/logbook_service.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/responsive_layout.dart';
import '../../utils/ui_utils.dart';
import '../../widgets/activities_header.dart';
import '../../widgets/activities_statistics.dart';
import '../../widgets/activities_timeline.dart';
import '../../widgets/activity_form_dialog.dart';
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
  int _selectedTabIndex = 0; // 0: Timeline, 1: Logbook List
  int _selectedWeekIndex = 0;
  late DateTime _startDateMagang;
  final int _totalWeeksDuration = 16;

  List<LogBook> _allLogBooks = [];
  List<LogBook> _filteredLogBooks = [];
  List<Attendance> _allAttendance = []; // Store attendance data
  List<TimelineActivity> _timelineActivities = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeStartDate();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _initializeStartDate() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user?.tanggalMulai != null) {
      try {
        _startDateMagang = DateTime.parse(user!.tanggalMulai!);
      } catch (e) {
        _startDateMagang = DateTime.now().subtract(const Duration(days: 1));
      }
    } else {
      _startDateMagang = DateTime.now();
    }
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;
      final pesertaId = user?.idPesertaMagang ?? '';

      if (pesertaId.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      // 1. Fetch Logbooks
      final logbookResponse = await LogbookService.getAllLogbook(
          pesertaMagangId: pesertaId, limit: 100);

      // 2. Fetch Attendance (Untuk Pie Chart)
      final attendanceResponse = await AttendanceService.getAllAttendance(
          pesertaMagangId: pesertaId, limit: 100);

      if (logbookResponse.success && logbookResponse.data != null) {
        _allLogBooks = logbookResponse.data!;

        // Convert Logbook ke Timeline Activity
        _timelineActivities = _allLogBooks.map((log) {
          return TimelineActivity(
              time: log.tanggal,
              activity: log.kegiatan,
              status: log.status?.displayName ?? 'Pending',
              location: '-');
        }).toList();

        _timelineActivities.sort((a, b) => b.time.compareTo(a.time));
      }

      if (attendanceResponse.success && attendanceResponse.data != null) {
        _allAttendance = attendanceResponse.data!;
      }

      if (!logbookResponse.success) {
        setState(() => _errorMessage = logbookResponse.message);
      } else {
        _filterLogBooks(); // Filter awal
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterLogBooks() {
    final weekStart =
        _startDateMagang.add(Duration(days: _selectedWeekIndex * 7));
    final weekEnd =
        weekStart.add(const Duration(days: 6, hours: 23, minutes: 59));

    setState(() {
      _filteredLogBooks = _allLogBooks.where((log) {
        try {
          final logDate = DateTime.parse(log.tanggal);
          return logDate
                  .isAfter(weekStart.subtract(const Duration(seconds: 1))) &&
              logDate.isBefore(weekEnd);
        } catch (_) {
          return false;
        }
      }).toList();

      _filteredLogBooks.sort((a, b) => b.tanggal.compareTo(a.tanggal));
    });
  }

  // --- LOGIC FORM & DELETE (Sama seperti sebelumnya) ---
  void _showLogBookForm(BuildContext context, LogBook? log) {
    showDialog(
      context: context,
      builder: (context) => LogBookFormDialog(
        existingLog: log,
        onSave:
            (tanggal, kegiatan, deskripsi, durasi, type, status, foto) async {
          Navigator.pop(context);
          _showLoadingDialog();
          try {
            final authProvider =
                Provider.of<AuthProvider>(context, listen: false);
            final pesertaId = authProvider.user?.idPesertaMagang ?? '';

            if (log == null) {
              await LogbookService.createLogbook(
                pesertaMagangId: pesertaId,
                tanggal: tanggal,
                kegiatan: kegiatan,
                deskripsi: deskripsi,
                durasi: durasi,
                type: type?.value,
                status: status?.value,
                foto: foto,
              );
              GlobalSnackBar.show('Logbook berhasil ditambahkan',
                  isSuccess: true);
            } else {
              await LogbookService.updateLogbook(
                id: log.id,
                tanggal: tanggal,
                kegiatan: kegiatan,
                deskripsi: deskripsi,
                durasi: durasi,
                type: type?.value,
                status: status?.value,
              );
              GlobalSnackBar.show('Logbook berhasil diperbarui',
                  isSuccess: true);
            }
            if (mounted) {
              Navigator.pop(context);
              _loadData();
            }
          } catch (e) {
            if (mounted) {
              Navigator.pop(context);
              GlobalSnackBar.show('Gagal menyimpan: $e', isError: true);
            }
          }
        },
      ),
    );
  }

  void _showActivityForm(BuildContext context, Activity? activity) {
    showDialog(
      context: context,
      builder: (context) => ActivityFormDialog(
        existingActivity: activity,
        onSave: (kegiatan, deskripsi, tanggal, type, status, foto) async {
          Navigator.pop(context);
          _showLoadingDialog();
          try {
            final authProvider =
                Provider.of<AuthProvider>(context, listen: false);
            final pesertaId = authProvider.user?.idPesertaMagang ?? '';
            final dateStr = DateFormat('yyyy-MM-dd').format(tanggal);

            if (activity == null) {
              await LogbookService.createLogbook(
                pesertaMagangId: pesertaId,
                tanggal: dateStr,
                kegiatan: kegiatan,
                deskripsi: deskripsi,
                type: type.value,
                status: status.value,
                foto: foto,
              );
              GlobalSnackBar.show('Aktivitas berhasil ditambahkan',
                  isSuccess: true);
            } else {
              // Jika Activity dianggap Logbook, kita bisa update by ID jika Activity punya ID
              // Namun model Activity saat ini mungkin berbeda.
              // Asumsi: Activity yang diedit berasal dari list Logbook yang di-cast.
              // Jika struktur terpisah, kita perlu penyesuaian.
              // Untuk saat ini, fitur "Edit" dari form ini hanya support Create baru
              // karena Timeline biasanya read-only atau edit detail Logbook.
              // Fallback: Create New (atau implement update jika ID tersedia di Activity)
              
              // Note: Karena parameter existingActivity bertipe Activity? tapi kita save ke Logbook,
              // ini menyiratkan penyatuan fitur.
              // Jika user mengedit item "Activity", idealnya kita butuh ID logbooknya.
              // Di kode saat ini, timelineActivities dibangun dari Logbook.
              // Tapi 'Activity' model class mungkin tidak punya ID yang sama dengan Logbook.
              
              // SEMENTARA: Kita treat Activity form sebagai "Input Logbook versi Ringkas"
              // Jadi selalu Create New jika null.
              // Jika tidak null, kita tampilkan info belum support edit via form ini (atau implement jika ID ada)
               GlobalSnackBar.show('Edit via Timeline belum didukung sepenuhnya', isInfo: true);
            }
            
            if (mounted) {
              Navigator.pop(context); // Close loading
              _loadData(); // Refresh data
            }
          } catch (e) {
            if (mounted) {
              Navigator.pop(context); // Close loading
              GlobalSnackBar.show('Gagal menyimpan aktivitas: $e',
                  isError: true);
            }
          }
        },
      ),
    );
  }

  void _confirmDeleteLog(BuildContext context, int index) {
    final logToDelete = _filteredLogBooks[index];
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: 'Hapus Logbook?',
        content:
            'Anda yakin ingin menghapus kegiatan "${logToDelete.kegiatan}"?',
        primaryButtonText: 'Hapus',
        primaryButtonColor: Theme.of(context).colorScheme.error,
        onPrimaryButtonPressed: () async {
          Navigator.pop(context);
          _showLoadingDialog();
          try {
            await LogbookService.deleteLogbook(logToDelete.id);
            if (mounted) {
              Navigator.pop(context);
              GlobalSnackBar.show('Logbook dihapus', isSuccess: true);
              _loadData();
            }
          } catch (e) {
            if (mounted) {
              Navigator.pop(context);
              GlobalSnackBar.show('Gagal menghapus: $e', isError: true);
            }
          }
        },
        secondaryButtonText: 'Batal',
      ),
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: LoadingIndicator()),
    );
  }

  Future<void> _handleQRScan() async {
    NavigationHelper.navigateWithoutAnimation(context, RouteNames.qrScan);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Aktivitas',
        showBackButton: false,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list_rounded, color: colorScheme.onSurface),
            onPressed: () {
              GlobalSnackBar.show('Filter mingguan aktif di tab Logbook',
                  isInfo: true);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          ResponsiveLayout(
            mobileBody: _buildMobileLayout(),
            tabletBody: _buildTabletLayout(),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingBottomNav(
              currentRoute: RouteNames.activities,
              onQRScanTap: _handleQRScan,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    // Current week calculation for charts
    final weekStart =
        _startDateMagang.add(Duration(days: _selectedWeekIndex * 7));
    final weekEnd = weekStart.add(const Duration(days: 6));

    return RefreshIndicator(
      onRefresh: _loadData,
      child: CustomScrollView(
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
                attendanceList: _allAttendance, // KIRIM DATA ABSENSI
                currentWeekStart: weekStart, // KIRIM MINGGU AKTIF
                currentWeekEnd: weekEnd,
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyTabDelegate(
              selectedIndex: _selectedTabIndex,
              onTabSelected: (index) =>
                  setState(() => _selectedTabIndex = index),
            ),
          ),
          if (_selectedTabIndex == 0)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ActivitiesTimeline(activities: _timelineActivities),
              ),
            ),
          if (_selectedTabIndex == 1) ...[
            SliverToBoxAdapter(child: _buildWeekFilter()),
            _buildListContent(),
          ],
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }

  // Tablet layout implementation would mirror mobile but with responsive flex...
  Widget _buildTabletLayout() {
    // Simplified for brevity, similar structure to mobile but side-by-side
    return _buildMobileLayout();
  }

  Widget _buildWeekFilter() {
    final colorScheme = Theme.of(context).colorScheme;

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
            onTap: () => setState(() {
              _selectedWeekIndex = index;
              _filterLogBooks();
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.outline.withOpacity(0.2),
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
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    dateRange,
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected
                          ? colorScheme.onPrimary.withOpacity(0.9)
                          : colorScheme.onSurfaceVariant,
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

  Widget _buildListContent() {
    final colorScheme = Theme.of(context).colorScheme;
    if (_isLoading) {
      return SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()));
    }

    final listData = _filteredLogBooks;

    if (listData.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inbox_outlined, size: 48, color: colorScheme.outline),
              const SizedBox(height: 16),
              Text('Tidak ada logbook minggu ini',
                  style: TextStyle(color: colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: LogBookCard(
            log: listData[index],
            onEdit: () => _showLogBookForm(context, listData[index]),
            onDelete: () => _confirmDeleteLog(context, index),
          ),
        );
      }, childCount: listData.length),
    );
  }
}

class _StickyTabDelegate extends SliverPersistentHeaderDelegate {
  final int selectedIndex;
  final Function(int) onTabSelected;

  _StickyTabDelegate(
      {required this.selectedIndex, required this.onTabSelected});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Expanded(
              child: _TabButton(
                  title: 'Timeline',
                  isActive: selectedIndex == 0,
                  onTap: () => onTabSelected(0)),
            ),
            Expanded(
              child: _TabButton(
                  title: 'Log Book',
                  isActive: selectedIndex == 1,
                  onTap: () => onTabSelected(1)),
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
      selectedIndex != oldDelegate.selectedIndex;
}

class _TabButton extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton(
      {required this.title, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? colorScheme.surfaceContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isActive
              ? [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2))
                ]
              : [],
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color:
                  isActive ? colorScheme.primary : colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
