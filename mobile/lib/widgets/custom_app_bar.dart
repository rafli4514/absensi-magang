import 'package:flutter/material.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      // Menggunakan aset logo jika judul kosong, atau teks judul
      title: title.isEmpty
          ? Image.asset('assets/images/InternLogoExpand.png', height: 40)
          : Text(title,
              style: TextStyle(
                  color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
      leading: showBackButton
          ? IconButton(
              icon:
                  Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      actions: actions,
      elevation: elevation ?? 0,
      backgroundColor: backgroundColor ?? colorScheme.surface,
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: colorScheme.outline.withOpacity(0.2),
          height: 1,
        ),
      ),
    );
  }
}
