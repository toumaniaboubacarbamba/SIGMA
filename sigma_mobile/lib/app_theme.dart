import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SigmaColors {
  // Primary
  static const primary = Color(0xFF00652C);
  static const primaryContainer = Color(0xFF15803D);
  static const onPrimary = Color(0xFFFFFFFF);
  static const onPrimaryContainer = Color(0xFFD3FFD5);
  static const primaryFixedDim = Color(0xFF79DB8D);

  // Surface
  static const surface = Color(0xFFF8F9FA);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF3F4F5);
  static const surfaceContainer = Color(0xFFEDEEEF);
  static const surfaceContainerHigh = Color(0xFFE7E8E9);
  static const surfaceContainerHighest = Color(0xFFE1E3E4);

  // On Surface
  static const onSurface = Color(0xFF191C1D);
  static const onSurfaceVariant = Color(0xFF3F493F);
  static const secondary = Color(0xFF5D5F5F);

  // Outline
  static const outline = Color(0xFF6F7A6E);
  static const outlineVariant = Color(0xFFBECABC);

  // Error
  static const error = Color(0xFFBA1A1A);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onError = Color(0xFFFFFFFF);

  // Tertiary
  static const tertiary = Color(0xFF97344A);
  static const tertiaryContainer = Color(0xFFB64C62);

  // Background
  static const background = Color(0xFFF8F9FA);
  static const onBackground = Color(0xFF191C1D);
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: SigmaColors.primary,
        onPrimary: SigmaColors.onPrimary,
        primaryContainer: SigmaColors.primaryContainer,
        onPrimaryContainer: SigmaColors.onPrimaryContainer,
        secondary: SigmaColors.secondary,
        onSecondary: SigmaColors.onPrimary,
        secondaryContainer: Color(0xFFDFE0E0),
        onSecondaryContainer: Color(0xFF616363),
        tertiary: SigmaColors.tertiary,
        onTertiary: SigmaColors.onPrimary,
        tertiaryContainer: SigmaColors.tertiaryContainer,
        onTertiaryContainer: Color(0xFFFFF1F1),
        error: SigmaColors.error,
        onError: SigmaColors.onError,
        errorContainer: SigmaColors.errorContainer,
        onErrorContainer: Color(0xFF93000A),
        surface: SigmaColors.surface,
        onSurface: SigmaColors.onSurface,
        onSurfaceVariant: SigmaColors.onSurfaceVariant,
        outline: SigmaColors.outline,
        outlineVariant: SigmaColors.outlineVariant,
        shadow: Colors.black,
        scrim: Colors.black,
        inverseSurface: Color(0xFF2E3132),
        onInverseSurface: Color(0xFFF0F1F2),
        inversePrimary: Color(0xFF79DB8D),
      ),
      textTheme: GoogleFonts.interTextTheme(),
      scaffoldBackgroundColor: SigmaColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: SigmaColors.surface,
        foregroundColor: SigmaColors.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SigmaColors.surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: SigmaColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: SigmaColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: SigmaColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SigmaColors.primaryContainer,
          foregroundColor: SigmaColors.onPrimary,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: SigmaColors.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: SigmaColors.outlineVariant),
        ),
      ),
    );
  }
}