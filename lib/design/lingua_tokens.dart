import 'package:flutter/material.dart';

/// Tokens de design sémantiques de LinguaCE.
///
/// Portés depuis le design system HTML (`tokens/colors.css`,
/// `tokens/theme-light.css`) — les valeurs sont identiques, un pour un.
///
/// Deux thèmes :
///  • SOMBRE — navy dominant, l'accent bleu pour l'interaction, l'or pour la
///    progression. C'est le thème de référence : le système est conçu sombre
///    d'abord.
///  • CLAIR — le sol devient papier chaud, la rampe navy s'inverse en texte.
///    Les rampes de marque (ember, or, grenat) ne changent PAS, donc les
///    illustrations, les couleurs de ligue et le registre Istang restent
///    identiques d'un thème à l'autre.
///
/// Accès dans un widget : `context.tokens`.
@immutable
class LinguaTokens extends ThemeExtension<LinguaTokens> {
  // ── Surfaces ───────────────────────────────────────────────────────────
  /// Fond de l'écran (scaffold).
  final Color surfaceBase;

  /// Surface surélevée : cartes, panneaux.
  final Color surfaceRaised;

  /// Surface en creux : champs de saisie, puits.
  final Color surfaceSunken;

  /// Surface de mise en avant, teintée de bleu.
  final Color surfaceFeature;

  /// Remplissage des champs de saisie.
  final Color surfaceInput;

  /// Surface translucide pour les matériaux « liquid glass ».
  final Color surfaceGlass;

  /// Remplissage de verre appuyé (barre flottante, superpositions).
  final Color surfaceGlassStrong;

  /// Bord clair interne du verre — la ligne brillante en haut.
  final Color glassEdge;

  /// Contour du verre.
  final Color glassBorder;

  // ── Contours ───────────────────────────────────────────────────────────
  final Color outline;
  final Color outlineSubtle;
  final Color outlineStrong;

  // ── Accent : le bleu d'interaction ─────────────────────────────────────
  final Color accent;
  final Color accentSoft;
  final Color accentStrong;

  /// Aplat bleu des boutons primaires.
  final Color accentFill;

  /// Teinte douce : navigation active, puces.
  final Color accentTint;
  final Color accentTintStrong;
  final Color onAccent;

  /// Bleu du texte et des icônes accentués.
  final Color textAccent;

  // ── Texte ──────────────────────────────────────────────────────────────
  final Color textPrimary;
  final Color textSecondary;

  /// Libellés atténués — `--text-muted`.
  final Color textTertiary;

  /// Le plus discret encore lisible — `--text-faint`, jamais sous 4,5:1.
  final Color textFaint;

  // ── États ──────────────────────────────────────────────────────────────
  final Color success;
  final Color danger;
  final Color dangerHover;

  // ── Registres de marque (invariants d'un thème à l'autre) ──────────────
  /// La flamme : séries, énergie, jalon actif.
  final Color ember;

  /// L'or : XP, étoiles, récompenses.
  final Color gold;

  /// Grenat : le registre ornemental Istang.
  final Color garnet;

  /// Métal : chaînes, quincaillerie atténuée.
  final Color steel;

  /// Piste du Switch à l'arrêt.
  final Color switchTrack;

  /// Grenat du cadre Istang.
  final Color istang;

  /// L'or serti du registre Istang.
  final Color istangJewel;

  // ── Profondeur ─────────────────────────────────────────────────────────
  final List<BoxShadow> shadowSm;
  final List<BoxShadow> shadowMd;
  final List<BoxShadow> shadowLg;

  /// Ombre de la barre flottante.
  final List<BoxShadow> shadowFloat;

  /// Halo bleu : bouton primaire au repos, carte active.
  final List<BoxShadow> glowAccent;

  /// Halo de flamme : série en cours.
  final List<BoxShadow> glowEmber;

  /// Dégradé « héros » pour les surfaces de mise en avant.
  final Gradient heroGradient;

  final bool isDark;

  const LinguaTokens({
    required this.surfaceBase,
    required this.surfaceRaised,
    required this.surfaceSunken,
    required this.surfaceFeature,
    required this.surfaceInput,
    required this.surfaceGlass,
    required this.surfaceGlassStrong,
    required this.glassEdge,
    required this.glassBorder,
    required this.outline,
    required this.outlineSubtle,
    required this.outlineStrong,
    required this.accent,
    required this.accentSoft,
    required this.accentStrong,
    required this.accentFill,
    required this.accentTint,
    required this.accentTintStrong,
    required this.onAccent,
    required this.textAccent,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textFaint,
    required this.success,
    required this.danger,
    required this.dangerHover,
    required this.ember,
    required this.gold,
    required this.garnet,
    required this.steel,
    required this.switchTrack,
    required this.istang,
    required this.istangJewel,
    required this.shadowSm,
    required this.shadowMd,
    required this.shadowLg,
    required this.shadowFloat,
    required this.glowAccent,
    required this.glowEmber,
    required this.heroGradient,
    required this.isDark,
  });

  // ── Thème SOMBRE — le thème de référence ───────────────────────────────
  static const LinguaTokens dark = LinguaTokens(
    surfaceBase: LinguaPalette.navy800,
    surfaceRaised: LinguaPalette.navy600,
    surfaceSunken: LinguaPalette.navy900,
    surfaceFeature: LinguaPalette.blueTint,
    surfaceInput: LinguaPalette.navy850,
    surfaceGlass: Color(0x8C072742),
    surfaceGlassStrong: Color(0xB80A3052),
    glassEdge: Color(0x29FFFFFF),
    glassBorder: Color(0x249BD0F5),
    outline: LinguaPalette.navy550,
    outlineSubtle: Color(0x0FFFFFFF),
    outlineStrong: Color(0x1FFFFFFF),
    accent: LinguaPalette.blue500,
    accentSoft: LinguaPalette.blue200,
    accentStrong: LinguaPalette.blue600,
    accentFill: LinguaPalette.blue500,
    accentTint: Color(0x2E0078D4),
    accentTintStrong: Color(0x4D0078D4),
    onAccent: Color(0xFFFFFFFF),
    textAccent: LinguaPalette.blue300,
    textPrimary: Color(0xFFEAF2F8),
    textSecondary: Color(0xFFC4D5E3),
    textTertiary: Color(0xFF92ABBE),
    textFaint: Color(0xFF7E99B0),
    success: LinguaPalette.green400,
    danger: LinguaPalette.garnet400,
    dangerHover: Color(0xFFC94334),
    ember: LinguaPalette.ember500,
    gold: LinguaPalette.gold500,
    garnet: LinguaPalette.garnet500,
    steel: LinguaPalette.steel500,
    switchTrack: LinguaPalette.navy600,
    istang: LinguaPalette.garnet500,
    istangJewel: LinguaPalette.gold500,
    shadowSm: [
      BoxShadow(color: Color(0x59000000), blurRadius: 3, offset: Offset(0, 1)),
    ],
    shadowMd: [
      BoxShadow(color: Color(0x66000000), blurRadius: 20, offset: Offset(0, 6)),
    ],
    shadowLg: [
      BoxShadow(color: Color(0x80000000), blurRadius: 38, offset: Offset(0, 14)),
    ],
    shadowFloat: [
      BoxShadow(color: Color(0x8C000000), blurRadius: 44, offset: Offset(0, 16)),
    ],
    glowAccent: [
      BoxShadow(color: Color(0x470078D4), blurRadius: 30, offset: Offset(0, 10)),
    ],
    glowEmber: [
      BoxShadow(color: Color(0x73FF6B35), blurRadius: 22),
    ],
    heroGradient: LinearGradient(
      colors: [LinguaPalette.blueTint2, LinguaPalette.navy700],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    isDark: true,
  );

  // ── Thème CLAIR — sol papier, la rampe navy passe en texte ─────────────
  static const LinguaTokens light = LinguaTokens(
    surfaceBase: Color(0xFFF7F9FB),
    surfaceRaised: Color(0xFFEFF3F7),
    surfaceSunken: Color(0xFFE4EBF2),
    surfaceFeature: Color(0xFFE8F2FB),
    surfaceInput: Color(0xFFFFFFFF),
    surfaceGlass: Color(0x9EFFFFFF),
    surfaceGlassStrong: Color(0xD1FFFFFF),
    glassEdge: Color(0xD9FFFFFF),
    glassBorder: Color(0x1A001529),
    outline: Color(0xFFD2DEE9),
    outlineSubtle: Color(0x17001529),
    outlineStrong: Color(0x29001529),
    accent: LinguaPalette.blue500,
    accentSoft: Color(0xFFD9EAF9),
    accentStrong: LinguaPalette.blue700,
    accentFill: LinguaPalette.blue500,
    accentTint: Color(0x1F0078D4),
    accentTintStrong: Color(0x380078D4),
    onAccent: Color(0xFFFFFFFF),
    textAccent: LinguaPalette.blue600,
    textPrimary: Color(0xFF001529),
    textSecondary: Color(0xFF23415A),
    textTertiary: Color(0xFF4C6A85),
    textFaint: Color(0xFF516B84),
    success: Color(0xFF1E8F52),
    danger: LinguaPalette.garnet500,
    dangerHover: Color(0xFF6E1A12),
    // Les rampes de marque ne bougent pas : seuls le texte et les icônes
    // reçoivent une version assombrie, calculée pour rester lisible.
    ember: LinguaPalette.ember500,
    gold: LinguaPalette.gold500,
    garnet: LinguaPalette.garnet500,
    steel: LinguaPalette.steel500,
    switchTrack: Color(0xFFD2DEE9),
    istang: LinguaPalette.garnet500,
    istangJewel: Color(0xFFB87A1C),
    shadowSm: [
      BoxShadow(color: Color(0x0F001529), blurRadius: 2, offset: Offset(0, 1)),
    ],
    shadowMd: [
      BoxShadow(color: Color(0x1A001529), blurRadius: 18, offset: Offset(0, 6)),
    ],
    shadowLg: [
      BoxShadow(color: Color(0x24001529), blurRadius: 34, offset: Offset(0, 14)),
    ],
    shadowFloat: [
      BoxShadow(color: Color(0x29001529), blurRadius: 40, offset: Offset(0, 16)),
    ],
    glowAccent: [
      BoxShadow(color: Color(0x2E0078D4), blurRadius: 26, offset: Offset(0, 10)),
    ],
    glowEmber: [
      BoxShadow(color: Color(0x52FF6B35), blurRadius: 20),
    ],
    heroGradient: LinearGradient(
      colors: [Color(0xFFE8F2FB), Color(0xFFF7F9FB)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    isDark: false,
  );

  /// L'or lisible en texte et en icône sur le thème courant.
  ///
  /// L'or de marque (`gold`) est réservé aux aplats et aux ornements : posé en
  /// texte sur du papier il tombe sous 3:1. Utiliser CE getter dès que l'or
  /// porte un caractère.
  Color get goldInk => isDark ? gold : const Color(0xFFB87A1C);

  /// Même règle pour la flamme.
  Color get emberInk => isDark ? ember : const Color(0xFFD9491A);

  @override
  LinguaTokens copyWith({
    Color? surfaceBase,
    Color? surfaceRaised,
    Color? surfaceSunken,
    Color? surfaceFeature,
    Color? surfaceInput,
    Color? surfaceGlass,
    Color? surfaceGlassStrong,
    Color? glassEdge,
    Color? glassBorder,
    Color? outline,
    Color? outlineSubtle,
    Color? outlineStrong,
    Color? accent,
    Color? accentSoft,
    Color? accentStrong,
    Color? accentFill,
    Color? accentTint,
    Color? accentTintStrong,
    Color? onAccent,
    Color? textAccent,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textFaint,
    Color? success,
    Color? danger,
    Color? dangerHover,
    Color? ember,
    Color? gold,
    Color? garnet,
    Color? steel,
    Color? switchTrack,
    Color? istang,
    Color? istangJewel,
    List<BoxShadow>? shadowSm,
    List<BoxShadow>? shadowMd,
    List<BoxShadow>? shadowLg,
    List<BoxShadow>? shadowFloat,
    List<BoxShadow>? glowAccent,
    List<BoxShadow>? glowEmber,
    Gradient? heroGradient,
    bool? isDark,
  }) {
    return LinguaTokens(
      surfaceBase: surfaceBase ?? this.surfaceBase,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      surfaceSunken: surfaceSunken ?? this.surfaceSunken,
      surfaceFeature: surfaceFeature ?? this.surfaceFeature,
      surfaceInput: surfaceInput ?? this.surfaceInput,
      surfaceGlass: surfaceGlass ?? this.surfaceGlass,
      surfaceGlassStrong: surfaceGlassStrong ?? this.surfaceGlassStrong,
      glassEdge: glassEdge ?? this.glassEdge,
      glassBorder: glassBorder ?? this.glassBorder,
      outline: outline ?? this.outline,
      outlineSubtle: outlineSubtle ?? this.outlineSubtle,
      outlineStrong: outlineStrong ?? this.outlineStrong,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      accentStrong: accentStrong ?? this.accentStrong,
      accentFill: accentFill ?? this.accentFill,
      accentTint: accentTint ?? this.accentTint,
      accentTintStrong: accentTintStrong ?? this.accentTintStrong,
      onAccent: onAccent ?? this.onAccent,
      textAccent: textAccent ?? this.textAccent,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textFaint: textFaint ?? this.textFaint,
      success: success ?? this.success,
      danger: danger ?? this.danger,
      dangerHover: dangerHover ?? this.dangerHover,
      ember: ember ?? this.ember,
      gold: gold ?? this.gold,
      garnet: garnet ?? this.garnet,
      steel: steel ?? this.steel,
      switchTrack: switchTrack ?? this.switchTrack,
      istang: istang ?? this.istang,
      istangJewel: istangJewel ?? this.istangJewel,
      shadowSm: shadowSm ?? this.shadowSm,
      shadowMd: shadowMd ?? this.shadowMd,
      shadowLg: shadowLg ?? this.shadowLg,
      shadowFloat: shadowFloat ?? this.shadowFloat,
      glowAccent: glowAccent ?? this.glowAccent,
      glowEmber: glowEmber ?? this.glowEmber,
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
      surfaceFeature: Color.lerp(surfaceFeature, other.surfaceFeature, t)!,
      surfaceInput: Color.lerp(surfaceInput, other.surfaceInput, t)!,
      surfaceGlass: Color.lerp(surfaceGlass, other.surfaceGlass, t)!,
      surfaceGlassStrong:
          Color.lerp(surfaceGlassStrong, other.surfaceGlassStrong, t)!,
      glassEdge: Color.lerp(glassEdge, other.glassEdge, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      outlineSubtle: Color.lerp(outlineSubtle, other.outlineSubtle, t)!,
      outlineStrong: Color.lerp(outlineStrong, other.outlineStrong, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      accentStrong: Color.lerp(accentStrong, other.accentStrong, t)!,
      accentFill: Color.lerp(accentFill, other.accentFill, t)!,
      accentTint: Color.lerp(accentTint, other.accentTint, t)!,
      accentTintStrong:
          Color.lerp(accentTintStrong, other.accentTintStrong, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      textAccent: Color.lerp(textAccent, other.textAccent, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textFaint: Color.lerp(textFaint, other.textFaint, t)!,
      success: Color.lerp(success, other.success, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerHover: Color.lerp(dangerHover, other.dangerHover, t)!,
      ember: Color.lerp(ember, other.ember, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      garnet: Color.lerp(garnet, other.garnet, t)!,
      steel: Color.lerp(steel, other.steel, t)!,
      switchTrack: Color.lerp(switchTrack, other.switchTrack, t)!,
      istang: Color.lerp(istang, other.istang, t)!,
      istangJewel: Color.lerp(istangJewel, other.istangJewel, t)!,
      shadowSm: t < 0.5 ? shadowSm : other.shadowSm,
      shadowMd: t < 0.5 ? shadowMd : other.shadowMd,
      shadowLg: t < 0.5 ? shadowLg : other.shadowLg,
      shadowFloat: t < 0.5 ? shadowFloat : other.shadowFloat,
      glowAccent: t < 0.5 ? glowAccent : other.glowAccent,
      glowEmber: t < 0.5 ? glowEmber : other.glowEmber,
      heroGradient: Gradient.lerp(heroGradient, other.heroGradient, t)!,
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}

/// Les rampes brutes de la marque — `tokens/colors.css`.
///
/// À n'employer que pour construire des tokens sémantiques, ou dans une
/// illustration qui doit garder la même couleur dans les deux thèmes (les
/// couleurs de ligue, le registre Istang). Dans un écran, passer par
/// `context.tokens`.
class LinguaPalette {
  LinguaPalette._();

  // Sol navy
  static const Color navy900 = Color(0xFF00101D);
  static const Color navy850 = Color(0xFF001321);
  static const Color navy800 = Color(0xFF001529);
  static const Color navy700 = Color(0xFF04203A);
  static const Color navy650 = Color(0xFF072742);
  static const Color navy600 = Color(0xFF0A3052);
  static const Color navy550 = Color(0xFF173F5F);
  static const Color navy500 = Color(0xFF21506E);

  // Bleu d'interaction
  static const Color blue200 = Color(0xFF9BD0F5);
  static const Color blue300 = Color(0xFF4FA8E8);
  static const Color blue400 = Color(0xFF2A8FE0);
  static const Color blue500 = Color(0xFF0078D4);
  static const Color blue600 = Color(0xFF0063B1);
  static const Color blue700 = Color(0xFF0A4E85);
  static const Color blueTint = Color(0xFF06283F);
  static const Color blueTint2 = Color(0xFF0B3A5C);

  // Feu et ornement
  static const Color ember500 = Color(0xFFFF6B35);
  static const Color ember400 = Color(0xFFFF8456);
  static const Color gold500 = Color(0xFFE8A33D);
  static const Color gold400 = Color(0xFFF2B85A);
  static const Color garnet500 = Color(0xFF8B2118);
  static const Color garnet400 = Color(0xFFB33327);
  static const Color steel500 = Color(0xFF6F8AA0);
  static const Color green400 = Color(0xFF5FD08A);
}

/// Accès rapide aux tokens : `context.tokens`.
extension LinguaTokensX on BuildContext {
  LinguaTokens get tokens =>
      Theme.of(this).extension<LinguaTokens>() ?? LinguaTokens.dark;
}
