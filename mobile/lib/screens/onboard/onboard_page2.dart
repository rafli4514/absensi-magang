import 'package:flutter/material.dart';

import '../../themes/app_themes.dart';

class OnboardPage2 extends StatelessWidget {
  const OnboardPage2({super.key});

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
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
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
                    borderRadius: BorderRadius.circular(130),
                  ),
                ),
                // Mascot yang "timbul"
                Transform.translate(
                  offset: const Offset(0, -20),
                  child: Image.asset(
                    'assets/images/Mascot2.png',
                    width: 320,
                    height: 320,
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
                      Icons.qr_code_scanner,
                      color: AppThemes.primaryColor,
                      size: 26,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Absensi Cuma Sekali Scan!',
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
                        ? AppThemes.successDark.withOpacity(0.2)
                        : AppThemes.successLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark
                          ? AppThemes.successDark.withOpacity(0.4)
                          : AppThemes.successColor.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    'Gak perlu ribet isi form manual lagi',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppThemes.successColor
                          : AppThemes.successDark,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Tinggal scan QR Code, langsung absen dalam hitungan detik! Cepat, akurat, dan anti ribet.',
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
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.flash_on,
                      color: AppThemes.warningColor,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Proses super cepat',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppThemes.warningColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.verified,
                      color: AppThemes.successColor,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Data akurat',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppThemes.successColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
