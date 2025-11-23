import 'package:flutter/material.dart';

import '../../themes/app_themes.dart';

class OnboardIndicator extends StatelessWidget {
  final int currentPage;
  final int pageCount;

  const OnboardIndicator({
    super.key,
    required this.currentPage,
    required this.pageCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: currentPage == index ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: currentPage == index
                ? AppThemes.primaryColor
                : (isDark
                      ? AppThemes.darkOutline
                      : AppThemes.hintColor.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
