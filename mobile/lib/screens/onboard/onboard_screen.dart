import 'package:flutter/material.dart';

import '../../navigation/route_names.dart';
import '../../themes/app_themes.dart';
import '../../widgets/onboard/onboard_button.dart';
import '../../widgets/onboard/onboard_indicator.dart';
import 'onboard_page1.dart';
import 'onboard_page2.dart';
import 'onboard_page3.dart';

class OnboardScreen extends StatefulWidget {
  const OnboardScreen({super.key});

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Widget> _onboardPages = [
    const OnboardPage1(),
    const OnboardPage2(),
    const OnboardPage3(),
  ];

  void _onNext() {
    if (_currentPage < _onboardPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Last page - navigate to welcome screen
      Navigator.pushReplacementNamed(context, RouteNames.onboardWelcome);
    }
  }

  void _onSkip() {
    Navigator.pushReplacementNamed(context, RouteNames.onboardWelcome);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppThemes.darkBackground
          : AppThemes
                .backgroundColor, // Changed to backgroundColor for consistency
      body: SafeArea(
        child: Column(
          children: [
            // KEEP Skip Button (top right) - ADDED BACK
            if (_currentPage < _onboardPages.length - 1)
              Align(
                alignment: Alignment.topRight,
                child: Padding(padding: const EdgeInsets.all(16.0)),
              ),

            // Page View
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: _onboardPages,
              ),
            ),

            // Indicators menggunakan komponen terpisah
            OnboardIndicator(
              currentPage: _currentPage,
              pageCount: _onboardPages.length,
            ),

            // Next Button menggunakan komponen terpisah - CENTERED
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: OnboardButton(
                currentPage: _currentPage,
                pageCount: _onboardPages.length,
                onNext: _onNext,
                onSkip: _onSkip,
              ),
            ),

            const SizedBox(height: 16),
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
