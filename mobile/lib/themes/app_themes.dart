import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Centralized theme system for the entire app
/// 
/// Usage in widgets:
/// ```dart
/// final colors = Theme.of(context).extension<AppColors>()!;
/// Text('Hello', style: TextStyle(color: colors.textPrimary))
/// ```
class AppThemes {
  // --- STATIC COLORS (Deprecated - use theme extensions instead) ---
  @Deprecated('Use Theme.of(context).colorScheme.primary')
  static const Color primaryColor = Color(0xFF14A2BA);
  
  @Deprecated('Use Theme.of(context).colorScheme.secondary')
  static const Color secondaryColor = Color(0xFF2E3840);
  
  @Deprecated('Use Theme.of(context).extension<AppColors>()!.success')
  static const Color successColor = Color(0xFF27AE60);
  
  @Deprecated('Use Theme.of(context).extension<AppColors>()!.warning')
  static const Color warningColor = Color(0xFFF39C12);

  @Deprecated('Use Theme.of(context).colorScheme.error')
  static const Color errorColor = Color(0xFFE74C3C);

  @Deprecated('Use Theme.of(context).extension<AppColors>()!.info')
  static const Color infoColor = Color(0xFF3498DB);

  @Deprecated('Use Theme.of(context).extension<AppColors>()!.neutral')
  static const Color neutralColor = Color(0xFF95A5A6);

  // --- LIGHT THEME ---
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: const Color(0xFF14A2BA),
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
    
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF14A2BA),
      onPrimary: Color(0xFFFFFFFF),
      secondary: Color(0xFF2E3840),
      onSecondary: Color(0xFFFFFFFF),
      error: Color(0xFFE74C3C),
      onError: Color(0xFFFFFFFF),
      surface: Color(0xFFF8F9FA),
      onSurface: Color(0xFF2E3840),
      onSurfaceVariant: Color(0xFF6C757D),
      outline: Color(0xFFE0E0E0),
      surfaceContainer: Color(0xFFFFFFFF),
      surfaceContainerHigh: Color(0xFFF1F3F5),
      surfaceContainerHighest: Color(0xFFE9ECEF),
    ),
    
    extensions: const <ThemeExtension>[
      AppColors(
        success: Color(0xFF27AE60),
        successLight: Color(0xFFD4EDDA),
        warning: Color(0xFFF39C12),
        warningLight: Color(0xFFFFF3CD),
        info: Color(0xFF3498DB),
        infoLight: Color(0xFFD1ECF1),
        neutral: Color(0xFF95A5A6),
        neutralLight: Color(0xFFE9ECEF),
        textPrimary: Color(0xFF2E3840),
        textSecondary: Color(0xFF6C757D),
        textHint: Color(0xFFAAAAAA),
        divider: Color(0xFFE0E0E0),
        shadow: Color(0x14000000),
        overlay: Color(0x80000000),
      ),
    ],
    
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF8F9FA),
      foregroundColor: Color(0xFF2E3840),
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
    
    cardTheme: const CardThemeData(
      color: Color(0xFFFFFFFF),
      elevation: 2,
      margin: EdgeInsets.zero,
      shadowColor: Color(0x14000000),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFFFFFFF),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF14A2BA), width: 2),
      ),
      hintStyle: const TextStyle(color: Color(0xFFAAAAAA)),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: const Color(0xFFFFFFFF),
        backgroundColor: const Color(0xFF14A2BA),
        elevation: 2,
        shadowColor: const Color(0x40000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
  );

  // --- DARK THEME ---
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF14A2BA),
    scaffoldBackgroundColor: const Color(0xFF121212),
    
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF14A2BA),
      onPrimary: Color(0xFFFFFFFF),
      secondary: Color(0xFF5DD5F4),
      onSecondary: Color(0xFF1E1E1E),
      error: Color(0xFFCF6679),
      onError: Color(0xFF000000),
      surface: Color(0xFF121212),
      onSurface: Color(0xFFE0E0E0),
      onSurfaceVariant: Color(0xFFA0A0A0),
      outline: Color(0xFF404040),
      surfaceContainer: Color(0xFF1E1E1E),
      surfaceContainerHigh: Color(0xFF2C2C2C),
      surfaceContainerHighest: Color(0xFF383838),
    ),
    
    extensions: const <ThemeExtension>[
      AppColors(
        success: Color(0xFF27AE60),
        successLight: Color(0xFF1E4D2B),
        warning: Color(0xFFF39C12),
        warningLight: Color(0xFF4D3610),
        info: Color(0xFF3498DB),
        infoLight: Color(0xFF1E3A52),
        neutral: Color(0xFF95A5A6),
        neutralLight: Color(0xFF404040),
        textPrimary: Color(0xFFE0E0E0),
        textSecondary: Color(0xFFA0A0A0),
        textHint: Color(0xFF666666),
        divider: Color(0xFF404040),
        shadow: Color(0x4D000000),
        overlay: Color(0xCC000000),
      ),
    ],
    
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF121212),
      foregroundColor: Color(0xFFE0E0E0),
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    
    cardTheme: const CardThemeData(
      color: Color(0xFF1E1E1E),
      elevation: 0,
      margin: EdgeInsets.zero,
      shadowColor: Color(0x00000000),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        side: BorderSide(color: Color(0xFF333333), width: 1),
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF404040)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF404040)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF14A2BA), width: 2),
      ),
      hintStyle: const TextStyle(color: Color(0xFF666666)),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: const Color(0xFFFFFFFF),
        backgroundColor: const Color(0xFF14A2BA),
        elevation: 0,
        shadowColor: const Color(0x00000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
  );
}

/// Custom color extension for semantic colors
/// 
/// Access via: Theme.of(context).extension<AppColors>()!
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color success;
  final Color successLight;
  final Color warning;
  final Color warningLight;
  final Color info;
  final Color infoLight;
  final Color neutral;
  final Color neutralLight;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color divider;
  final Color shadow;
  final Color overlay;

  const AppColors({
    required this.success,
    required this.successLight,
    required this.warning,
    required this.warningLight,
    required this.info,
    required this.infoLight,
    required this.neutral,
    required this.neutralLight,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.divider,
    required this.shadow,
    required this.overlay,
  });

  @override
  AppColors copyWith({
    Color? success,
    Color? successLight,
    Color? warning,
    Color? warningLight,
    Color? info,
    Color? infoLight,
    Color? neutral,
    Color? neutralLight,
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
    Color? divider,
    Color? shadow,
    Color? overlay,
  }) {
    return AppColors(
      success: success ?? this.success,
      successLight: successLight ?? this.successLight,
      warning: warning ?? this.warning,
      warningLight: warningLight ?? this.warningLight,
      info: info ?? this.info,
      infoLight: infoLight ?? this.infoLight,
      neutral: neutral ?? this.neutral,
      neutralLight: neutralLight ?? this.neutralLight,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textHint: textHint ?? this.textHint,
      divider: divider ?? this.divider,
      shadow: shadow ?? this.shadow,
      overlay: overlay ?? this.overlay,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      success: Color.lerp(success, other.success, t)!,
      successLight: Color.lerp(successLight, other.successLight, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningLight: Color.lerp(warningLight, other.warningLight, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoLight: Color.lerp(infoLight, other.infoLight, t)!,
      neutral: Color.lerp(neutral, other.neutral, t)!,
      neutralLight: Color.lerp(neutralLight, other.neutralLight, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
    );
  }
}
