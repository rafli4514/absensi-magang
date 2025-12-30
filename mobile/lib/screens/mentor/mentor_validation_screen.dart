import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

class _MentorValidationScreenState extends State<MentorValidationScreen> {
  // State Halaman
  int _selectedTabIndex = 0; // 0 = Logbook, 1 = Izin
  bool _isLoading = false;

  // Data Source
  List<dynamic> _allLogbooks = [];
  List<dynamic> _leaves = [];

  // Filter State Logbook
  DateTime _selectedDate = DateTime.now();
  bool _showHistory = false; // false = Menunggu, true = Riwayat

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final logbookRes = await LogbookService.getAllLogbook(limit: 200);
      final leaveRes = await LeaveService.getLeaves(status: 'PENDING');

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (logbookRes.success && logbookRes.data != null) {
            _allLogbooks = logbookRes.data!;
          }
          if (leaveRes.success && leaveRes.data != null) {
            // Sort Izin terbaru diatas
            _leaves = leaveRes.data!;
            _leaves.sort((a, b) {
              DateTime tA =
                  DateTime.tryParse(a['createdAt'] ?? '') ?? DateTime.now();
              DateTime tB =
                  DateTime.tryParse(b['createdAt'] ?? '') ?? DateTime.now();
              return tB.compareTo(tA);
            });
          } else {
            _leaves = [];
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

  // --- LOGIC FILTER ---
  List<dynamic> _getFilteredLogbooks() {
    // 1. Filter Tanggal & Status
    final filtered = _allLogbooks.where((log) {
      bool statusMatch;
      if (_showHistory) {
        statusMatch = log.status == ActivityStatus.completed ||
            log.status == ActivityStatus.cancelled;
      } else {
        statusMatch = log.status == ActivityStatus.pending ||
            log.status == ActivityStatus.inProgress;
      }

      bool dateMatch = false;
      try {
        final logDate = DateTime.parse(log.tanggal);
        dateMatch = logDate.year == _selectedDate.year &&
            logDate.month == _selectedDate.month &&
            logDate.day == _selectedDate.day;
      } catch (_) {}

      return statusMatch && dateMatch;
    }).toList();

    // 2. Sort: Jam Terbaru Diatas (berdasarkan createdAt)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return filtered;
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
  }

  // --- API ACTIONS ---
  Future<void> _reviewLogbook(String id, bool isApprove) async {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final status =
          isApprove ? ActivityStatus.completed : ActivityStatus.cancelled;
      final res =
          await LogbookService.updateLogbook(id: id, status: status.value);

      if (mounted) {
        Navigator.pop(context); // Tutup Loading
        if (res.success) {
          Navigator.pop(context); // Tutup Detail Dialog
          GlobalSnackBar.show(isApprove ? 'Disetujui' : 'Ditolak',
              isSuccess: true);
          _loadData();
        } else {
          GlobalSnackBar.show('Gagal update status', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        GlobalSnackBar.show('Error: $e', isError: true);
      }
    }
  }

  Future<void> _processLeave(String id, bool approve) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
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
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        GlobalSnackBar.show('Error: $e', isError: true);
      }
    }
  }

  // --- UI COMPONENTS ---

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
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData)
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 16),
              // 1. CUSTOM TAB BAR (Logbook | Izin/Cuti)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color:
                        isDark ? AppThemes.darkSurface : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _buildTabItem("Logbook", 0, isDark),
                      _buildTabItem(
                          "Izin / Cuti (${_leaves.length})", 1, isDark),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 2. KONTEN (Switch based on Index)
              Expanded(
                child: _isLoading
                    ? const Center(child: LoadingIndicator())
                    : _selectedTabIndex == 0
                        ? _buildLogbookContent(isDark)
                        : _buildLeaveContent(isDark),
              ),

              const SizedBox(height: 90), // Space for bottom nav
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MentorBottomNav(currentRoute: RouteNames.mentorValidation),
          ),
        ],
      ),
    );
  }

  // Widget Tab Item Custom
  Widget _buildTabItem(String title, int index, bool isDark) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppThemes.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10), // Rounded penuh
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.grey : Colors.grey.shade600),
            ),
          ),
        ),
      ),
    );
  }

  // --- KONTEN LOGBOOK ---
  Widget _buildLogbookContent(bool isDark) {
    final filteredLogbooks = _getFilteredLogbooks();
    final dateStr = DateFormat('EEE, d MMM', 'id_ID').format(_selectedDate);

    return Column(
      children: [
        // CONTROLS AREA (Tanggal & Filter Status)
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
              color: isDark ? AppThemes.darkSurface : AppThemes.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: isDark ? AppThemes.darkOutline : Colors.grey.shade200),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
              ]),
          child: Column(
            children: [
              // Row 1: Navigasi Tanggal & Toggle Riwayat
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tanggal Navigasi
                  Row(
                    children: [
                      _buildDateNavBtn(
                          Icons.chevron_left, () => _changeDate(-1), isDark),
                      const SizedBox(width: 12),
                      Text(
                        dateStr,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isDark
                                ? AppThemes.darkTextPrimary
                                : AppThemes.onSurfaceColor),
                      ),
                      const SizedBox(width: 12),
                      _buildDateNavBtn(
                          Icons.chevron_right, () => _changeDate(1), isDark),
                    ],
                  ),

                  // Divider Kecil
                  Container(
                      height: 20,
                      width: 1,
                      color: Colors.grey.withOpacity(0.3)),

                  // Toggle Status (Text Button Simple)
                  GestureDetector(
                    onTap: () => setState(() => _showHistory = !_showHistory),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: _showHistory
                              ? AppThemes.primaryColor.withOpacity(0.1)
                              : AppThemes.warningColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: _showHistory
                                  ? AppThemes.primaryColor
                                  : AppThemes.warningColor,
                              width: 1)),
                      child: Row(
                        children: [
                          Text(
                            _showHistory ? 'Riwayat' : 'Menunggu',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _showHistory
                                    ? AppThemes.primaryColor
                                    : AppThemes.warningColor),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.swap_horiz_rounded,
                              size: 16,
                              color: _showHistory
                                  ? AppThemes.primaryColor
                                  : AppThemes.warningColor)
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),

        // LIST
        Expanded(
          child: filteredLogbooks.isEmpty
              ? _buildEmptyState('Tidak ada logbook', isDark)
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  itemCount: filteredLogbooks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _buildLogbookCard(filteredLogbooks[index], isDark);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDateNavBtn(IconData icon, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark ? AppThemes.darkSurfaceElevated : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon,
            size: 20, color: isDark ? Colors.white : Colors.grey.shade700),
      ),
    );
  }

  // --- KARTU LOGBOOK (Menyamping) ---
  Widget _buildLogbookCard(dynamic item, bool isDark) {
    final name = item.pesertaMagang?['nama'] ?? 'Peserta';
    final avatar = item.pesertaMagang?['avatar'];
    final timeStr = DateFormat('HH:mm').format(item.createdAt);
    final kegiatan = item.kegiatan;

    return Card(
      elevation: 0, // Flat design
      color: isDark ? AppThemes.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: isDark ? AppThemes.darkOutline : Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () => _showLogbookDetail(item),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 1. PFP (Avatar)
              CircleAvatar(
                radius: 26,
                backgroundColor: AppThemes.primaryColor.withOpacity(0.1),
                backgroundImage: avatar != null ? NetworkImage(avatar) : null,
                child: avatar == null
                    ? Text(name[0].toUpperCase(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppThemes.primaryColor,
                            fontSize: 18))
                    : null,
              ),

              const SizedBox(width: 16),

              // 2. Info (Judul, Nama, Waktu)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kegiatan,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: isDark
                              ? AppThemes.darkTextPrimary
                              : AppThemes.onSurfaceColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      name,
                      style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppThemes.darkTextSecondary
                              : Colors.grey.shade700),
                    ),
                    const SizedBox(height: 4),
                    // Badge Waktu
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                          color: isDark
                              ? AppThemes.darkSurfaceElevated
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.access_time,
                              size: 12, color: AppThemes.hintColor),
                          const SizedBox(width: 4),
                          Text(
                            timeStr,
                            style: TextStyle(
                                fontSize: 11,
                                color: AppThemes.hintColor,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),

              // 3. Arrow / Status Icon
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey.shade400,
              )
            ],
          ),
        ),
      ),
    );
  }

  // --- KONTEN IZIN (Tetap List Biasa) ---
  Widget _buildLeaveContent(bool isDark) {
    if (_leaves.isEmpty) {
      return _buildEmptyState('Tidak ada pengajuan izin', isDark);
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _leaves.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = _leaves[index];
          final name = item['pesertaMagang']?['nama'] ?? 'Peserta';
          final type = item['tipe'] ?? 'IZIN';

          Color color = AppThemes.warningColor;
          if (type == 'SAKIT') color = AppThemes.infoColor;
          if (type == 'CUTI') color = AppThemes.successColor;

          return Card(
            elevation: 0,
            color: isDark ? AppThemes.darkSurface : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                  color: isDark ? AppThemes.darkOutline : Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6)),
                        child: Text(type,
                            style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: 11)),
                      ),
                      const Spacer(),
                      Text(
                        '${item['tanggalMulai']} s/d ${item['tanggalSelesai']}',
                        style:
                            TextStyle(fontSize: 11, color: AppThemes.hintColor),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(name,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark
                              ? AppThemes.darkTextPrimary
                              : Colors.black87)),
                  const SizedBox(height: 4),
                  Text(item['alasan'] ?? '-',
                      style: TextStyle(
                          color: isDark
                              ? AppThemes.darkTextSecondary
                              : Colors.grey[700],
                          fontSize: 13)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => _processLeave(item['id'], false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppThemes.errorColor,
                          side: const BorderSide(color: AppThemes.errorColor),
                          visualDensity: VisualDensity.compact,
                        ),
                        child: const Text('Tolak'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () => _processLeave(item['id'], true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppThemes.successColor,
                          foregroundColor: Colors.white,
                          visualDensity: VisualDensity.compact,
                        ),
                        child: const Text('Setujui'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- DETAIL DIALOG (Dipanggil saat kartu diklik) ---
  void _showLogbookDetail(dynamic item) {
    final name = item.pesertaMagang?['nama'] ?? 'Peserta';
    final avatar = item.pesertaMagang?['avatar'];
    final tanggal = item.tanggal;
    final kegiatan = item.kegiatan;
    final deskripsi = item.deskripsi;
    final durasi = item.durasi ?? '-';
    final jamKirim = DateFormat('HH:mm').format(item.createdAt);
    final isReviewed = item.status == ActivityStatus.completed ||
        item.status == ActivityStatus.cancelled;

    showDialog(
        context: context,
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor:
                isDark ? AppThemes.darkSurface : AppThemes.surfaceColor,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor:
                            AppThemes.primaryColor.withOpacity(0.1),
                        backgroundImage:
                            avatar != null ? NetworkImage(avatar) : null,
                        child: avatar == null
                            ? Text(name[0],
                                style: const TextStyle(
                                    color: AppThemes.primaryColor))
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: isDark
                                        ? AppThemes.darkTextPrimary
                                        : Colors.black87)),
                            Text('Dikirim: $jamKirim',
                                style: TextStyle(
                                    fontSize: 12, color: AppThemes.hintColor)),
                          ],
                        ),
                      ),
                      IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints()),
                    ],
                  ),
                  const Divider(height: 32),
                  _buildInfoRow("Tanggal", tanggal, isDark),
                  const SizedBox(height: 8),
                  _buildInfoRow("Kegiatan", kegiatan, isDark),
                  const SizedBox(height: 8),
                  _buildInfoRow("Durasi", durasi, isDark),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: isDark
                            ? AppThemes.darkSurfaceElevated
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: isDark
                                ? AppThemes.darkOutline
                                : Colors.grey.shade200)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Deskripsi",
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppThemes.hintColor)),
                        const SizedBox(height: 4),
                        Text(deskripsi,
                            style: TextStyle(
                                color: isDark
                                    ? AppThemes.darkTextPrimary
                                    : Colors.black87,
                                height: 1.4)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (!isReviewed)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _reviewLogbook(item.id, false),
                            style: OutlinedButton.styleFrom(
                                foregroundColor: AppThemes.errorColor,
                                side: const BorderSide(
                                    color: AppThemes.errorColor),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                            child: const Text('Tolak'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _reviewLogbook(item.id, true),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppThemes.successColor,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                            child: const Text('Setujui'),
                          ),
                        ),
                      ],
                    )
                  else
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: item.status == ActivityStatus.completed
                              ? AppThemes.successColor.withOpacity(0.1)
                              : AppThemes.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item.status == ActivityStatus.completed
                              ? "Telah Disetujui"
                              : "Telah Ditolak",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: item.status == ActivityStatus.completed
                                  ? AppThemes.successColor
                                  : AppThemes.errorColor),
                        ),
                      ),
                    )
                ],
              ),
            ),
          );
        });
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
            width: 70,
            child: Text(label,
                style: TextStyle(fontSize: 12, color: AppThemes.hintColor))),
        Expanded(
            child: Text(value,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppThemes.darkTextPrimary
                        : AppThemes.onSurfaceColor))),
      ],
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
