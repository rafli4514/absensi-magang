import 'package:flutter/material.dart';

import '../../../models/onboard_model.dart';
import '../../../themes/app_themes.dart';

class OnboardPageWidget extends StatelessWidget {
  final OnboardPage page;

  const OnboardPageWidget({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Ambil ukuran layar
    final size = MediaQuery.of(context).size;

    // Tentukan ukuran gambar dinamis (misal: 40% dari tinggi layar, max 350px)
    final double imageHeight = size.height * 0.40;
    final double maxImageSize = 350.0;
    final double finalSize =
        imageHeight > maxImageSize ? maxImageSize : imageHeight;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 24.0), // Padding kanan kiri diperbesar
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Center vertikal
        children: [
          // Logo Kecil di atas
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: Image.asset(
              'assets/images/InternLogoExpand.png',
              width: 60,
              height: 60,
              fit: BoxFit.contain,
            ),
          ),

          // Mascot dengan Background Bulat (RESPONSIVE)
          SizedBox(
            height: finalSize, // Tinggi dinamis
            width: finalSize, // Lebar dinamis (kotak)
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background Bulat
                Container(
                  width: finalSize * 0.9, // 90% dari container
                  height: finalSize * 0.9,
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
                    borderRadius:
                        BorderRadius.circular(finalSize), // Bulat sempurna
                  ),
                ),
                // Mascot Image
                Transform.translate(
                  offset: Offset(0, -finalSize * 0.05), // Naik dikit (5%)
                  child: Image.asset(
                    page.imageUrl,
                    width: finalSize,
                    height: finalSize,
                    fit: BoxFit.contain,
                    errorBuilder: (ctx, _, __) => Icon(
                        Icons.image_not_supported,
                        size: finalSize * 0.5,
                        color: AppThemes.hintColor),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: size.height * 0.05), // Jarak dinamis (5% layar)

          // Text Content (Flexible agar tidak overflow)
          Text(
            page.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 22, // Ukuran font tetap atau bisa pakai auto_size_text
              color:
                  isDark ? AppThemes.darkTextPrimary : AppThemes.onSurfaceColor,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppThemes.darkTextTertiary : AppThemes.hintColor,
              fontSize: 14,
              height: 1.5,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
