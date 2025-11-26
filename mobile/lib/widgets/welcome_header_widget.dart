import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../themes/app_themes.dart';
import '../utils/indonesian_time.dart';

class WelcomeHeaderWidget extends StatelessWidget {
  const WelcomeHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (isDark ? AppThemes.darkAccentBlue : AppThemes.primaryColor)
                .withOpacity(0.15),
            (isDark ? AppThemes.primaryDark : AppThemes.primaryLight)
                .withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppThemes.darkAccentBlue : AppThemes.primaryColor)
                .withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: isDark
            ? Border.all(
                color: AppThemes.darkOutline.withOpacity(0.3),
                width: 0.5,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting and Time Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting with animated emoji
                    Row(
                      children: [
                        _buildAnimatedEmoji(
                          IndonesianTime.getGreeting(),
                          isDark,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${IndonesianTime.getGreeting()}!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppThemes.darkTextSecondary
                                : AppThemes.hintColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // User Name with badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user?.name ?? user?.displayName ?? "User",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppThemes.darkTextPrimary
                                  : AppThemes.onSurfaceColor,
                              height: 1.1,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                (isDark
                                        ? AppThemes.darkAccentBlue
                                        : AppThemes.primaryColor)
                                    .withOpacity(0.8),
                                (isDark
                                        ? AppThemes.primaryDark
                                        : AppThemes.primaryDark)
                                    .withOpacity(0.9),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user?.department ?? "Department",
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Position/Role
                    if (user?.position != null)
                      Text(
                        user!.position!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color:
                              (isDark
                                      ? AppThemes.darkAccentBlue
                                      : AppThemes.primaryColor)
                                  .withOpacity(0.8),
                        ),
                      ),
                  ],
                ),
              ),
              // Time Display with modern design
              _buildTimeDisplay(isDark),
            ],
          ),
          const SizedBox(height: 20),
          // Motivational Message with Progress
          _buildMotivationalSection(isDark),
        ],
      ),
    );
  }

  Widget _buildAnimatedEmoji(String greeting, bool isDark) {
    String emoji = '👋';
    if (greeting.contains('Pagi')) emoji = '🌅';
    if (greeting.contains('Siang')) emoji = '☀️';
    if (greeting.contains('Sore')) emoji = '🌇';
    if (greeting.contains('Malam')) emoji = '🌙';

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: (isDark ? AppThemes.darkAccentBlue : AppThemes.primaryColor)
            .withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 16)),
    );
  }

  Widget _buildTimeDisplay(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppThemes.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: isDark
            ? Border.all(color: AppThemes.darkOutline, width: 0.5)
            : null,
      ),
      child: Column(
        children: [
          Text(
            IndonesianTime.getFormattedTime(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isDark
                  ? AppThemes.darkTextPrimary
                  : AppThemes.onSurfaceColor,
            ),
          ),
          Text(
            IndonesianTime.getFormattedDateOnly(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? AppThemes.darkTextSecondary : AppThemes.hintColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationalSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppThemes.darkSurface : AppThemes.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.1 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Animated Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
                  (isDark ? AppThemes.darkAccentBlue : AppThemes.primaryColor)
                      .withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getMotivationalIcon(),
              size: 20,
              color: isDark ? AppThemes.darkAccentBlue : AppThemes.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getMotivationalMessage(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppThemes.darkTextPrimary
                        : AppThemes.onSurfaceColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Have a productive day! 🌟',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppThemes.darkTextSecondary
                        : AppThemes.hintColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMotivationalIcon() {
    final hour = DateTime.now().hour;
    if (hour < 12) return Icons.wb_sunny_rounded;
    if (hour < 15) return Icons.light_mode_rounded;
    if (hour < 18) return Icons.brightness_5_rounded;
    return Icons.nightlight_round_rounded;
  }

  String _getMotivationalMessage() {
    final hour = DateTime.now().hour;
    if (hour < 10) return 'Start your day with great energy!';
    if (hour < 14) return 'Keep up the good work!';
    if (hour < 17) return 'Stay focused and productive!';
    return 'Finish strong today!';
  }
}
