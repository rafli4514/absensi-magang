import 'package:flutter/material.dart';

import '../../navigation/route_names.dart';
import '../../themes/app_themes.dart';

class OnboardWelcomeScreen extends StatelessWidget {
  const OnboardWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Ambil ukuran layar untuk perhitungan responsif
    final size = MediaQuery.of(context).size;
    final double screenHeight = size.height;

    // Tentukan ukuran gambar dinamis (maksimal 45% tinggi layar)
    final double imageSectionHeight = screenHeight * 0.45;
    final double maxImageWidth = 400.0;

    return Scaffold(
      backgroundColor:
          isDark ? AppThemes.darkBackground : AppThemes.backgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            // Agar bisa discroll di HP kecil/landscape
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
                      // Spacer atas dinamis
                      SizedBox(height: screenHeight * 0.05),

                      // Logo di paling atas
                      Image.asset(
                        'assets/images/InternLogoExpand.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.contain,
                      ),

                      SizedBox(height: screenHeight * 0.02),

                      // Mascot dengan background bulat - RESPONSIVE
                      SizedBox(
                        height: imageSectionHeight,
                        width: double.infinity,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Background bulatan besar (80% dari area gambar)
                            Container(
                              width: imageSectionHeight * 0.8,
                              height: imageSectionHeight * 0.8,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight,
                                  colors: isDark
                                      ? [
                                          AppThemes.primaryColor
                                              .withOpacity(0.4),
                                          AppThemes.primaryDark
                                              .withOpacity(0.15),
                                        ]
                                      : [
                                          AppThemes.primaryLight
                                              .withOpacity(0.5),
                                          AppThemes.primaryColor
                                              .withOpacity(0.15),
                                        ],
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                            // Mascot yang "timbul" lebih tinggi
                            Transform.translate(
                              offset: Offset(
                                  0, -imageSectionHeight * 0.1), // Naik 10%
                              child: ConstrainedBox(
                                constraints:
                                    BoxConstraints(maxWidth: maxImageWidth),
                                child: Image.asset(
                                  'assets/images/Mascot4.png',
                                  height:
                                      imageSectionHeight, // Ikuti tinggi area
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Konten text dan buttons
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.rocket_launch,
                                color: AppThemes.primaryColor,
                                size: 28,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                // Agar teks tidak overflow jika layar sempit
                                child: Text(
                                  'Yuk, Mulai Petualanganmu!',
                                  style:
                                      theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: isDark
                                        ? AppThemes.darkTextPrimary
                                        : AppThemes.onSurfaceColor,
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
                            'Absensi jadi lebih seru dan praktis! Pantau aktivitas magang, catat progress, dan raih prestasi terbaikmu',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark
                                  ? AppThemes.darkTextSecondary
                                  : AppThemes.hintColor,
                              height: 1.5,
                              fontSize: 14,
                              letterSpacing: 0.2,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(
                              height: screenHeight * 0.04), // Jarak dinamis

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
                                    'Masuk & Eksplor!',
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
                                foregroundColor: isDark
                                    ? AppThemes.darkAccentBlue
                                    : AppThemes.primaryColor,
                                side: BorderSide(
                                  color: isDark
                                      ? AppThemes.darkAccentBlue
                                      : AppThemes.primaryColor,
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
                                    'Daftar Akun Baru',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                      color: isDark
                                          ? AppThemes.darkAccentBlue
                                          : AppThemes.primaryColor,
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
                              color: isDark
                                  ? AppThemes.darkAccentBlue.withOpacity(0.1)
                                  : AppThemes.primaryColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? AppThemes.darkAccentBlue.withOpacity(0.3)
                                    : AppThemes.primaryColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people,
                                  color: isDark
                                      ? AppThemes.darkAccentBlue
                                      : AppThemes.primaryColor,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Gabung dengan komunitas magang terbaik',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: isDark
                                          ? AppThemes.darkTextSecondary
                                          : AppThemes.hintColor,
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

                      // Spacer bawah agar tidak mepet di scroll paling bawah
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
