import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF1A56FF);
  static const Color primaryDark = Color(0xFF0038CC);
  static const Color primarySecondary = Color(0xFF00D4AA);
  static const Color accent = Color(0xFFFF5733);
  static const Color bgLight = Color(0xFFF2F5FF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF0C1445);
  static const Color textLight = Color(0xFF6B7280);
  static const Color borderLight = Color(0xFFE4EAF8);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color gold = Color(0xFFF59E0B);
  static const Color elite = Color(0xFF7C3AED);

  static const Color bgDark = Color(0xFF0A0F2E);
  static const Color cardDark = Color(0xFF141B3C);
  static const Color textDarkMode = Color(0xFFE8EDFF);
  static const Color textLightDark = Color(0xFF8891B4);
  static const Color borderDark = Color(0xFF1E2A4A);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primary,
    scaffoldBackgroundColor: bgLight,
    fontFamily: GoogleFonts.nunito().fontFamily,
    colorScheme: ColorScheme.light(
      primary: primary,
      secondary: primarySecondary,
      surface: cardLight,
      error: error,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: cardLight,
      foregroundColor: textDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        color: textDark,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardTheme(
      color: cardLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: bgLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primary, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textTheme: GoogleFonts.nunitoTextTheme().copyWith(
      headlineLarge: GoogleFonts.poppins(
        color: textDark,
        fontSize: 28,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: GoogleFonts.poppins(
        color: textDark,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: GoogleFonts.poppins(
        color: textDark,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: GoogleFonts.nunito(
        color: textDark,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.nunito(color: textDark, fontSize: 16),
      bodyMedium: GoogleFonts.nunito(color: textDark, fontSize: 14),
      bodySmall: GoogleFonts.nunito(color: textLight, fontSize: 12),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: cardLight,
      selectedItemColor: primary,
      unselectedItemColor: textLight,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    dividerTheme: DividerThemeData(color: borderLight, thickness: 1),
    chipTheme: ChipThemeData(
      backgroundColor: bgLight,
      selectedColor: primary.withValues(alpha: 0.1),
      labelStyle: TextStyle(color: textDark),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: borderLight),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primary,
    scaffoldBackgroundColor: bgDark,
    fontFamily: GoogleFonts.nunito().fontFamily,
    colorScheme: ColorScheme.dark(
      primary: primary,
      secondary: primarySecondary,
      surface: cardDark,
      error: error,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: cardDark,
      foregroundColor: textDarkMode,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        color: textDarkMode,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardTheme(
      color: cardDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primary, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textTheme: GoogleFonts.nunitoTextTheme().copyWith(
      headlineLarge: GoogleFonts.poppins(
        color: textDarkMode,
        fontSize: 28,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: GoogleFonts.poppins(
        color: textDarkMode,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: GoogleFonts.poppins(
        color: textDarkMode,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: GoogleFonts.nunito(
        color: textDarkMode,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.nunito(color: textDarkMode, fontSize: 16),
      bodyMedium: GoogleFonts.nunito(color: textDarkMode, fontSize: 14),
      bodySmall: GoogleFonts.nunito(color: textLightDark, fontSize: 12),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: cardDark,
      selectedItemColor: primary,
      unselectedItemColor: textLightDark,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    dividerTheme: DividerThemeData(color: borderDark, thickness: 1),
    chipTheme: ChipThemeData(
      backgroundColor: cardDark,
      selectedColor: primary.withValues(alpha: 0.2),
      labelStyle: TextStyle(color: textDarkMode),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: borderDark),
      ),
    ),
  );
}
