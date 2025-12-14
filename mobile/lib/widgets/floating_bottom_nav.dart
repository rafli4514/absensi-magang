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
        Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          decoration: BoxDecoration(
            color:
                isDark ? AppThemes.darkSurfaceVariant : AppThemes.surfaceColor,
            borderRadius: BorderRadius.circular(30),
            border: isDark
                ? Border.all(color: AppThemes.darkOutline, width: 0.5)
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
                  RouteNames.home, 'Home', isDark),
              _buildNavItem(
                  context,
                  Icons.assignment_rounded,
                  Icons.assignment_outlined,
                  RouteNames.activities,
                  'Activity',
                  isDark),
              const SizedBox(width: 40), // Space for FAB
              _buildNavItem(
                  context,
                  Icons.bar_chart_rounded,
                  Icons.bar_chart_outlined,
                  RouteNames.report,
                  'Report',
                  isDark),
              _buildNavItem(context, Icons.person_rounded, Icons.person_outline,
                  RouteNames.profile, 'Profile', isDark),
            ],
          ),
        ),
        if (onQRScanTap != null)
          //Bulatan Floating
          Positioned(
            left: 0,
            right: 0,
            bottom: 25,
            child: Center(
              child: GestureDetector(
                onTap: onQRScanTap,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [AppThemes.darkAccentBlue, AppThemes.primaryDark]
                          : [AppThemes.primaryColor, AppThemes.primaryDark],
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
      String route, String label, bool isDark) {
    final isActive = currentRoute == route;
    return GestureDetector(
      onTap: () {
        if (!isActive)
          NavigationHelper.navigateWithoutAnimation(context, route);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? activeIcon : icon,
            color: isActive
                ? (isDark ? AppThemes.darkAccentBlue : AppThemes.primaryColor)
                : (isDark ? AppThemes.darkTextSecondary : AppThemes.hintColor),
            size: 24,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: isActive
                  ? (isDark ? AppThemes.darkAccentBlue : AppThemes.primaryColor)
                  : (isDark
                      ? AppThemes.darkTextSecondary
                      : AppThemes.hintColor),
            ),
          ),
        ],
      ),
    );
  }
}
