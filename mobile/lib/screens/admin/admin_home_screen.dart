import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../navigation/route_names.dart';
import '../../providers/auth_provider.dart';
import '../../services/dashboard_service.dart';
import '../../themes/app_themes.dart';
import '../../utils/responsive_layout.dart'; // IMPORT RESPONSIVE HELPER
import '../../utils/ui_utils.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/loading_indicator.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final response = await DashboardService.getDashboardStats();
      if (mounted) {
        if (response.success && response.data != null) {
          setState(() {
            _stats = response.data;
            _isLoading = false;
          });
        } else {
          GlobalSnackBar.show(response.message, isError: true);
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        GlobalSnackBar.show('Gagal memuat data: $e', isError: true);
        setState(() => _isLoading = false);
      }
    }
  }

  void _logout() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: 'Keluar',
        content: 'Keluar dari Panel Admin?',
        primaryButtonText: 'Keluar',
        primaryButtonColor: AppThemes.errorColor,
        onPrimaryButtonPressed: () async {
          await authProvider.logout();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(
                context, RouteNames.login, (route) => false);
          }
        },
        secondaryButtonText: 'Batal',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // --- IMPLEMENTASI RESPONSIVE HELPER ---
    final isMobile = ResponsiveLayout.isMobile(context);
    final isTablet = ResponsiveLayout.isTablet(context);

    // Tentukan jumlah kolom dan rasio kartu berdasarkan ukuran layar
    final int gridCrossAxisCount = isMobile ? 2 : 4;

    // Aspek rasio: Mobile butuh kartu lebih tinggi (rasio lebih kecil) agar teks tidak overflow
    final double gridChildAspectRatio = isMobile
        ? 1.35 // Mobile: Lebih tinggi
        : 1.5; // Tablet/Desktop: Lebih lebar

    return Scaffold(
      backgroundColor:
          isDark ? AppThemes.darkBackground : AppThemes.backgroundColor,
      appBar: CustomAppBar(
        title: 'Admin Panel',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadDashboardData,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppThemes.errorColor),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator(message: "Memuat Data..."))
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      'Selamat Datang, Admin',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppThemes.darkTextPrimary
                            : AppThemes.onSurfaceColor,
                      ),
                    ),
                    Text(
                      'Overview program magang hari ini',
                      style: TextStyle(
                        color: isDark
                            ? AppThemes.darkTextSecondary
                            : AppThemes.hintColor,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Statistik Grid (Responsive)
                    GridView.count(
                      crossAxisCount: gridCrossAxisCount,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio:
                          gridChildAspectRatio, // FIX OVERFLOW DISINI
                      children: [
                        _buildStatCard(
                          'Total Peserta',
                          _stats?['totalPesertaMagang']?.toString() ?? '0',
                          Icons.people_alt_rounded,
                          AppThemes.primaryColor,
                          isDark,
                        ),
                        _buildStatCard(
                          'Peserta Hadir',
                          _stats?['absensiMasukHariIni']?.toString() ?? '0',
                          Icons.check_circle_rounded,
                          AppThemes.successColor,
                          isDark,
                        ),
                        _buildStatCard(
                          'Peserta Pulang',
                          _stats?['absensiKeluarHariIni']?.toString() ?? '0',
                          Icons.logout_rounded,
                          AppThemes.infoColor,
                          isDark,
                        ),
                        _buildStatCard(
                          'Rata-rata Hadir',
                          '${_stats?['tingkatKehadiran'] ?? 0}%',
                          Icons.pie_chart_rounded,
                          AppThemes.warningColor,
                          isDark,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                    Text(
                      'Menu Manajemen',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppThemes.darkTextPrimary
                            : AppThemes.onSurfaceColor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Menu Admin - Gunakan Responsive Layout jika perlu,
                    // tapi Column biasanya aman untuk list menu vertical.
                    Column(
                      children: [
                        _buildAdminMenuTile(
                          title: 'Data Peserta Magang',
                          subtitle: 'Lihat daftar, tambah, atau hapus peserta',
                          icon: Icons.manage_accounts_rounded,
                          color: AppThemes.primaryColor,
                          isDark: isDark,
                          onTap: () => Navigator.pushNamed(
                              context, RouteNames.adminInterns),
                        ),
                        const SizedBox(height: 12),
                        _buildAdminMenuTile(
                          title: 'Buat QR Code Absensi',
                          subtitle: 'Generate QR untuk discan oleh peserta',
                          icon: Icons.qr_code_2_rounded,
                          color: AppThemes.secondaryColor,
                          isDark: isDark,
                          onTap: () =>
                              Navigator.pushNamed(context, RouteNames.adminQR),
                        ),
                      ],
                    ),
                    // Padding bawah tambahan agar scroll tidak mentok
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppThemes.darkSurface : AppThemes.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppThemes.darkTextPrimary
                      : AppThemes.onSurfaceColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppThemes.darkTextSecondary
                      : AppThemes.hintColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdminMenuTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      tileColor: isDark ? AppThemes.darkSurface : AppThemes.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? AppThemes.darkOutline : Colors.grey.withOpacity(0.1),
        ),
      ),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDark ? AppThemes.darkTextPrimary : AppThemes.onSurfaceColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: isDark ? AppThemes.darkTextSecondary : AppThemes.hintColor,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: isDark ? AppThemes.darkTextSecondary : AppThemes.hintColor,
      ),
    );
  }
}
