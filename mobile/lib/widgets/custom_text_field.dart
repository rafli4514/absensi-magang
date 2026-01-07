import 'package:flutter/material.dart';

import '../themes/app_themes.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool isPassword;
  final bool readOnly;
  final VoidCallback? onTap;
  final int maxLines;
  final Widget? suffixIcon;
  final Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
    this.suffixIcon,
    this.onChanged,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    // 1. FIX TEMA: Gunakan ColorScheme agar otomatis Dark/Light Mode
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Deteksi mode Picker (ReadOnly + ada OnTap)
    final bool isPicker = widget.readOnly && widget.onTap != null;

    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscureText : false,
      keyboardType: widget.keyboardType,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      onChanged: widget.onChanged,
      maxLines: widget.maxLines,
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,

      // 2. FIX WEB CRASH:
      // Jangan gunakan AbsorbPointer. Matikan interaksi seleksi & kursor jika ini Picker.
      enableInteractiveSelection: !isPicker,
      showCursor: !isPicker,

      // Style Text Input
      style: TextStyle(
        fontSize: 13,
        color: colorScheme.onSurface, // Warna teks utama
        fontWeight: FontWeight.w500,
      ),

      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurfaceVariant, // Warna label
        ),
        hintText: widget.hint,
        hintStyle: TextStyle(
          fontSize: 13,
          color: colorScheme.onSurfaceVariant.withOpacity(0.5), // Warna hint
        ),
        filled: true,
        // Background Color (Adaptif)
        fillColor: widget.readOnly
            ? colorScheme.surfaceContainerHigh.withOpacity(0.5)
            : colorScheme.surfaceContainer,

        prefixIcon: Icon(
          widget.icon,
          color: widget.readOnly
              ? colorScheme.onSurfaceVariant.withOpacity(0.5)
              : AppThemes.primaryColor,
          size: 18,
        ),

        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppThemes.primaryColor,
                  size: 18,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(maxWidth: 36),
              )
            : widget.suffixIcon ??
                (isPicker
                    ? const Icon(
                        Icons.arrow_drop_down_rounded,
                        color: AppThemes.primaryColor,
                      )
                    : null),

        // Borders (Menggunakan outline color dari tema)
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: colorScheme.outline.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: colorScheme.outline.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppThemes.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppThemes.errorColor, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppThemes.errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        isDense: true,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
    );
  }
}
