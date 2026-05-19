import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../features/shared/premium_ui.dart';

ThemeData buildGoLifeTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final colorScheme = isDark
      ? const ColorScheme.dark(
          primary: GoLifePalette.violetBright,
          secondary: GoLifePalette.blue,
          tertiary: GoLifePalette.emerald,
          surface: GoLifePalette.surface800,
          error: GoLifePalette.danger,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: GoLifePalette.textPrimary,
        )
      : const ColorScheme.light(
          primary: GoLifePalette.violet,
          secondary: GoLifePalette.blue,
          tertiary: GoLifePalette.emerald,
          surface: Color(0xFFF4F7FF),
          error: GoLifePalette.danger,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Color(0xFF10182D),
        );

  final bodyTheme = GoogleFonts.manropeTextTheme();
  final displayTheme = GoogleFonts.spaceGroteskTextTheme();
  final inputFill = isDark
      ? GoLifePalette.ink700.withValues(alpha: 0.96)
      : Colors.white.withValues(alpha: 0.92);
  final surface = isDark ? GoLifePalette.surface800 : const Color(0xFFF5F7FF);
  final surfaceAlt =
      isDark ? GoLifePalette.surface700 : const Color(0xFFEFF3FF);
  final line = isDark ? GoLifePalette.line : const Color(0xFFD7E1FF);

  TextTheme textTheme(TextTheme base) {
    return base.copyWith(
      headlineLarge: displayTheme.headlineLarge?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.2,
      ),
      headlineMedium: displayTheme.headlineMedium?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.9,
      ),
      headlineSmall: displayTheme.headlineSmall?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
      ),
      titleLarge: bodyTheme.titleLarge?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w800,
      ),
      titleMedium: bodyTheme.titleMedium?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
      titleSmall: bodyTheme.titleSmall?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: bodyTheme.bodyLarge?.copyWith(
        color: isDark ? GoLifePalette.textPrimary : colorScheme.onSurface,
        height: 1.45,
      ),
      bodyMedium: bodyTheme.bodyMedium?.copyWith(
        color: isDark ? GoLifePalette.textSecondary : const Color(0xFF43506E),
        height: 1.45,
      ),
      bodySmall: bodyTheme.bodySmall?.copyWith(
        color: isDark ? GoLifePalette.textMuted : const Color(0xFF667493),
        height: 1.35,
      ),
      labelLarge: bodyTheme.labelLarge?.copyWith(
        color: isDark ? GoLifePalette.textPrimary : colorScheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
      labelMedium: bodyTheme.labelMedium?.copyWith(
        color: isDark ? GoLifePalette.textSecondary : const Color(0xFF5A6786),
        fontWeight: FontWeight.w600,
      ),
    );
  }

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor:
        isDark ? GoLifePalette.surface900 : const Color(0xFFEEF3FF),
    canvasColor: surface,
    dividerColor: line,
    textTheme: textTheme(bodyTheme),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: isDark ? GoLifePalette.surface700 : Colors.white,
      contentTextStyle: bodyTheme.bodyMedium?.copyWith(
        color: isDark ? GoLifePalette.textPrimary : const Color(0xFF10182D),
      ),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(26),
        side: BorderSide(color: line),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceAlt,
      selectedColor: GoLifePalette.violet.withValues(alpha: 0.24),
      side: BorderSide(color: line),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      labelStyle: bodyTheme.labelLarge?.copyWith(
        color: isDark ? GoLifePalette.textSecondary : const Color(0xFF31415E),
        fontWeight: FontWeight.w700,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: inputFill,
      hintStyle: bodyTheme.bodyMedium?.copyWith(
        color: isDark ? GoLifePalette.textMuted : const Color(0xFF7A89AB),
      ),
      labelStyle: bodyTheme.bodyMedium?.copyWith(
        color: isDark ? GoLifePalette.textSecondary : const Color(0xFF5B6989),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(color: line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(color: line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: GoLifePalette.violetBright),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: GoLifePalette.danger),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: GoLifePalette.violet,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: bodyTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor:
            isDark ? GoLifePalette.textPrimary : const Color(0xFF18233D),
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        side: BorderSide(color: line),
        textStyle: bodyTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: GoLifePalette.blue,
        minimumSize: const Size(0, 48),
        textStyle: bodyTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: isDark
          ? GoLifePalette.ink800.withValues(alpha: 0.96)
          : Colors.white.withValues(alpha: 0.95),
      indicatorColor: GoLifePalette.violet.withValues(alpha: 0.2),
      height: 72,
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((states) {
        final selected = states.contains(WidgetState.selected);
        return bodyTheme.labelMedium?.copyWith(
          color: selected
              ? (isDark ? GoLifePalette.textPrimary : const Color(0xFF10182D))
              : (isDark ? GoLifePalette.textMuted : const Color(0xFF63718F)),
          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected
              ? GoLifePalette.violetBright
              : (isDark ? GoLifePalette.textMuted : const Color(0xFF63718F)),
        );
      }),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: Colors.transparent,
      selectedIconTheme: const IconThemeData(color: GoLifePalette.violetBright),
      unselectedIconTheme: IconThemeData(
        color: isDark ? GoLifePalette.textMuted : const Color(0xFF667493),
      ),
      selectedLabelTextStyle: bodyTheme.labelLarge?.copyWith(
        color: isDark ? GoLifePalette.textPrimary : const Color(0xFF10182D),
        fontWeight: FontWeight.w800,
      ),
      unselectedLabelTextStyle: bodyTheme.labelLarge?.copyWith(
        color: isDark ? GoLifePalette.textMuted : const Color(0xFF667493),
      ),
      indicatorColor: GoLifePalette.violet.withValues(alpha: 0.18),
      useIndicator: true,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: isDark ? GoLifePalette.surface800 : Colors.white,
      modalBackgroundColor: isDark ? GoLifePalette.surface800 : Colors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
  );
}
