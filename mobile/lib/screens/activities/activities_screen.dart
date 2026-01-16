import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/activity.dart';
import '../../models/attendance.dart'; 
import '../../models/logbook.dart';
import '../../navigation/route_names.dart';
import '../../providers/auth_provider.dart';
import '../../providers/logbook_provider.dart';
import '../../services/attendance_service.dart'; 
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
  // Local state only for UI Tabs/Filter
  int _selectedTabIndex = 0; // 0: Timeline, 1: Logbook List
  
  // Statistics Data (Still fetched manually for now or move to Provider later)
  List<Attendance> _allAttendance = [];
  bool _isLoadingStats = false;
  final int _totalWeeksDuration = 16;

  @override
  void initState() {
    super.initState();
    // Defer data loading until after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  void _initializeData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final logbookProvider = Provider.of<LogbookProvider>(context, listen: false);
    final user = authProvider.user;
    
    // 1. Set Start Date
    if (user?.tanggalMulai != null) {
      try {
        logbookProvider.setStartDate(DateTime.parse(user!.tanggalMulai!));
      } catch (e) {
        logbookProvider.setStartDate(DateTime.now());
      }
    } else {
      logbookProvider.setStartDate(DateTime.now());
    }

    // 2. Load Logbooks
    final pesertaId = user?.profileId ?? '';
    if (pesertaId.isNotEmpty) {
       logbookProvider.fetchLogbooks(pesertaId);
       _loadAttendanceStats(pesertaId);
    }
  }

  Future<void> _loadAttendanceStats(String pesertaId) async {
    if (!mounted) return;
    setState(() => _isLoadingStats = true);
    try {
      final attendanceResponse = await AttendanceService.getAllAttendance(
          pesertaMagangId: pesertaId, limit: 100);
      if (attendanceResponse.success && attendanceResponse.data != null) {
        setState(() {
          _allAttendance = attendanceResponse.data!;
        });
      }
    } catch (e) {
      debugPrint("Error loading attendance stats: $e");
    } finally {
      if (mounted) setState(() => _isLoadingStats = false);
    }
  }

  // --- LOGIC FORM & DELETE ---
  
  void _showLogBookForm(BuildContext context, LogBook? log) {
    showDialog(
      context: context,
      builder: (dialogContext) => LogBookFormDialog(
        existingLog: log,
        onSave: (tanggal, kegiatan, deskripsi, durasi, type, status, foto) async {
          // 1. Close Form Dialog
          Navigator.of(dialogContext).pop();
          
          // 2. Validate User
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          final logbookProvider = Provider.of<LogbookProvider>(context, listen: false);
          final pesertaId = authProvider.user?.profileId ?? '';

          if (pesertaId.isEmpty) {
             GlobalSnackBar.show('Error: ID Peserta tidak ditemukan', isError: true);
             return;
          }

          // 3. Call Provider (Handles API + State)
          // Fix: 'foto' is already XFile? now
          
          bool success = false;
          if (log == null) {
             success = await logbookProvider.addLogbook(
                pesertaId: pesertaId,
                tanggal: tanggal,
                kegiatan: kegiatan,
                deskripsi: deskripsi,
                durasi: durasi,
                type: type?.value,
                status: status?.value,
                foto: foto, // Pass directly
             );
          } else {
             success = await logbookProvider.updateLogbook(
                log: log,
                tanggal: tanggal,
                kegiatan: kegiatan,
                deskripsi: deskripsi,
                durasi: durasi,
                type: type?.value,
                status: status?.value,
                foto: foto, // Pass directly
             );
          }

          if (success) {
            GlobalSnackBar.show(
              log == null ? 'Logbook berhasil ditambahkan' : 'Logbook diperbarui', 
              isSuccess: true
            );
          } else {
            GlobalSnackBar.show(
              'Gagal menyimpan: ${logbookProvider.errorMessage}', 
              isError: true
            );
          }
        },
      ),
    );
  }

  void _showActivityForm(BuildContext context, Activity? activity) {
    showDialog(
      context: context,
      builder: (dialogContext) => ActivityFormDialog(
        existingActivity: activity,
        onSave: (kegiatan, deskripsi, tanggal, type, status, foto) async {
          Navigator.of(dialogContext).pop();
          
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          final logbookProvider = Provider.of<LogbookProvider>(context, listen: false);
          final pesertaId = authProvider.user?.profileId ?? '';

          if (pesertaId.isEmpty) {
             GlobalSnackBar.show('Error: ID Peserta tidak ditemukan', isError: true);
             return;
          }

          final dateStr = DateFormat('yyyy-MM-dd').format(tanggal);
          // Fix: foto is already XFile?
          
          if (activity == null) {
            bool success = await logbookProvider.addLogbook(
                pesertaId: pesertaId,
                tanggal: dateStr,
                kegiatan: kegiatan,
                deskripsi: deskripsi,
                type: type.value,
                status: status.value,
                foto: foto, // Pass directly
            );
            
            if (success) {
               GlobalSnackBar.show('Aktivitas berhasil ditambahkan', isSuccess: true);
            } else {
               GlobalSnackBar.show(logbookProvider.errorMessage ?? 'Gagal', isError: true);
            }
          } else {
             GlobalSnackBar.show('Edit via Timeline belum didukung sepenuhnya', isInfo: true);
          }
        },
      ),
    );
  }

  void _confirmDeleteLog(BuildContext context, LogBook log) {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: 'Hapus Logbook?',
        content: 'Anda yakin ingin menghapus kegiatan "${log.kegiatan}"?',
        primaryButtonText: 'Hapus',
        primaryButtonColor: Theme.of(context).colorScheme.error,
        onPrimaryButtonPressed: () async {
          Navigator.pop(context);
          
          final logbookProvider = Provider.of<LogbookProvider>(context, listen: false);
          bool success = await logbookProvider.deleteLogbook(log.id);
          
          if (success) {
            GlobalSnackBar.show('Logbook dihapus', isSuccess: true);
          } else {
            GlobalSnackBar.show('Gagal: ${logbookProvider.errorMessage}', isError: true);
          }
        },
        secondaryButtonText: 'Batal',
      ),
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
            icon: Icon(Icons.download, color: colorScheme.onSurface),
            onPressed: () => _showExportOptions(context),
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.onSurface),
            onPressed: () { 
                _initializeData();
                GlobalSnackBar.show("Refreshing...", isInfo: true);
            },
          ),
        ],
      ),
      drawer: null, // No Drawer here as we use Bottom Nav
      body: Stack(
        children: [
          Consumer<LogbookProvider>(
            builder: (context, provider, child) {
              
              // Handle Full Page Loading ONLY on initial load if needed, 
              // but standard is to show skeleton or loader inside list.
              // Here we just overlay if provider.isLoading is true? 
              // Better: Show loading indicator in list part.
              
              return ResponsiveLayout(
                mobileBody: _buildMobileLayout(provider),
                tabletBody: _buildMobileLayout(provider), // Reuse for now
              );
            },
          ),
           // Loading Overlay for CRUD operations
           Consumer<LogbookProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return Container(
                  color: Colors.black12,
                  child: const Center(child: LoadingIndicator()),
                );
              }
              return const SizedBox.shrink();
            },
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

  Widget _buildMobileLayout(LogbookProvider provider) {
    // Week calculation for charts using provider's start date
    // Note: Provider doesn't expose _startDate directly via getter, 
    // but we can assume provider methods handle filter logic.
    // For the UI statistics "current week", we might need helper.
    // Let's assume Statistics widget needs raw list.
    
    return RefreshIndicator(
      onRefresh: () async {
         _initializeData();
      },
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          if (provider.errorMessage != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: CustomErrorWidget(
                  message: provider.errorMessage!,
                  onDismiss: () => _initializeData(), // Retry?
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
                logbooks: provider.allLogBooks,
                attendanceList: _allAttendance,
                currentWeekStart: DateTime.now(), // Fallback/Minor, mainly for visual
                currentWeekEnd: DateTime.now().add(const Duration(days: 6)),
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
                child: ActivitiesTimeline(activities: provider.activities),
              ),
            ),
          if (_selectedTabIndex == 1) ...[
            SliverToBoxAdapter(child: _buildWeekFilter(provider)),
            _buildListContent(provider),
          ],
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }

  Widget _buildWeekFilter(LogbookProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedIndex = provider.selectedWeekIndex;

    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 8, top: 8),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _totalWeeksDuration,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
           // Visual date logic could be improved by asking provider for week range
           // For now just showing week numbers is safe.
           final isSelected = index == selectedIndex;
           return GestureDetector(
            onTap: () => provider.setWeekIndex(index),
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
              child: Center(
                child: Text(
                  'Minggu ${index + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListContent(LogbookProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;
    final listData = provider.filteredLogBooks;

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
            onDelete: () => _confirmDeleteLog(context, listData[index]),
          ),
        );
      }, childCount: listData.length),
    );
  }

  void _showExportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Export Data", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text("Export Logbook (PDF)"),
                onTap: () {
                  Navigator.pop(context);
                  _handleExport('logbook', 'pdf');
                },
              ),
              ListTile(
                leading: const Icon(Icons.table_chart, color: Colors.green),
                title: const Text("Export Logbook (CSV)"),
                onTap: () {
                  Navigator.pop(context);
                  _handleExport('logbook', 'csv');
                },
              ),
               ListTile(
                leading: const Icon(Icons.history, color: Colors.blue),
                title: const Text("Export Activity Log (CSV)"),
                onTap: () {
                  Navigator.pop(context);
                  _handleExport('activity', 'csv');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleExport(String type, String format) async {
    final provider = Provider.of<LogbookProvider>(context, listen: false);
    try {
      GlobalSnackBar.show("Mengunduh export...", isInfo: true);
      
      await provider.exportData(type: type, format: format);
      
      GlobalSnackBar.show("Download berhasil! Membuka file...", isSuccess: true);
    } catch (e) {
       GlobalSnackBar.show("Gagal export: $e", isError: true);
    }
  }
}


// ... _StickyTabDelegate and _TabButton remain unchanged ...
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
