import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../navigation/route_names.dart';
import '../../providers/auth_provider.dart';
import '../../services/intern_service.dart';
import '../../services/leave_service.dart';
import '../../services/notification_service.dart';
import '../../themes/app_themes.dart';
import '../../utils/ui_utils.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/mentor_bottom_nav.dart';

class MentorHomeScreen extends StatefulWidget {
  const MentorHomeScreen({super.key});

  @override
  State<MentorHomeScreen> createState() => _MentorHomeScreenState();
}

class _MentorHomeScreenState extends State<MentorHomeScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _mentees = [];

  // Variabel untuk Auto Refresh & Notifikasi
  Timer? _refreshTimer;
  int _lastPendingCount =
      0; // Melacak jumlah pending terakhir untuk deteksi perubahan

  @override
  void initState() {
    super.initState();
    _initialLoad();

    // Timer mengecek setiap 3 detik (Polling)
    // Digunakan untuk mendeteksi pengajuan izin baru secara real-time
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        _checkPendingLeavesBackground();
        _loadMenteesBackground();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  // Load data awal saat layar dibuka
  Future<void> _initialLoad() async {
    await _loadMentees();

    // Inisialisasi count awal tanpa memicu notifikasi
    // Agar saat login pertama kali tidak langsung bunyi notif untuk data lama
    try {
      final response = await LeaveService.getLeaves(status: 'PENDING');
      if (response.success && response.data != null) {
        _lastPendingCount = response.data!.length;
      }
    } catch (_) {}
  }

  // --- LOGIC 1: CEK PERMOHONAN IZIN BARU (BACKGROUND) ---
  Future<void> _checkPendingLeavesBackground() async {
    if (!mounted) return;
    try {
      // Ambil daftar izin yang statusnya PENDING
      final response = await LeaveService.getLeaves(status: 'PENDING');

      if (response.success && response.data != null) {
        final currentPendingCount = response.data!.length;

        // LOGIKA UTAMA:
        // Jika jumlah pending saat ini LEBIH BANYAK dari sebelumnya,
        // berarti ada pengajuan baru yang masuk.
        if (currentPendingCount > 0 &&
            currentPendingCount > _lastPendingCount) {
          // Ambil data terbaru (biasanya index 0 karena sort by created desc di backend)
          final latestRequest = response.data![0];
          final studentName =
              latestRequest['pesertaMagang']?['nama'] ?? 'Peserta';
          final leaveType = latestRequest['tipe'] ?? 'IZIN';

          // 1. Tampilkan Notifikasi System Tray (Status Bar HP)
          await NotificationService().showNotification(
            id: 300, // ID unik untuk notifikasi mentor
            title: 'Pengajuan Izin Baru 📩',
            body: '$studentName mengajukan $leaveType. Segera validasi.',
            payload: RouteNames
                .mentorValidation, // Klik notif -> Buka layar validasi
          );

          // 2. Tampilkan Snackbar Info di dalam aplikasi (jika sedang aktif)
          if (mounted) {
            GlobalSnackBar.show('Permohonan izin baru dari $studentName',
                isInfo: true);
          }
        }

        // Update jumlah terakhir agar notifikasi tidak muncul berulang-ulang
        if (currentPendingCount != _lastPendingCount) {
          setState(() {
            _lastPendingCount = currentPendingCount;
          });
        }
      }
    } catch (e) {
      debugPrint("Silent check error: $e");
    }
  }

  // --- LOGIC 2: REFRESH DATA TIM (BACKGROUND) ---
  Future<void> _loadMenteesBackground() async {
    if (!mounted) return;
    try {
      final response = await InternService.getAllInterns();
      if (mounted && response.success && response.data != null) {
        // Cek sederhana: jika jumlah anggota berubah, update UI
        if (_mentees.length != response.data!.length) {
          setState(() {
            _mentees = response.data!;
          });
        }
      }
    } catch (_) {}
  }

  // --- LOGIC 3: LOAD AWAL (DENGAN LOADING SPINNER) ---
  Future<void> _loadMentees() async {
    setState(() => _isLoading = true);
    try {
      final response = await InternService.getAllInterns();
      if (mounted) {
        if (response.success && response.data != null) {
          setState(() {
            _mentees = response.data!;
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Dashboard Pembimbing',
        showBackButton: false,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined,
                color: colorScheme.onSurface),
            onPressed: () {
              // Feedback visual bahwa sistem realtime aktif
              GlobalSnackBar.show('Real-time monitoring aktif.', isInfo: true);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: LoadingIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Header (Info Pembimbing)
                      _buildWelcomeHeader(
                          user?.nama ?? 'Pembimbing', isDark, colorScheme),
                      const SizedBox(height: 24),

                      // 2. Stats Cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              'Total Tim Saya',
                              '${_mentees.length}',
                              Icons.groups_rounded,
                              AppThemes.primaryColor,
                              colorScheme,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSummaryCard(
                              'Menunggu Review',
                              _lastPendingCount > 0
                                  ? '$_lastPendingCount'
                                  : '0', // Data Realtime
                              Icons.rate_review_rounded,
                              AppThemes.warningColor,
                              colorScheme,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 3. List Anggota Tim
                      Text(
                        'Anggota Tim',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (_mentees.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              'Belum ada anggota tim yang ditugaskan',
                              style: TextStyle(
                                  color: colorScheme.onSurfaceVariant),
                            ),
                          ),
                        ),

                      ..._mentees.map((mentee) =>
                          _buildMenteeCard(mentee, colorScheme, context)),

                      const SizedBox(
                          height: 100), // Space extra untuk bottom nav
                    ],
                  ),
                ),

          // 4. Bottom Nav Khusus Mentor
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: const MentorBottomNav(currentRoute: RouteNames.mentorHome),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildWelcomeHeader(
      String name, bool isDark, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [colorScheme.surfaceContainerHigh, colorScheme.surfaceContainer]
              : [AppThemes.primaryColor, const Color(0xFF0D7A8C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppThemes.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: const Icon(Icons.person, size: 30, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Selamat Datang,',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                Text(name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('Pembimbing Lapangan',
                      style: TextStyle(color: Colors.white, fontSize: 10)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon,
      Color color, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface)),
          Text(title,
              style:
                  TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildMenteeCard(Map<String, dynamic> mentee, ColorScheme colorScheme,
      BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, RouteNames.menteeDetail,
            arguments: mentee);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppThemes.primaryColor.withOpacity(0.1),
              child: Text((mentee['nama'] ?? 'U')[0],
                  style: const TextStyle(
                      color: AppThemes.primaryColor,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mentee['nama'] ?? 'Nama',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface)),
                  Text(mentee['divisi'] ?? '-',
                      style: TextStyle(
                          fontSize: 12, color: colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
