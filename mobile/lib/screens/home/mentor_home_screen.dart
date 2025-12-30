// lib/screens/home/mentor_home_screen.dart

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
  int _lastPendingCount = 0; // Melacak jumlah pending terakhir

  @override
  void initState() {
    super.initState();
    _initialLoad();

    // UPDATE PENTING: Refresh dipercepat jadi 3 detik agar terasa Real-Time
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkPendingLeavesBackground();
      _loadMenteesBackground();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _initialLoad() async {
    await _loadMentees();
    // Langsung cek izin di awal load
    await _checkPendingLeavesBackground();
  }

  // --- LOGIC AUTO REFRESH & NOTIFIKASI ---

  // Cek izin pending di background tanpa loading spinner
  Future<void> _checkPendingLeavesBackground() async {
    if (!mounted) return;
    try {
      final response = await LeaveService.getLeaves(status: 'PENDING');

      if (response.success && response.data != null) {
        final currentPendingCount = response.data!.length;

        // Logic: Jika jumlah pending BERTAMBAH dari sebelumnya, berarti ada yang baru masuk
        // Kita bandingkan dengan _lastPendingCount
        if (currentPendingCount > 0 &&
            currentPendingCount > _lastPendingCount) {
          // Ambil nama peserta pertama untuk pesan notifikasi
          final firstName =
              response.data![0]['pesertaMagang']?['nama'] ?? 'Peserta';

          String notifTitle = 'Pengajuan Izin Baru';
          String notifBody = '$firstName mengajukan izin baru.';

          if (currentPendingCount > 1) {
            notifBody =
                'Ada $currentPendingCount pengajuan izin menunggu validasi.';
          }

          // Tampilkan Notifikasi Sistem
          await NotificationService().showNotification(
            id: 100, // ID tetap agar menumpuk jika belum dibaca
            title: notifTitle,
            body: notifBody,
            payload: RouteNames.mentorValidation,
          );

          // Tampilkan snackbar info kecil
          if (mounted) {
            GlobalSnackBar.show('Pengajuan izin baru diterima', isInfo: true);
          }
        }

        // Update tracking count SELALU, agar sinkron
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

  // Refresh data tim di background (opsional, bisa lebih jarang)
  Future<void> _loadMenteesBackground() async {
    if (!mounted) return;
    try {
      final response = await InternService.getAllInterns();
      if (mounted && response.success && response.data != null) {
        // Cek sederhana: jika jumlah berubah, update UI
        if (_mentees.length != response.data!.length) {
          setState(() {
            _mentees = response.data!;
          });
        }
      }
    } catch (_) {}
  }

  // Load awal dengan loading spinner
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppThemes.darkBackground : AppThemes.backgroundColor,
      appBar: CustomAppBar(
        title: 'Dashboard Pembimbing',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
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
                      _buildWelcomeHeader(user?.nama ?? 'Pembimbing', isDark),
                      const SizedBox(height: 24),

                      // 2. Stats (Fokus ke Tim)
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              'Total Tim Saya',
                              '${_mentees.length}',
                              Icons.groups_rounded,
                              AppThemes.primaryColor,
                              isDark,
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
                              isDark,
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
                          color: isDark
                              ? AppThemes.darkTextPrimary
                              : AppThemes.onSurfaceColor,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (_mentees.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              'Belum ada anggota tim yang ditugaskan',
                              style: TextStyle(color: AppThemes.hintColor),
                            ),
                          ),
                        ),

                      ..._mentees.map((mentee) =>
                          _buildMenteeCard(mentee, isDark, context)),

                      const SizedBox(height: 100), // Space for navbar
                    ],
                  ),
                ),

          // 4. Bottom Nav Khusus Mentor
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MentorBottomNav(currentRoute: RouteNames.mentorHome),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(String name, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppThemes.darkSurfaceElevated, AppThemes.darkSurface]
              : [AppThemes.primaryColor, AppThemes.primaryDark],
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

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppThemes.darkSurface : AppThemes.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color:
                isDark ? AppThemes.darkOutline : Colors.grey.withOpacity(0.1)),
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
                  color: isDark
                      ? AppThemes.darkTextPrimary
                      : AppThemes.onSurfaceColor)),
          Text(title,
              style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppThemes.darkTextSecondary
                      : AppThemes.hintColor)),
        ],
      ),
    );
  }

  Widget _buildMenteeCard(
      Map<String, dynamic> mentee, bool isDark, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, RouteNames.menteeDetail,
            arguments: mentee);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppThemes.darkSurface : AppThemes.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isDark
                  ? AppThemes.darkOutline
                  : Colors.grey.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor:
                  isDark ? AppThemes.darkSurfaceElevated : Colors.grey.shade100,
              child: Text((mentee['nama'] ?? 'U')[0],
                  style: TextStyle(
                      color: isDark
                          ? AppThemes.darkTextPrimary
                          : AppThemes.primaryColor,
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
                          color: isDark
                              ? AppThemes.darkTextPrimary
                              : AppThemes.onSurfaceColor)),
                  Text(mentee['divisi'] ?? '-',
                      style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppThemes.darkTextSecondary
                              : AppThemes.hintColor)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppThemes.hintColor),
          ],
        ),
      ),
    );
  }
}
