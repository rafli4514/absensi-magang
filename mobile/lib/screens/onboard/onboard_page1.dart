import 'package:flutter/material.dart';

import '../../themes/app_themes.dart';

class OnboardPage1 extends StatelessWidget {
  const OnboardPage1({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Logo di paling atas
          Container(
            margin: const EdgeInsets.only(top: 20, bottom: 10),
            child: Image.asset(
              'assets/images/InternLogoExpand.png',
              width: 80,
              height: 80,
              fit: BoxFit.contain,
            ),
          ),

          // Mascot dengan background bulat - mengambil space lebih banyak
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background bulatan
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [
                              AppThemes.primaryColor.withOpacity(0.3),
                              AppThemes.primaryDark.withOpacity(0.1),
                            ]
                          : [
                              AppThemes.primaryLight.withOpacity(0.4),
                              AppThemes.primaryColor.withOpacity(0.1),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(140),
                  ),
                ),
                // Mascot yang "timbul"
                Transform.translate(
                  offset: const Offset(0, -30),
                  child: Image.asset(
                    'assets/images/Mascot1.png',
                    width: 340,
                    height: 340,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),

          // Konten text di bagian bawah
          Container(
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        'Selamat Datang di MyInternPlus!',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 21,
                          color: isDark
                              ? AppThemes.darkTextPrimary
                              : AppThemes.onSurfaceColor,
                          letterSpacing: -0.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.waving_hand,
                      color: AppThemes.primaryColor,
                      size: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppThemes.primaryColor.withOpacity(0.15)
                        : AppThemes.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.self_improvement,
                        color: AppThemes.primaryColor,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Teman Setia Magangmu',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: isDark
                                ? AppThemes.darkTextSecondary
                                : AppThemes.onSurfaceColor.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Bikin magang jadi lebih mudah dan terorganisir! Kelola absensi, pantau aktivitas, dan catat progress belajarmu dalam satu aplikasi',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppThemes.darkTextTertiary
                        : AppThemes.hintColor,
                    fontSize: 14,
                    height: 1.6,
                    letterSpacing: 0.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
