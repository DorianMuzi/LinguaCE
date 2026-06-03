import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'lingua_scale.dart';
import 'lingua_tokens.dart';

/// Fabrique les [ThemeData] clair et sombre à partir des [LinguaTokens].
///
/// Typographie :
///  • Playfair Display → titres (élégance éditoriale)
///  • Inter            → corps de texte (lisibilité)
///  • Space Mono       → labels / métadonnées (signature technique)
class LinguaTheme {
  LinguaTheme._();

  static ThemeData light() => _build(LinguaTokens.light, Brightness.light);
  static ThemeData dark() => _build(LinguaTokens.dark, Brightness.dark);

  static ThemeData _build(LinguaTokens t, Brightness brightness) {
    final base = ThemeData(brightness: brightness, useMaterial3: true);

    final colorScheme = base.colorScheme.copyWith(
      brightness: brightness,
      primary: t.accent,
      onPrimary: t.onAccent,
      secondary: t.accentStrong,
      onSecondary: t.onAccent,
      surface: t.surfaceRaised,
      onSurface: t.textPrimary,
      error: t.danger,
      onError: Colors.white,
      outline: t.outline,
    );

    return base.copyWith(
      scaffoldBackgroundColor: t.surfaceBase,
      colorScheme: colorScheme,
      extensions: [t],
      textTheme: _textTheme(t),
      cardTheme: CardThemeData(
        color: t.surfaceRaised,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: LinguaRadius.rLg),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: t.surfaceBase,
        foregroundColor: t.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: t.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: t.textPrimary),
      ),
      dividerTheme: DividerThemeData(color: t.outlineSubtle, thickness: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: t.surfaceSunken,
        hintStyle: GoogleFonts.inter(color: t.textTertiary, fontSize: 14),
        labelStyle: GoogleFonts.inter(color: t.textTertiary, fontSize: 14),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: LinguaRadius.rMd,
          borderSide: BorderSide(color: t.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: LinguaRadius.rMd,
          borderSide: BorderSide(color: t.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: LinguaRadius.rMd,
          borderSide: BorderSide(color: t.accent, width: 1.5),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: t.surfaceRaised,
        contentTextStyle: GoogleFonts.inter(color: t.textPrimary),
        shape: const RoundedRectangleBorder(borderRadius: LinguaRadius.rMd),
      ),
    );
  }

  static TextTheme _textTheme(LinguaTokens t) {
    return TextTheme(
      displayLarge: GoogleFonts.playfairDisplay(
        color: t.textPrimary,
        fontSize: 34,
        fontWeight: FontWeight.bold,
        height: 1.1,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        color: t.textPrimary,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: GoogleFonts.playfairDisplay(
        color: t.textPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: GoogleFonts.playfairDisplay(
        color: t.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: GoogleFonts.playfairDisplay(
        color: t.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.inter(
        color: t.textPrimary,
        fontSize: 16,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        color: t.textSecondary,
        fontSize: 14,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.inter(
        color: t.textTertiary,
        fontSize: 12,
        height: 1.4,
      ),
      labelLarge: GoogleFonts.spaceMono(
        color: t.accent,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
      labelSmall: GoogleFonts.spaceMono(
        color: t.textSecondary,
        fontSize: 10,
        letterSpacing: 0.8,
      ),
    );
  }
}
