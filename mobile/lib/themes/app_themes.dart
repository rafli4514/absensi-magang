import 'package:flutter/material.dart';

class AppThemes {
  // Warna utama berdasarkan warna biru QR (#14A2BA)
  static const Color primaryColor = Color(0xFF14A2BA);
  static const Color primaryLight = Color(0xFF5DD5F4);
  static const Color primaryDark = Color(0xFF00728F);

  // Warna sekunder dan netral
  static const Color secondaryColor = Color(0xFF2E3840);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color onSurfaceColor = Color(0xFF2E3840);
  static const Color hintColor = Color(0xFF6C757D);

  // Warna status/semantic colors dengan contrast yang selaras
  static const Color successColor = Color(0xFF27AE60); // Hijau
  static const Color errorColor = Color(0xFFE74C3C); // Merah
  static const Color warningColor = Color(0xFFF39C12); // Orange
  static const Color infoColor = Color(0xFF3498DB); // Biru info
  static const Color neutralColor = Color(0xFF95A5A6); // Abu-abu netral

  // Warna progress states
  static const Color progressSuccess = successColor; // Progress berhasil
  static const Color progressError = errorColor; // Progress error
  static const Color progressWarning = warningColor; // Progress peringatan
  static const Color progressInfo = infoColor; // Progress info
  static const Color progressNeutral = neutralColor; // Progress netral

  // Variasi light untuk background
  static const Color successLight = Color(0xFFE8F5E8);
  static const Color errorLight = Color(0xFFFDEDED);
  static const Color warningLight = Color(0xFFFEF5E7);
  static const Color infoLight = Color(0xFFEBF5FB);
  static const Color neutralLight = Color(0xFFF4F6F6);

  // Variasi dark untuk dark theme
  static const Color successDark = Color(0xFF229954);
  static const Color errorDark = Color(0xFFC0392B);
  static const Color warningDark = Color(0xFFE67E22);
  static const Color infoDark = Color(0xFF2980B9);
  static const Color neutralDark = Color(0xFF7B8A8B);

  // === PALET WARNA DARK THEME YANG DIPERBAIKI ===
  static const Color darkBackground = Color(0xFF121212); // Base background
  static const Color darkSurface = Color(0xFF1E1E1E); // Cards, dialogs, sheets
  static const Color darkSurfaceVariant = Color(
    0xFF252526,
  ); // App bar, bottom nav
  static const Color darkSurfaceElevated = Color(0xFF2D2D2D); // Elevated cards
  static const Color darkOutline = Color(0xFF404040); // Borders, dividers
  static const Color darkOutlineVariant = Color(0xFF333333); // Subtle borders

  // Warna teks dengan opasitas yang tepat
  static const Color darkTextPrimary = Color(
    0xFFFFFFFF,
  ); // White untuk teks utama
  static const Color darkTextSecondary = Color(
    0xFFB0B0B0,
  ); // 60% opacity equivalent
  static const Color darkTextTertiary = Color(
    0xFF808080,
  ); // 38% opacity equivalent
  static const Color darkTextDisabled = Color(
    0xFF666666,
  ); // 26% opacity equivalent

  // Warna aksen untuk dark theme
  static const Color darkAccentBlue = Color(
    0xFF5DD5F4,
  ); // primaryLight sebagai aksen
  static const Color darkAccentCyan = Color(
    0xFF4FD1C5,
  ); // Warna cyan complement

  // Getter untuk warna primary yang bisa diakses dari mana saja
  static Color get qrColor => primaryColor;

  // Helper untuk mendapatkan warna progress berdasarkan status
  static Color getProgressColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'completed':
      case 'berhasil':
        return successColor;
      case 'error':
      case 'failed':
      case 'gagal':
        return errorColor;
      case 'warning':
      case 'pending':
      case 'menunggu':
        return warningColor;
      case 'info':
      case 'processing':
      case 'proses':
        return infoColor;
      default:
        return neutralColor;
    }
  }

  // Helper untuk mendapatkan light color berdasarkan status
  static Color getProgressLightColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'completed':
      case 'berhasil':
        return successLight;
      case 'error':
      case 'failed':
      case 'gagal':
        return errorLight;
      case 'warning':
      case 'pending':
      case 'menunggu':
        return warningLight;
      case 'info':
      case 'processing':
      case 'proses':
        return infoLight;
      default:
        return neutralLight;
    }
  }

  static final lightTheme = ThemeData(
    primaryColor: primaryColor,
    primaryColorLight: primaryLight,
    primaryColorDark: primaryDark,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      background: backgroundColor,
      surface: surfaceColor,
      onSurface: onSurfaceColor,
      error: errorColor,
    ),
    brightness: Brightness.light,
    scaffoldBackgroundColor: backgroundColor,

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: surfaceColor,
      elevation: 1,
      iconTheme: IconThemeData(color: onSurfaceColor),
      titleTextStyle: TextStyle(
        color: onSurfaceColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      hoverElevation: 8,
      focusElevation: 6,
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surfaceColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: hintColor,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: surfaceColor,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
    ),

    // Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      labelStyle: const TextStyle(color: hintColor),
      hintStyle: const TextStyle(color: hintColor),
      errorStyle: const TextStyle(color: errorColor),
    ),

    // Icon Theme
    iconTheme: const IconThemeData(color: onSurfaceColor),

    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: onSurfaceColor,
        fontWeight: FontWeight.w700,
      ),
      displayMedium: TextStyle(
        color: onSurfaceColor,
        fontWeight: FontWeight.w600,
      ),
      displaySmall: TextStyle(
        color: onSurfaceColor,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: TextStyle(
        color: onSurfaceColor,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        color: onSurfaceColor,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(color: onSurfaceColor, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(
        color: onSurfaceColor,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: TextStyle(color: onSurfaceColor, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(color: onSurfaceColor, fontWeight: FontWeight.w400),
      bodyMedium: TextStyle(color: onSurfaceColor, fontWeight: FontWeight.w400),
      bodySmall: TextStyle(color: hintColor, fontWeight: FontWeight.w400),
    ),

    // Divider Theme
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade300,
      thickness: 1,
      space: 1,
    ),

    // Progress Indicator Theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryColor,
      linearTrackColor: Color(0xFFE9ECEF),
    ),
  );

  // === DARK THEME YANG DIPERBAIKI ===
  static final darkTheme = ThemeData(
    primaryColor: primaryColor,
    primaryColorLight: darkAccentBlue, // Gunakan aksen biru yang lebih terang
    primaryColorDark: primaryDark,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: darkAccentBlue, // Gunakan aksen biru untuk secondary
      background: darkBackground,
      surface: darkSurface,
      onSurface: darkTextPrimary,
      onBackground: darkTextPrimary,
      error: errorDark,
    ),
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,

    // AppBar Theme dengan elevation yang lebih jelas
    appBarTheme: const AppBarTheme(
      backgroundColor: darkSurfaceVariant,
      elevation: 2,
      shadowColor: Colors.black54,
      iconTheme: IconThemeData(color: darkTextPrimary),
      titleTextStyle: TextStyle(
        color: darkTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Floating Action Button Theme dengan aksen yang lebih menarik
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 6,
      hoverElevation: 12,
      focusElevation: 8,
      splashColor: darkAccentBlue,
    ),

    // Bottom Navigation Bar Theme dengan depth
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkSurfaceVariant,
      selectedItemColor: darkAccentBlue, // Gunakan aksen biru
      unselectedItemColor: darkTextTertiary,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
    ),

    // Card Theme dengan variasi elevation
    cardTheme: CardThemeData(
      color: darkSurface,
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: darkOutline, width: 0.5),
      ),
      margin: const EdgeInsets.all(8),
    ),

    // Button Theme yang lebih bervariasi
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 3,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        shadowColor: Colors.black.withOpacity(0.5),
      ),
    ),

    // Outlined Button Theme dengan border yang lebih visible
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: darkAccentBlue,
        side: const BorderSide(color: darkAccentBlue, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: Colors.transparent,
      ),
    ),

    // Text Button Theme dengan hover effect yang lebih baik
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: darkAccentBlue,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),

    // Input Decoration Theme yang lebih refined
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurfaceElevated,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: darkOutline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: darkOutline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: darkAccentBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorDark, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorDark, width: 2),
      ),
      labelStyle: const TextStyle(color: darkTextSecondary),
      hintStyle: const TextStyle(color: darkTextTertiary),
      errorStyle: const TextStyle(color: errorDark),
      prefixIconColor: darkTextSecondary,
      suffixIconColor: darkTextSecondary,
    ),

    // Icon Theme dengan variasi warna
    iconTheme: const IconThemeData(color: darkTextPrimary),

    // Action Icon Theme untuk icon yang lebih menonjol
    actionIconTheme: ActionIconThemeData(
      backButtonIconBuilder: (context) =>
          Icon(Icons.arrow_back, color: darkTextPrimary),
    ),

    // Text Theme dengan hierarki yang jelas
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: darkTextPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 32,
      ),
      displayMedium: TextStyle(
        color: darkTextPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 28,
      ),
      displaySmall: TextStyle(
        color: darkTextPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 24,
      ),
      headlineMedium: TextStyle(
        color: darkTextPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 22,
      ),
      headlineSmall: TextStyle(
        color: darkTextPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 20,
      ),
      titleLarge: TextStyle(
        color: darkTextPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      titleMedium: TextStyle(
        color: darkTextPrimary,
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
      titleSmall: TextStyle(
        color: darkTextPrimary,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      bodyLarge: TextStyle(
        color: darkTextPrimary,
        fontWeight: FontWeight.w400,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: darkTextPrimary,
        fontWeight: FontWeight.w400,
        fontSize: 14,
      ),
      bodySmall: TextStyle(
        color: darkTextSecondary,
        fontWeight: FontWeight.w400,
        fontSize: 12,
      ),
      labelLarge: TextStyle(
        color: darkTextPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      labelMedium: TextStyle(
        color: darkTextSecondary,
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
      labelSmall: TextStyle(
        color: darkTextTertiary,
        fontWeight: FontWeight.w400,
        fontSize: 10,
      ),
    ),

    // Divider Theme dengan warna yang sesuai
    dividerTheme: const DividerThemeData(
      color: darkOutline,
      thickness: 1,
      space: 1,
    ),

    // Progress Indicator Theme dengan track yang visible
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: darkAccentBlue,
      linearTrackColor: darkOutline,
      circularTrackColor: darkOutline,
    ),

    // Dialog Theme dengan elevation
    dialogTheme: DialogThemeData(
      backgroundColor: darkSurface,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: darkOutline, width: 0.5),
      ),
      titleTextStyle: const TextStyle(
        color: darkTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: const TextStyle(color: darkTextSecondary, fontSize: 14),
    ),

    // SnackBar Theme dengan warna yang sesuai
    snackBarTheme: SnackBarThemeData(
      backgroundColor: darkSurfaceElevated,
      contentTextStyle: const TextStyle(color: darkTextPrimary),
      actionTextColor: darkAccentBlue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: darkOutline),
      ),
    ),

    // Chip Theme yang konsisten
    chipTheme: ChipThemeData(
      backgroundColor: darkSurfaceElevated,
      selectedColor: primaryColor.withOpacity(0.2),
      secondarySelectedColor: primaryColor.withOpacity(0.2),
      labelStyle: const TextStyle(color: darkTextPrimary),
      secondaryLabelStyle: const TextStyle(color: Colors.white),
      brightness: Brightness.dark,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: darkOutline),
      ),
    ),
  );
}
