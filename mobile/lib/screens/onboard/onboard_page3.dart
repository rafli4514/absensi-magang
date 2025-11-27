import 'package:flutter/material.dart';

import '../../themes/app_themes.dart';

class OnboardPage3 extends StatelessWidget {
  const OnboardPage3({super.key});

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

          // Mascot dengan background bulat - dominan
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background bulatan
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
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
                    borderRadius: BorderRadius.circular(150),
                  ),
                ),
                // Mascot yang "timbul"
                Transform.translate(
                  offset: const Offset(0, -30),
                  child: Image.asset(
                    'assets/images/Mascot3.png',
                    width: 360,
                    height: 360,
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
                    Icon(
                      Icons.analytics,
                      color: AppThemes.primaryColor,
                      size: 26,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Pantau Progress Magangmu!',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        color: isDark
                            ? AppThemes.darkTextPrimary
                            : AppThemes.onSurfaceColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppThemes.infoDark.withOpacity(0.2)
                        : AppThemes.infoLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark
                          ? AppThemes.infoDark.withOpacity(0.4)
                          : AppThemes.infoColor.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    'Semua data dalam genggaman',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppThemes.infoColor : AppThemes.infoDark,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Lihat riwayat absensi, aktivitas harian, dan perkembangan skill-mu secara real-time. Jadi bisa evaluasi diri dan makin produktif!',
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
