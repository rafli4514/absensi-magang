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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscureText : false,
      keyboardType: widget.keyboardType,
      readOnly: widget.readOnly,

      // --- PERBAIKAN DI SINI (WRAPPER ONTAP) ---
      // Membungkus onTap agar return type-nya dipaksa menjadi void
      // Ini mencegah error interop pada fungsi async
      onTap: widget.onTap != null
          ? () {
              widget.onTap!();
            }
          : null,

      onChanged: widget.onChanged,
      maxLines: widget.maxLines,
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: TextStyle(
        fontSize: 13,
        color: isDark ? AppThemes.darkTextPrimary : AppThemes.onSurfaceColor,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isDark ? AppThemes.darkTextSecondary : AppThemes.hintColor,
        ),
        hintText: widget.hint,
        hintStyle: TextStyle(
          fontSize: 13,
          color: isDark
              ? AppThemes.darkTextTertiary
              : AppThemes.hintColor.withOpacity(0.5),
        ),
        filled: true,
        fillColor: widget.readOnly
            ? (isDark ? AppThemes.darkSurfaceVariant : Colors.grey.shade100)
            : (isDark ? AppThemes.darkSurface : Colors.white),
        prefixIcon: Icon(
          widget.icon,
          color: widget.readOnly
              ? (isDark ? AppThemes.darkTextTertiary : Colors.grey)
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
                ((widget.readOnly && widget.onTap != null)
                    ? const Icon(
                        Icons.arrow_drop_down_rounded,
                        color: AppThemes.primaryColor,
                      )
                    : null),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDark ? AppThemes.darkOutline : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDark ? AppThemes.darkOutline : Colors.grey.shade300,
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
