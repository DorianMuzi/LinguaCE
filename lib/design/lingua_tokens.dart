import 'package:flutter/material.dart';

/// Tokens de design sémantiques de LinguaCE.
///
/// Exposés via [ThemeExtension] : ils basculent automatiquement entre le
/// thème clair (façon Microsoft 365 Copilot — neutres aérés, accent indigo)
/// et le thème sombre (mêmes neutres assombris, accent indigo clair).
///
/// Accès dans un widget : `context.tokens`.
@immutable
class LinguaTokens extends ThemeExtension<LinguaTokens> {
  // ── Surfaces ───────────────────────────────────────────────────────────
  /// Fond de l'écran (scaffold).
  final Color surfaceBase;

  /// Surface surélevée : cartes, panneaux.
  final Color surfaceRaised;

  /// Surface en creux : champs de saisie, zones secondaires.
  final Color surfaceSunken;

  /// Surface translucide pour les matériaux "glass".
  final Color surfaceGlass;

  // ── Contours ───────────────────────────────────────────────────────────
  final Color outline;
  final Color outlineSubtle;

  // ── Accent (l'or, couleur signature) ───────────────────────────────────
  final Color accent;
  final Color accentSoft;
  final Color accentStrong;
  final Color onAccent;

  // ── Texte ──────────────────────────────────────────────────────────────
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  // ── États ──────────────────────────────────────────────────────────────
  final Color success;
  final Color danger;

  // ── Profondeur ─────────────────────────────────────────────────────────
  final List<BoxShadow> shadowSm;
  final List<BoxShadow> shadowMd;
  final List<BoxShadow> shadowLg;

  /// Dégradé "héros" pour les surfaces de mise en avant.
  final Gradient heroGradient;

  final bool isDark;

  const LinguaTokens({
    required this.surfaceBase,
    required this.surfaceRaised,
    required this.surfaceSunken,
    required this.surfaceGlass,
    required this.outline,
    required this.outlineSubtle,
    required this.accent,
    required this.accentSoft,
    required this.accentStrong,
    required this.onAccent,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.success,
    required this.danger,
    required this.shadowSm,
    required this.shadowMd,
    required this.shadowLg,
    required this.heroGradient,
    required this.isDark,
  });

  // ── Thème CLAIR (Copilot — neutres + accent indigo) ────────────────────
  static const LinguaTokens light = LinguaTokens(
    surfaceBase: Color(0xFFFAFAFA),
    surfaceRaised: Color(0xFFFFFFFF),
    surfaceSunken: Color(0xFFF0F0F0),
    surfaceGlass: Color(0xCCFFFFFF),
    outline: Color(0xFFE0E0E0),
    outlineSubtle: Color(0xFFEDEDED),
    accent: Color(0xFF6C72E8),
    accentSoft: Color(0xFFECEEFC),
    accentStrong: Color(0xFF5256CC),
    onAccent: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF242424),
    textSecondary: Color(0xFF616161),
    textTertiary: Color(0xFF919191),
    success: Color(0xFF107C41),
    danger: Color(0xFFC50F1F),
    shadowSm: [
      BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2)),
    ],
    shadowMd: [
      BoxShadow(color: Color(0x1F000000), blurRadius: 20, offset: Offset(0, 6)),
    ],
    shadowLg: [
      BoxShadow(color: Color(0x29000000), blurRadius: 40, offset: Offset(0, 16)),
    ],
    heroGradient: LinearGradient(
      colors: [Color(0xFFEEF0FB), Color(0xFFF3EEFA)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    isDark: false,
  );

  // ── Thème SOMBRE (Copilot — neutres sombres + accent indigo clair) ─────
  static const LinguaTokens dark = LinguaTokens(
    surfaceBase: Color(0xFF1B1B1F),
    surfaceRaised: Color(0xFF26262B),
    surfaceSunken: Color(0xFF161619),
    surfaceGlass: Color(0x14FFFFFF),
    outline: Color(0xFF3A3A40),
    outlineSubtle: Color(0xFF2C2C31),
    accent: Color(0xFF9AA0FF),
    accentSoft: Color(0xFF2E3052),
    accentStrong: Color(0xFFB4B8FF),
    onAccent: Color(0xFF1B1B2E),
    textPrimary: Color(0xFFF5F5F5),
    textSecondary: Color(0xFFB8B8BE),
    textTertiary: Color(0xFF87878D),
    success: Color(0xFF5DC98B),
    danger: Color(0xFFE57373),
    shadowSm: [
      BoxShadow(color: Color(0x40000000), blurRadius: 10, offset: Offset(0, 3)),
    ],
    shadowMd: [
      BoxShadow(color: Color(0x59000000), blurRadius: 24, offset: Offset(0, 8)),
    ],
    shadowLg: [
      BoxShadow(color: Color(0x73000000), blurRadius: 48, offset: Offset(0, 18)),
    ],
    heroGradient: LinearGradient(
      colors: [Color(0xFF26273D), Color(0xFF2C2540)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    isDark: true,
  );

  @override
  LinguaTokens copyWith({
    Color? surfaceBase,
    Color? surfaceRaised,
    Color? surfaceSunken,
    Color? surfaceGlass,
    Color? outline,
    Color? outlineSubtle,
    Color? accent,
    Color? accentSoft,
    Color? accentStrong,
    Color? onAccent,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? success,
    Color? danger,
    List<BoxShadow>? shadowSm,
    List<BoxShadow>? shadowMd,
    List<BoxShadow>? shadowLg,
    Gradient? heroGradient,
    bool? isDark,
  }) {
    return LinguaTokens(
      surfaceBase: surfaceBase ?? this.surfaceBase,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      surfaceSunken: surfaceSunken ?? this.surfaceSunken,
      surfaceGlass: surfaceGlass ?? this.surfaceGlass,
      outline: outline ?? this.outline,
      outlineSubtle: outlineSubtle ?? this.outlineSubtle,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      accentStrong: accentStrong ?? this.accentStrong,
      onAccent: onAccent ?? this.onAccent,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      success: success ?? this.success,
      danger: danger ?? this.danger,
      shadowSm: shadowSm ?? this.shadowSm,
      shadowMd: shadowMd ?? this.shadowMd,
      shadowLg: shadowLg ?? this.shadowLg,
      heroGradient: heroGradient ?? this.heroGradient,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  LinguaTokens lerp(ThemeExtension<LinguaTokens>? other, double t) {
    if (other is! LinguaTokens) return this;
    return LinguaTokens(
      surfaceBase: Color.lerp(surfaceBase, other.surfaceBase, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      surfaceSunken: Color.lerp(surfaceSunken, other.surfaceSunken, t)!,
      surfaceGlass: Color.lerp(surfaceGlass, other.surfaceGlass, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      outlineSubtle: Color.lerp(outlineSubtle, other.outlineSubtle, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      accentStrong: Color.lerp(accentStrong, other.accentStrong, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      success: Color.lerp(success, other.success, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      shadowSm: t < 0.5 ? shadowSm : other.shadowSm,
      shadowMd: t < 0.5 ? shadowMd : other.shadowMd,
      shadowLg: t < 0.5 ? shadowLg : other.shadowLg,
      heroGradient: Gradient.lerp(heroGradient, other.heroGradient, t)!,
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}

/// Accès rapide aux tokens : `context.tokens`.
extension LinguaTokensX on BuildContext {
  LinguaTokens get tokens =>
      Theme.of(this).extension<LinguaTokens>() ?? LinguaTokens.dark;
}
