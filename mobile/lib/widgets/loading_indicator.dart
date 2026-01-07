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
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (index) {
                  return _buildDot(index, colorScheme);
                }),
              );
            },
          ),
          if (widget.message != null) ...[
            const SizedBox(height: 12),
            Text(
              widget.message!,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDot(int index, ColorScheme colorScheme) {
    final double animationValue = _controller.value;
    final double offset = (animationValue * 2 * pi + (index * 2 * pi / 3));
    final double scale = 0.5 + (sin(offset) + 1) / 4;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: AppThemes.primaryColor,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
