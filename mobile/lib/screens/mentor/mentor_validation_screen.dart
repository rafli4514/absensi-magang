import 'package:flutter/material.dart';

import '../../models/enum/activity_status.dart';
import '../../navigation/route_names.dart';
import '../../services/leave_service.dart';
import '../../services/logbook_service.dart';
import '../../themes/app_themes.dart';
import '../../utils/ui_utils.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/mentor_bottom_nav.dart';

class MentorValidationScreen extends StatefulWidget {
  const MentorValidationScreen({super.key});

  @override
  State<MentorValidationScreen> createState() => _MentorValidationScreenState();
}

class _MentorValidationScreenState extends State<MentorValidationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  List<dynamic> _logbooks = [];
  List<dynamic> _leaves = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // Load Logbooks (Pending)
      final logbookRes = await LogbookService.getAllLogbook(limit: 100);

      // Load Leaves (Pending) -> Ini yang memuat data izin
      final leaveRes = await LeaveService.getLeaves(status: 'PENDING');

      if (mounted) {
        setState(() {
          _isLoading = false;

          if (logbookRes.success && logbookRes.data != null) {
            _logbooks = logbookRes.data!
                .where((l) =>
                    l.status == ActivityStatus.pending ||
                    l.status == ActivityStatus.inProgress)
                .toList();
          }

          if (leaveRes.success && leaveRes.data != null) {
            _leaves = leaveRes.data!;
          } else {
            _leaves = []; // Pastikan list kosong jika gagal/null
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        GlobalSnackBar.show('Gagal memuat data: $e', isError: true);
      }
    }
  }

  Future<void> _updateLogbookStatus(String id, ActivityStatus status) async {
    final res = await LogbookService.updateLogbook(
      id: id,
      status: status.value,
    );

    if (res.success) {
      GlobalSnackBar.show('Status logbook diperbarui', isSuccess: true);
      _loadData();
    } else {
      GlobalSnackBar.show('Gagal memperbarui status', isError: true);
    }
  }

  Future<void> _processLeave(String id, bool approve) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    bool success;
    if (approve) {
      success =
          await LeaveService.approveLeave(id, catatan: 'Disetujui Mentor');
    } else {
      success = await LeaveService.rejectLeave(id, catatan: 'Ditolak Mentor');
    }

    if (mounted) {
      Navigator.pop(context);
      if (success) {
        GlobalSnackBar.show(approve ? 'Izin disetujui' : 'Izin ditolak',
            isSuccess: true);
        _loadData();
      } else {
        GlobalSnackBar.show('Gagal memproses izin', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppThemes.darkBackground : AppThemes.backgroundColor,
      appBar: CustomAppBar(
        title: 'Validasi',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          )
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppThemes.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: isDark
                          ? AppThemes.darkOutline
                          : Colors.grey.shade200),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppThemes.primaryColor,
                  unselectedLabelColor:
                      isDark ? Colors.grey : Colors.grey.shade600,
                  indicatorColor: AppThemes.primaryColor,
                  tabs: [
                    Tab(text: 'Logbook (${_logbooks.length})'),
                    Tab(text: 'Izin/Cuti (${_leaves.length})'),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: LoadingIndicator())
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          RefreshIndicator(
                            onRefresh: _loadData,
                            child: _buildLogbookList(isDark),
                          ),
                          RefreshIndicator(
                            onRefresh: _loadData,
                            child: _buildLeaveList(isDark),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 100),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MentorBottomNav(
              currentRoute: RouteNames.mentorValidation,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogbookList(bool isDark) {
    if (_logbooks.isEmpty) {
      return ListView(
        // Pakai ListView agar RefreshIndicator bekerja
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: _buildEmptyState('Tidak ada logbook pending', isDark),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _logbooks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _logbooks[index];
        final name = item.pesertaMagang?.nama ?? 'Peserta';
        return _buildValidationCard(
          isDark: isDark,
          title: item.kegiatan,
          subtitle: '$name • ${item.tanggal}',
          description: item.deskripsi,
          statusLabel: 'LOGBOOK',
          statusColor: AppThemes.primaryColor,
          onApprove: () =>
              _updateLogbookStatus(item.id, ActivityStatus.completed),
          onReject: () =>
              GlobalSnackBar.show('Fitur ini belum tersedia', isInfo: true),
        );
      },
    );
  }

  Widget _buildLeaveList(bool isDark) {
    if (_leaves.isEmpty) {
      return ListView(
        // Pakai ListView agar RefreshIndicator bekerja
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: _buildEmptyState('Tidak ada pengajuan izin pending', isDark),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _leaves.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _leaves[index];
        final name = item['pesertaMagang']?['nama'] ?? 'Peserta';
        final type = item['tipe'] ?? 'IZIN';

        Color typeColor = AppThemes.warningColor;
        if (type == 'SAKIT') typeColor = AppThemes.infoColor;
        if (type == 'CUTI') typeColor = AppThemes.successColor;

        return _buildValidationCard(
          isDark: isDark,
          title: '$type - $name',
          subtitle: '${item['tanggalMulai']} s/d ${item['tanggalSelesai']}',
          description: item['alasan'] ?? 'Tidak ada keterangan',
          statusLabel: type,
          statusColor: typeColor,
          onApprove: () => _processLeave(item['id'], true),
          onReject: () => _processLeave(item['id'], false),
        );
      },
    );
  }

  Widget _buildValidationCard({
    required bool isDark,
    required String title,
    required String subtitle,
    required String description,
    required String statusLabel,
    required Color statusColor,
    required VoidCallback onApprove,
    required VoidCallback onReject,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppThemes.darkSurface : AppThemes.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? AppThemes.darkOutline : Colors.grey.shade200),
        boxShadow: [
          if (!isDark)
            BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark
                            ? AppThemes.darkTextPrimary
                            : AppThemes.onSurfaceColor)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle,
              style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppThemes.darkTextTertiary
                      : Colors.grey.shade600,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
                  isDark ? AppThemes.darkSurfaceElevated : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(description,
                style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppThemes.darkTextSecondary
                        : AppThemes.hintColor)),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: onReject,
                icon: const Icon(Icons.close, size: 16),
                label: const Text('Tolak'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppThemes.errorColor,
                  side: const BorderSide(color: AppThemes.errorColor),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: onApprove,
                icon: const Icon(Icons.check, size: 16),
                label: const Text('Setujui'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppThemes.successColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String msg, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_turned_in_outlined,
              size: 64, color: AppThemes.hintColor.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(msg,
              style: TextStyle(
                  color: isDark
                      ? AppThemes.darkTextSecondary
                      : AppThemes.hintColor)),
        ],
      ),
    );
  }
}
