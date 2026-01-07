import 'package:flutter/material.dart';

import '../themes/app_themes.dart';

class CustomErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const CustomErrorWidget({
    super.key,
    required this.message,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    // Tidak perlu isDark lagi, pakai color constant langsung atau Theme
    // Untuk error, kita pakai warna merah konsisten

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppThemes.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppThemes.errorColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppThemes.errorColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppThemes.errorColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon:
                const Icon(Icons.close, size: 18, color: AppThemes.errorColor),
            onPressed: onDismiss,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
