import 'package:flutter/material.dart';

import '../navigation/route_names.dart';
import '../themes/app_themes.dart';
import '../utils/haptic_util.dart'; // [IMPORT HAPTIC]
import '../utils/navigation_helper.dart';

class FloatingBottomNav extends StatelessWidget {
  final String currentRoute;
  final VoidCallback? onQRScanTap;

  const FloatingBottomNav({
    super.key,
    required this.currentRoute,
    this.onQRScanTap,
  });

  @override
  Widget build(BuildContext context) {
    // FIX: Gunakan Theme Context
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            // FIX: Gunakan surfaceContainer yang otomatis berubah warna sesuai mode
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(30),
            // FIX: Gunakan outline untuk border
            border: isDark
                ? Border.all(
                    color: colorScheme.outline.withOpacity(0.3), width: 0.5)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(context, Icons.home_rounded, Icons.home_outlined,
                  RouteNames.home, 'Beranda'),
              _buildNavItem(
                  context,
                  Icons.assignment_rounded,
                  Icons.assignment_outlined,
                  RouteNames.activities,
                  'Aktivitas'),
              const SizedBox(width: 40), // Space for FAB
              _buildNavItem(context, Icons.bar_chart_rounded,
                  Icons.bar_chart_outlined, RouteNames.report, 'Laporan'),
              _buildNavItem(context, Icons.person_rounded, Icons.person_outline,
                  RouteNames.profile, 'Profil'),
            ],
          ),
        ),
        if (onQRScanTap != null)
          // Bulatan Floating (QR Button)
          Positioned(
            left: 0,
            right: 0,
            bottom: 25,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  HapticUtil.medium(); // [HAPTIC] Tap Tombol Tengah
                  if (onQRScanTap != null) onQRScanTap!();
                },
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      // FIX: Gunakan primaryColor statis atau dari scheme
                      colors: [
                        AppThemes.primaryColor,
                        const Color(
                            0xFF00728F), // Variasi gelap manual untuk gradient
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppThemes.primaryColor.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    // FIX: Border dihapus agar full color tanpa outline
                  ),
                  child: const Icon(Icons.qr_code_scanner_outlined,
                      color: Colors.white, size: 35),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNavItem(BuildContext context, IconData activeIcon, IconData icon,
      String route, String label) {
    final isActive = currentRoute == route;
    final colorScheme = Theme.of(context).colorScheme;

    // FIX: Tentukan warna berdasarkan state aktif/tidak
    final color = isActive
        ? AppThemes.primaryColor // Warna aktif (Cyan)
        : colorScheme.onSurfaceVariant; // Warna tidak aktif (Abu-abu adaptif)

    return GestureDetector(
      onTap: () {
        HapticUtil.light(); // [HAPTIC] Tap Navigasi
        if (!isActive) {
          NavigationHelper.navigateWithoutAnimation(context, route);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? activeIcon : icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
