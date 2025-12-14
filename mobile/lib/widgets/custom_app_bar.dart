import 'package:flutter/material.dart';

import '../themes/app_themes.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final Color? backgroundColor;
  final double? elevation;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.backgroundColor,
    this.elevation,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      // title: Text(
      //   title,
      //   style: theme.textTheme.titleLarge?.copyWith(
      //     fontWeight: FontWeight.w700,
      //     color: isDark ? AppThemes.darkTextPrimary : AppThemes.onSurfaceColor,
      //   ),
      // ),
      // Jika Anda menggunakan Logo sebagai title, gunakan ini:
      title: Image.asset('assets/images/InternLogoExpand.png', height: 40),

      leading: showBackButton
          ? IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: isDark
                    ? AppThemes.darkTextPrimary
                    : AppThemes.onSurfaceColor,
              ),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      actions: actions,
      elevation: elevation ?? (isDark ? 0 : 0.5),
      backgroundColor: backgroundColor ??
          (isDark ? AppThemes.darkSurfaceVariant : AppThemes.surfaceColor),
      surfaceTintColor:
          isDark ? AppThemes.darkSurfaceVariant : AppThemes.surfaceColor,
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: isDark ? AppThemes.darkOutline : Colors.grey.withOpacity(0.2),
          height: 1,
        ),
      ),
    );
  }
}
