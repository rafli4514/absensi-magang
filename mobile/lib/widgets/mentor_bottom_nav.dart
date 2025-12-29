import 'package:flutter/material.dart';

import '../navigation/route_names.dart';
import '../themes/app_themes.dart';
import '../utils/navigation_helper.dart';

class MentorBottomNav extends StatelessWidget {
  final String currentRoute;

  const MentorBottomNav({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppThemes.darkSurfaceVariant : AppThemes.surfaceColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
              context,
              Icons.dashboard_rounded,
              Icons.dashboard_outlined,
              RouteNames.mentorHome,
              'Dashboard',
              isDark),
          _buildNavItem(
              context,
              Icons.fact_check_rounded,
              Icons.fact_check_outlined,
              RouteNames.mentorValidation,
              'Validasi',
              isDark),
          _buildNavItem(context, Icons.person_rounded, Icons.person_outline,
              RouteNames.profile, 'Profil', isDark),
        ],
      ),
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
