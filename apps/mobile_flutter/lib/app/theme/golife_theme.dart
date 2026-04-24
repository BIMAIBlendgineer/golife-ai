import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildGoLifeTheme() {
  const colorScheme = ColorScheme.light(
    primary: Color(0xFFD06447),
    secondary: Color(0xFF5D7A68),
    tertiary: Color(0xFF8A6C2F),
    surface: Color(0xFFFFF7EC),
    error: Color(0xFFB3432F),
  );

  final baseText = GoogleFonts.manropeTextTheme();
  final display = GoogleFonts.dmSerifDisplayTextTheme();

  return ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: const Color(0xFFF6EEDD),
    textTheme: baseText.copyWith(
      headlineLarge: display.headlineLarge,
      headlineMedium: display.headlineMedium,
      headlineSmall: display.headlineSmall,
      titleLarge: baseText.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      titleMedium: baseText.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      bodyLarge: baseText.bodyLarge?.copyWith(height: 1.4),
      bodyMedium: baseText.bodyMedium?.copyWith(
        height: 1.45,
        color: const Color(0xFF5C514A),
      ),
    ),
    useMaterial3: true,
    cardTheme: const CardThemeData(
      color: Color(0xFFFFFBF4),
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
