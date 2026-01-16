import 'package:flutter/material.dart';
import '../navigation/route_names.dart';
import '../themes/app_themes.dart';

class MentorBottomNav extends StatelessWidget {
  final String currentRoute;

  const MentorBottomNav({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _getCurrentIndex(),
        onTap: (index) => _navigate(context, index),
        backgroundColor: colorScheme.surfaceContainer,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Validasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  int _getCurrentIndex() {
    switch (currentRoute) {
      case RouteNames.mentorHome:
        return 0;
      case RouteNames.mentorValidation:
        return 1;
      case RouteNames.profile:
        return 2;
      default:
        return 0;
    }
  }

  void _navigate(BuildContext context, int index) {
    String route;
    switch (index) {
      case 0:
        route = RouteNames.mentorHome;
        break;
      case 1:
        route = RouteNames.mentorValidation;
        break;
      case 2:
        route = RouteNames.profile;
        break;
      default:
        return;
    }

    if (route != currentRoute) {
      Navigator.pushReplacementNamed(context, route);
    }
  }
}
