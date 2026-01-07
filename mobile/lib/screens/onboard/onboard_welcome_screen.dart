import 'package:flutter/material.dart';

import '../../navigation/route_names.dart';
import '../../themes/app_themes.dart';

class OnboardWelcomeScreen extends StatelessWidget {
  const OnboardWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final size = MediaQuery.of(context).size;
    final double screenHeight = size.height;
    final double imageSectionHeight = screenHeight * 0.45;
    final double maxImageWidth = 400.0;

    return Scaffold(
      // FIX: Gunakan background dari tema, bukan variabel statis
      backgroundColor: theme.scaffoldBackgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: screenHeight * 0.05),
                      Image.asset(
                        'assets/images/InternLogoExpand.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      SizedBox(
                        height: imageSectionHeight,
                        width: double.infinity,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: imageSectionHeight * 0.8,
                              height: imageSectionHeight * 0.8,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight,
                                  // FIX: Gunakan warna dari colorScheme dengan opacity
                                  colors: [
                                    colorScheme.primary
                                        .withOpacity(isDark ? 0.4 : 0.2),
                                    colorScheme.primary.withOpacity(0.15),
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Transform.translate(
                              offset: Offset(0, -imageSectionHeight * 0.1),
                              child: ConstrainedBox(
                                constraints:
                                    BoxConstraints(maxWidth: maxImageWidth),
                                child: Image.asset(
                                  'assets/images/Mascot4.png',
                                  height: imageSectionHeight,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.rocket_launch,
                                // FIX: Gunakan primaryColor dari AppThemes atau colorScheme.primary
                                color: AppThemes.primaryColor,
                                size: 28,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Ayo Mulai Petualanganmu!', // Translate
                                  style:
                                      theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    // FIX: Gunakan onSurface untuk teks utama
                                    color: colorScheme.onSurface,
                                    letterSpacing: -0.5,
                                    fontSize: 24,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Absensi jadi lebih seru dan praktis! Pantau aktivitas magang, catat progres, dan raih prestasi terbaikmu.', // Translate
                            style: theme.textTheme.bodyMedium?.copyWith(
                              // FIX: Gunakan onSurfaceVariant untuk teks sekunder
                              color: colorScheme.onSurfaceVariant,
                              height: 1.5,
                              fontSize: 14,
                              letterSpacing: 0.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: screenHeight * 0.04),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  RouteNames.login,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppThemes.primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                shadowColor:
                                    AppThemes.primaryColor.withOpacity(0.4),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.login, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Masuk & Jelajahi', // Translate
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  RouteNames.register,
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                // FIX: Gunakan primary color untuk outline
                                foregroundColor: AppThemes.primaryColor,
                                side: BorderSide(
                                  color: AppThemes.primaryColor,
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                backgroundColor: Colors.transparent,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.person_add, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Buat Akun Baru', // Translate
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                      // FIX: Gunakan primary color
                                      color: AppThemes.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              // FIX: Gunakan primary color dengan opacity
                              color: AppThemes.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppThemes.primaryColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people,
                                  // FIX: Gunakan primary color
                                  color: AppThemes.primaryColor,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Gabung dengan komunitas magang terbaik', // Translate
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      // FIX: Gunakan onSurfaceVariant
                                      color: colorScheme.onSurfaceVariant,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
