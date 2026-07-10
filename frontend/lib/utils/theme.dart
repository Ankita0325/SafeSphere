import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryPink = Color(0xFFE4406C);
  static const Color accentPink = Color(0xFFFF4D8A);
  static const Color primaryPurple = Color(0xFF6E3FB0);
  static const Color accentPurple = Color(0xFF8A3FFC);
  static const Color accentViolet = Color(0xFF8A3FFC);
  static const Color deepPurple = Color(0xFF5A2D91);
  static const Color lavender = Color(0xFFC58FA7);
  
  // Neutral Colors (Dark Neon Theme)
  static const Color backgroundColor = Color(0xFF09061F);
  static const Color secondaryBackground = Color(0xFF150F2B);
  static const Color cardColor = Color(0xFF2A233C);
  static const Color elevatedCardColor = Color(0xFF463F5B);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFD6D2E8);
  static const Color textDisabled = Color(0xFF6B6785);
  static const Color border = Color(0xFF3C3557);
  static const Color divider = Color(0xFF2B2644);
  
  // Status Colors
  static const Color safeGreen = Color(0xFF46D369);
  static const Color warningOrange = Color(0xFFFFC857);
  static const Color dangerRed = Color(0xFFF44336);
  static const Color locationBlue = Color(0xFF4D9EFF);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primaryPink,
      secondary: primaryPurple,
      surface: cardColor,
      error: dangerRed,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
    ),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryPurple,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryPink,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    ),
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: border, width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: secondaryBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: accentPink, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: textSecondary),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textWhite),
      bodyMedium: TextStyle(color: textSecondary),
      titleLarge: TextStyle(color: textWhite, fontWeight: FontWeight.bold),
    ),
  );

  static ThemeData darkTheme = lightTheme;
}
