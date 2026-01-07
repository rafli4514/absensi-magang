import 'package:flutter/material.dart';

import '../navigation/route_names.dart';
import '../themes/app_themes.dart';
import '../utils/navigation_helper.dart';

class MentorBottomNav extends StatelessWidget {
  final String currentRoute;

  const MentorBottomNav({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, Icons.dashboard_rounded,
              Icons.dashboard_outlined, RouteNames.mentorHome, 'Dashboard'),
          _buildNavItem(
              context,
              Icons.fact_check_rounded,
              Icons.fact_check_outlined,
              RouteNames.mentorValidation,
              'Validasi'),
          _buildNavItem(context, Icons.person_rounded, Icons.person_outline,
              RouteNames.profile, 'Profil'),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData activeIcon, IconData icon,
      String route, String label) {
    final isActive = currentRoute == route;
    final colorScheme = Theme.of(context).colorScheme;

    final color =
        isActive ? AppThemes.primaryColor : colorScheme.onSurfaceVariant;

    return GestureDetector(
      onTap: () {
        if (!isActive)
          NavigationHelper.navigateWithoutAnimation(context, route);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isActive ? activeIcon : icon, color: color, size: 24),
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
