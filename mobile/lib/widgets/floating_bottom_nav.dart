import 'package:flutter/material.dart';

import '../navigation/route_names.dart';
import '../themes/app_themes.dart';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Bottom Navigation Bar
        Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 30),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
          decoration: BoxDecoration(
            color: isDark
                ? AppThemes.darkSurfaceVariant
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.4 : 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Group kiri: Home dan Activities
              Row(
                children: [
                  _buildNavItem(
                    context: context,
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    route: RouteNames.home,
                    label: 'Home',
                    isDark: isDark,
                  ),
                  const SizedBox(width: 10),
                  _buildNavItem(
                    context: context,
                    icon: Icons.assignment_outlined,
                    activeIcon: Icons.assignment_rounded,
                    route: RouteNames.activities,
                    label: 'Activities',
                    isDark: isDark,
                  ),
                ],
              ),

              // Group kanan: Report dan Profile
              Row(
                children: [
                  _buildNavItem(
                    context: context,
                    icon: Icons.bar_chart_outlined,
                    activeIcon: Icons.bar_chart_rounded,
                    route: RouteNames.report,
                    label: 'Report',
                    isDark: isDark,
                  ),
                  const SizedBox(width: 15),
                  _buildNavItem(
                    context: context,
                    icon: Icons.person_outlined,
                    activeIcon: Icons.person_rounded,
                    route: RouteNames.profile,
                    label: 'Profile',
                    isDark: isDark,
                  ),
                ],
              ),
            ],
          ),
        ),

        // Floating QR Button di tengah
        if (onQRScanTap != null)
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 30,
            bottom: 26,
            child: GestureDetector(
              onTap: onQRScanTap,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppThemes.darkAccentBlue
                        : AppThemes.primaryColor,
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [AppThemes.darkAccentBlue, AppThemes.primaryDark]
                          : [AppThemes.primaryColor, AppThemes.primaryDark],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (isDark
                                    ? AppThemes.darkAccentBlue
                                    : AppThemes.primaryColor)
                                .withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String route,
    required String label,
    required bool isDark,
  }) {
    final isActive = currentRoute == route;
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _navigateTo(context, route),
        borderRadius: BorderRadius.circular(20),
        splashColor:
            (isDark ? AppThemes.darkAccentBlue : AppThemes.primaryColor)
                .withOpacity(0.1),
        highlightColor:
            (isDark ? AppThemes.darkAccentBlue : AppThemes.primaryColor)
                .withOpacity(0.2),
        hoverColor: (isDark ? AppThemes.darkAccentBlue : AppThemes.primaryColor)
            .withOpacity(0.02),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isActive
                ? (isDark ? AppThemes.darkAccentBlue : AppThemes.primaryColor)
                      .withOpacity(0.1)
                : Colors.transparent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                color: isActive
                    ? (isDark
                          ? AppThemes.darkAccentBlue
                          : AppThemes.primaryColor)
                    : (isDark
                          ? AppThemes.darkTextSecondary
                          : theme.colorScheme.onSurface.withOpacity(0.6)),
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isActive
                      ? (isDark
                            ? AppThemes.darkAccentBlue
                            : AppThemes.primaryColor)
                      : (isDark
                            ? AppThemes.darkTextSecondary
                            : theme.colorScheme.onSurface.withOpacity(0.6)),
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, String routeName) {
    if (currentRoute != routeName) {
      NavigationHelper.navigateWithoutAnimation(context, routeName);
    }
  }
}
