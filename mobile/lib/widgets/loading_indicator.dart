import 'dart:math';

import 'package:flutter/material.dart';

import '../themes/app_themes.dart';

class LoadingIndicator extends StatefulWidget {
  final String? message;

  const LoadingIndicator({super.key, this.message});

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDot(0, isDark),
                const SizedBox(width: 8),
                _buildDot(1, isDark),
                const SizedBox(width: 8),
                _buildDot(2, isDark),
              ],
            );
          },
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppThemes.darkTextSecondary : AppThemes.hintColor,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDot(int index, bool isDark) {
    final double animationValue = _controller.value;
    final double offset = (animationValue * 2 * pi + (index * 2 * pi / 3));
    final double scale = 0.5 + (sin(offset) + 1) / 4;

    return Transform.scale(
      scale: scale,
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: isDark ? AppThemes.darkAccentBlue : AppThemes.primaryColor,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
