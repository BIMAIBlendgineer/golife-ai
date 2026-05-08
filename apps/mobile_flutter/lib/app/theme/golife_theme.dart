import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildGoLifeTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final colorScheme = isDark
      ? const ColorScheme.dark(
          primary: Color(0xFFE48B6E),
          secondary: Color(0xFF89A58F),
          tertiary: Color(0xFFD8B36D),
          surface: Color(0xFF171311),
          error: Color(0xFFE37F6D),
        )
      : const ColorScheme.light(
          primary: Color(0xFFD06447),
          secondary: Color(0xFF5D7A68),
          tertiary: Color(0xFF8A6C2F),
          surface: Color(0xFFFFF7EC),
          error: Color(0xFFB3432F),
        );

  final baseText = GoogleFonts.manropeTextTheme();
  final display = GoogleFonts.dmSerifDisplayTextTheme();

  return ThemeData(
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor:
        isDark ? const Color(0xFF120F0D) : const Color(0xFFF6EEDD),
    textTheme: baseText.copyWith(
      headlineLarge: display.headlineLarge,
      headlineMedium: display.headlineMedium,
      headlineSmall: display.headlineSmall,
      titleLarge: baseText.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      titleMedium: baseText.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      bodyLarge: baseText.bodyLarge?.copyWith(height: 1.4),
      bodyMedium: baseText.bodyMedium?.copyWith(
        height: 1.45,
        color: isDark ? const Color(0xFFE2D5CC) : const Color(0xFF5C514A),
      ),
    ),
    useMaterial3: true,
    cardTheme: CardThemeData(
      color: isDark ? const Color(0xFF201A17) : const Color(0xFFFFFBF4),
      elevation: 0,
      margin: EdgeInsets.zero,
    ),
    chipTheme: const ChipThemeData(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      side: BorderSide.none,
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
    ),
  );
}
