import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../navigation/route_names.dart';
import '../../providers/auth_provider.dart';
import '../../services/intern_service.dart';
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

  @override
  void initState() {
    super.initState();
    _loadMentees();
  }

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
              GlobalSnackBar.show('Tidak ada notifikasi baru', isInfo: true);
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
                              '5', // Placeholder jumlah pending
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
