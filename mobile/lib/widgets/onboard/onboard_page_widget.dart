import 'package:flutter/material.dart';

import '../../../models/onboard_model.dart';
import '../../../themes/app_themes.dart';

class OnboardPageWidget extends StatelessWidget {
  final OnboardPage page;

  const OnboardPageWidget({Key? key, required this.page}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image
          Expanded(
            flex: 2,
            child: Image.asset(
              page.imageUrl,
              fit: BoxFit.contain,
              width: double.infinity,
            ),
          ),
          const SizedBox(height: 40),
          // Title
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Description
          Text(
            page.description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Pindahkan fungsi ini ke file terpisah atau hapus jika tidak digunakan
Widget _getIconForPage(OnboardPage page, bool isDark) {
  if (page.title.contains('Welcome')) {
    return Icon(
      Icons.work_outline_rounded,
      size: 100,
      color: isDark ? AppThemes.darkAccentBlue : AppThemes.primaryColor,
    );
  } else if (page.title.contains('QR Code')) {
    return Icon(
      Icons.qr_code_scanner_rounded,
      size: 100,
      color: isDark ? AppThemes.darkAccentBlue : AppThemes.primaryColor,
    );
  } else {
    return Icon(
      Icons.bar_chart_rounded,
      size: 100,
      color: isDark ? AppThemes.darkAccentBlue : AppThemes.primaryDark,
    );
  }
}
