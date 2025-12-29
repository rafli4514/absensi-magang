import 'package:flutter/material.dart';

import '../../models/onboard_model.dart';
import '../../navigation/route_names.dart';
import '../../themes/app_themes.dart';
import '../../widgets/onboard/onboard_button.dart';
import '../../widgets/onboard/onboard_indicator.dart';
import '../../widgets/onboard/onboard_page_widget.dart';

class OnboardScreen extends StatefulWidget {
  const OnboardScreen({super.key});

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Data Onboarding Bahasa Indonesia
  final List<OnboardPage> _pages = [
    OnboardPage(
      id: '1',
      title: 'Selamat Datang di MyInternPlus!',
      description:
          'Bikin magang jadi lebih mudah dan terorganisir! Kelola absensi, pantau aktivitas, dan catat progres belajarmu dalam satu aplikasi.',
      imageUrl: 'assets/images/Mascot1.png',
      order: 1,
    ),
    OnboardPage(
      id: '2',
      title: 'Absensi Cuma Sekali Scan!',
      description:
          'Tinggal scan QR Code, langsung absen dalam hitungan detik! Cepat, akurat, dan anti ribet.',
      imageUrl: 'assets/images/Mascot2.png',
      order: 2,
    ),
    OnboardPage(
      id: '3',
      title: 'Pantau Progres Magangmu!',
      description:
          'Lihat riwayat absensi, aktivitas harian, dan perkembangan skill-mu secara real-time.',
      imageUrl: 'assets/images/Mascot3.png',
      order: 3,
    ),
  ];

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, RouteNames.onboardWelcome);
    }
  }

  void _onSkip() {
    Navigator.pushReplacementNamed(context, RouteNames.onboardWelcome);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppThemes.darkBackground : AppThemes.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            if (_currentPage < _pages.length - 1)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16, top: 16),
                  child: TextButton(
                    onPressed: _onSkip,
                    child: Text(
                      'Lewati', // Translate
                      style: TextStyle(
                        color: isDark
                            ? AppThemes.darkTextSecondary
                            : AppThemes.hintColor,
                      ),
                    ),
                  ),
                ),
              )
            else
              const SizedBox(height: 64),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  return OnboardPageWidget(page: _pages[index]);
                },
              ),
            ),
            OnboardIndicator(
              currentPage: _currentPage,
              pageCount: _pages.length,
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: OnboardButton(
                currentPage: _currentPage,
                pageCount: _pages.length,
                onNext: _onNext,
                onSkip: _onSkip,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
