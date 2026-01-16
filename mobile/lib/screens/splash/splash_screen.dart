import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../widgets/loading_indicator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String appVersion = 'V.1.0.0';

  @override
  void initState() {
    super.initState();
    _getAppVersion();
    // Logic initialization is now handled by AuthGate
  }

  // Method untuk mendapatkan info versi aplikasi
  Future<void> _getAppVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        appVersion = 'v${packageInfo.version} (${packageInfo.buildNumber})';
      });
    } catch (e) {
      // Fallback jika gagal mendapatkan versi
      setState(() {
        appVersion = 'v1.0.0';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Menggunakan warna onSurfaceVariant agar adaptif terhadap tema (gelap/terang)
    final textColor = theme.colorScheme.onSurfaceVariant;

    return Scaffold(
      // Menggunakan background scaffold dari tema
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Konten utama di tengah
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo
                  Image.asset(
                    'assets/images/InternLogoExpand.png',
                    width: 220,
                    height: 220,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 32),
                  // Menggunakan LoadingIndicator
                  const LoadingIndicator(message: 'Memuat...'),
                ],
              ),
            ),

            // Informasi versi dan copyright di bagian bawah
            Positioned(
              bottom: 24, // Jarak dari bawah
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // Versi aplikasi
                  if (appVersion.isNotEmpty)
                    Text(
                      appVersion,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: textColor.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),

                  const SizedBox(height: 8),

                  // Copyright
                  Text(
                    '© 2024 Aro Fakhrur Riziq. All rights reserved.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: textColor.withOpacity(0.5),
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
