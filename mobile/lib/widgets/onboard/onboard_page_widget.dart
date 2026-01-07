import 'package:flutter/material.dart';

import '../../models/onboard_model.dart'; // Pastikan model ini ada

class OnboardPageWidget extends StatelessWidget {
  final OnboardPage page;

  const OnboardPageWidget({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Gambar
          Expanded(
            flex: 3,
            child: Image.asset(
              page.imageUrl,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 40),
          // Judul
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          // Deskripsi
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }
}
