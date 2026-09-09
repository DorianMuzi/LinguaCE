import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'lingua_scale.dart';
import 'lingua_tokens.dart';

/// Fabrique les [ThemeData] clair et sombre à partir des [LinguaTokens].
///
/// Trois voix typographiques, portées depuis `tokens/typography.css` :
///  • Oswald         → titres monumentaux condensés, en capitales
///  • Manrope        → corps de texte, boutons, champs
///  • JetBrains Mono → libellés en capitales, chiffres, chrome, logotype
///
/// La règle qui compte : un titre d'écran est en Oswald CAPITALES, un libellé
/// de métadonnée en JetBrains Mono capitales très espacé, et tout le reste en
/// Manrope. Ne pas mélanger les rôles — c'est ce qui donne au système sa
/// signature.
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
      secondary: t.gold,
      onSecondary: LinguaPalette.navy900,
      surface: t.surfaceRaised,
      onSurface: t.textPrimary,
      surfaceContainerHighest: t.surfaceSunken,
      error: t.danger,
      onError: Colors.white,
      outline: t.outline,
      outlineVariant: t.outlineSubtle,
    );

    return base.copyWith(
      scaffoldBackgroundColor: t.surfaceBase,
      colorScheme: colorScheme,
      extensions: [t],
      textTheme: _textTheme(t),
      splashFactory: InkSparkle.splashFactory,

      cardTheme: CardThemeData(
        color: t.surfaceRaised,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: LinguaRadius.rCard,
          side: BorderSide(color: t.outlineSubtle),
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: t.surfaceBase,
        foregroundColor: t.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: LinguaFrame.topBarHeight,
        titleTextStyle: GoogleFonts.oswald(
          color: t.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          height: 1.05,
        ),
        iconTheme: IconThemeData(color: t.textPrimary, size: 22),
      ),

      dividerTheme: DividerThemeData(
        color: t.outlineSubtle,
        thickness: 1,
        space: 1,
      ),

      // ── Saisie ─────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: t.surfaceInput,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: LinguaSpacing.lg,
          vertical: LinguaSpacing.md + 2,
        ),
        hintStyle: GoogleFonts.manrope(color: t.textFaint, fontSize: 15),
        labelStyle: GoogleFonts.manrope(color: t.textTertiary, fontSize: 15),
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
          borderSide: BorderSide(color: t.accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: LinguaRadius.rMd,
          borderSide: BorderSide(color: t.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: LinguaRadius.rMd,
          borderSide: BorderSide(color: t.danger, width: 2),
        ),
      ),

      // ── Boutons ────────────────────────────────────────────────────────
      // Le bouton primaire est un aplat bleu à coins de 14 px, en Manrope
      // demi-gras — jamais en capitales : les capitales sont réservées aux
      // titres Oswald et aux libellés mono.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: t.accentFill,
          foregroundColor: t.onAccent,
          disabledBackgroundColor: t.surfaceRaised,
          disabledForegroundColor: t.textFaint,
          elevation: 0,
          minimumSize: const Size.fromHeight(LinguaFrame.minTarget + 8),
          padding: const EdgeInsets.symmetric(horizontal: LinguaSpacing.xxl),
          shape: const RoundedRectangleBorder(borderRadius: LinguaRadius.rMd),
          textStyle: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: t.textPrimary,
          minimumSize: const Size.fromHeight(LinguaFrame.minTarget + 8),
          padding: const EdgeInsets.symmetric(horizontal: LinguaSpacing.xxl),
          side: BorderSide(color: t.outline),
          shape: const RoundedRectangleBorder(borderRadius: LinguaRadius.rMd),
          textStyle: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: t.textAccent,
          minimumSize: const Size(0, LinguaFrame.minTarget),
          padding: const EdgeInsets.symmetric(horizontal: LinguaSpacing.md),
          shape: const RoundedRectangleBorder(borderRadius: LinguaRadius.rSm),
          textStyle: GoogleFonts.manrope(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: t.accentFill,
          foregroundColor: t.onAccent,
          minimumSize: const Size.fromHeight(LinguaFrame.minTarget + 8),
          shape: const RoundedRectangleBorder(borderRadius: LinguaRadius.rMd),
          textStyle: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: t.textSecondary,
          minimumSize: const Size.square(LinguaFrame.minTarget),
          shape: const RoundedRectangleBorder(borderRadius: LinguaRadius.rSm),
        ),
      ),

      // ── Puces et onglets ───────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: t.surfaceRaised,
        selectedColor: t.accentTintStrong,
        disabledColor: t.surfaceSunken,
        side: BorderSide(color: t.outlineSubtle),
        shape: const RoundedRectangleBorder(borderRadius: LinguaRadius.rPill),
        padding: const EdgeInsets.symmetric(
          horizontal: LinguaSpacing.md,
          vertical: LinguaSpacing.sm,
        ),
        labelStyle: GoogleFonts.jetBrainsMono(
          color: t.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: GoogleFonts.jetBrainsMono(
          color: t.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: t.textPrimary,
        unselectedLabelColor: t.textTertiary,
        indicatorColor: t.accent,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        labelStyle: GoogleFonts.jetBrainsMono(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
        unselectedLabelStyle: GoogleFonts.jetBrainsMono(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.2,
        ),
      ),

      // ── Bascules ───────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? t.onAccent : t.textTertiary,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? t.accent : t.switchTrack,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? Colors.transparent
              : t.outline,
        ),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? t.accent
              : Colors.transparent,
        ),
        checkColor: WidgetStatePropertyAll(t.onAccent),
        side: BorderSide(color: t.outline, width: 1.5),
        shape: const RoundedRectangleBorder(borderRadius: LinguaRadius.rXs),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? t.accent : t.outline,
        ),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: t.accent,
        inactiveTrackColor: t.surfaceSunken,
        thumbColor: t.accent,
        overlayColor: t.accentTint,
        trackHeight: 6,
      ),

      // ── Progression ────────────────────────────────────────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: t.accent,
        linearTrackColor: t.surfaceSunken,
        circularTrackColor: t.surfaceSunken,
        linearMinHeight: 8,
      ),

      // ── Superpositions ─────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: t.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: t.surfaceRaised,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(LinguaRadius.xl),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: t.outline,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: t.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: LinguaRadius.rLg,
          side: BorderSide(color: t.outlineSubtle),
        ),
        titleTextStyle: GoogleFonts.oswald(
          color: t.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          height: 1.15,
        ),
        contentTextStyle: GoogleFonts.manrope(
          color: t.textSecondary,
          fontSize: 15,
          height: 1.55,
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: t.surfaceGlassStrong,
        contentTextStyle: GoogleFonts.manrope(
          color: t.textPrimary,
          fontSize: 14,
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: LinguaRadius.rMd,
          side: BorderSide(color: t.glassBorder),
        ),
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: t.surfaceSunken,
          borderRadius: LinguaRadius.rSm,
          border: Border.all(color: t.outline),
        ),
        textStyle: GoogleFonts.manrope(color: t.textPrimary, fontSize: 12),
      ),

      listTileTheme: ListTileThemeData(
        iconColor: t.textTertiary,
        textColor: t.textPrimary,
        minVerticalPadding: LinguaSpacing.md,
        shape: const RoundedRectangleBorder(borderRadius: LinguaRadius.rMd),
        titleTextStyle: GoogleFonts.manrope(
          color: t.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        subtitleTextStyle: GoogleFonts.manrope(
          color: t.textTertiary,
          fontSize: 13,
          height: 1.45,
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: t.surfaceGlass,
        indicatorColor: t.accentTintStrong,
        height: LinguaFrame.tabBarHeight,
        elevation: 0,
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.jetBrainsMono(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  /// L'échelle typographique de `tokens/typography.css`.
  ///
  /// `displayLarge/Medium/Small` et `headlineLarge` sont en Oswald : ce sont
  /// les seuls styles en capitales du système. `titleSmall` est le libellé
  /// mono très espacé. Le reste est en Manrope.
  static TextTheme _textTheme(LinguaTokens t) {
    final display = GoogleFonts.oswald(
      color: t.textPrimary,
      fontWeight: FontWeight.w700,
      height: 1.05,
      letterSpacing: 0.4,
    );

    return TextTheme(
      // Oswald — titres
      displayLarge: display.copyWith(fontSize: 44),
      displayMedium: display.copyWith(fontSize: 34),
      displaySmall: display.copyWith(fontSize: 26),
      headlineLarge: display.copyWith(fontSize: 20, height: 1.15),

      // Manrope — titres de contenu et corps
      headlineMedium: GoogleFonts.manrope(
        color: t.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.25,
      ),
      headlineSmall: GoogleFonts.manrope(
        color: t.textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
      titleLarge: GoogleFonts.manrope(
        color: t.textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      titleMedium: GoogleFonts.manrope(
        color: t.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),

      // JetBrains Mono — le libellé de métadonnée, en capitales
      titleSmall: GoogleFonts.jetBrainsMono(
        color: t.textTertiary,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.9,
      ),

      bodyLarge: GoogleFonts.manrope(
        color: t.textSecondary,
        fontSize: 17,
        height: 1.55,
      ),
      bodyMedium: GoogleFonts.manrope(
        color: t.textSecondary,
        fontSize: 15,
        height: 1.55,
      ),
      bodySmall: GoogleFonts.manrope(
        color: t.textTertiary,
        fontSize: 13.5,
        height: 1.5,
      ),

      labelLarge: GoogleFonts.manrope(
        color: t.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: GoogleFonts.jetBrainsMono(
        color: t.textTertiary,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.2,
      ),
      labelSmall: GoogleFonts.jetBrainsMono(
        color: t.textFaint,
        fontSize: 10.5,
        fontWeight: FontWeight.w500,
        letterSpacing: 1,
      ),
    );
  }
}

/// Les styles qui ne rentrent pas dans un [TextTheme] Material.
///
/// Le logotype et les compteurs chiffrés ont des réglages propres (chiffres
/// tabulaires, notamment) qu'aucun rôle Material ne décrit.
class LinguaType {
  LinguaType._();

  /// Le logotype LinguaCE.
  static TextStyle wordmark(Color color, {double size = 18}) =>
      GoogleFonts.jetBrainsMono(
        color: color,
        fontSize: size,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.36,
      );

  /// Un grand compteur : XP, série, niveau. Chiffres tabulaires pour que la
  /// valeur ne saute pas quand elle change.
  static TextStyle number(Color color, {double size = 28}) =>
      GoogleFonts.jetBrainsMono(
        color: color,
        fontSize: size,
        fontWeight: FontWeight.w700,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  /// Un mot tchétchène affiché en vedette — écriture latine en avant.
  static TextStyle chechen(Color color, {double size = 22}) =>
      GoogleFonts.oswald(
        color: color,
        fontSize: size,
        fontWeight: FontWeight.w700,
        height: 1.2,
      );

  /// La forme cyrillique, en appui sous la forme latine.
  static TextStyle cyrillic(Color color, {double size = 11}) =>
      GoogleFonts.jetBrainsMono(
        color: color,
        fontSize: size,
        fontWeight: FontWeight.w400,
      );
}
