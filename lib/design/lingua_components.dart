import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'lingua_scale.dart';
import 'lingua_theme.dart';
import 'lingua_tokens.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Libellé de section : JetBrains Mono, capitales, très espacé.
//
// C'est la voix « métadonnée » du système — XP TOTAL, NIV. 3, AUJOURD'HUI.
// Jamais pour une phrase : l'espacement de 1,9 rend un texte long illisible.
// ─────────────────────────────────────────────────────────────────────────────
class SectionLabel extends StatelessWidget {
  final String text;

  /// Passe le libellé en or — pour un en-tête de section de contenu.
  final bool accent;

  const SectionLabel(this.text, {super.key, this.accent = false});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.jetBrainsMono(
        color: accent ? t.goldInk : t.textTertiary,
        fontSize: 11,
        letterSpacing: 1.9,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Titre d'écran : Oswald capitales. Le seul style monumental du système.
// ─────────────────────────────────────────────────────────────────────────────
class ScreenTitle extends StatelessWidget {
  final String text;
  final double size;

  const ScreenTitle(this.text, {super.key, this.size = 34});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.oswald(
        color: context.tokens.textPrimary,
        fontSize: size,
        fontWeight: FontWeight.w700,
        height: 1.05,
        letterSpacing: 0.4,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Carte : surface surélevée, coins de 18, filet discret.
// ─────────────────────────────────────────────────────────────────────────────
class CopilotCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool elevated;
  final Color? color;
  final Gradient? gradient;

  /// Filet de gauche coloré — signale une carte de registre (leçon, alerte).
  final Color? edge;

  const CopilotCard({
    super.key,
    required this.child,
    this.padding = LinguaSpacing.cardPad,
    this.onTap,
    this.elevated = true,
    this.color,
    this.gradient,
    this.edge,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final decoration = BoxDecoration(
      color: gradient == null ? (color ?? t.surfaceRaised) : null,
      gradient: gradient,
      borderRadius: LinguaRadius.rCard,
      border: edge != null
          ? Border(left: BorderSide(color: edge!, width: 3))
          : Border.all(color: t.outlineSubtle),
      boxShadow: elevated ? t.shadowSm : null,
    );

    final body = AnimatedContainer(
      duration: LinguaDuration.base,
      curve: LinguaCurves.out,
      padding: padding,
      decoration: decoration,
      child: child,
    );

    if (onTap == null) return body;
    return Material(
      color: Colors.transparent,
      borderRadius: LinguaRadius.rCard,
      child: InkWell(
        borderRadius: LinguaRadius.rCard,
        onTap: onTap,
        child: body,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bouton : plein, tonal, fantôme, et l'or pour une récompense.
//
// Jamais en capitales — celles-ci appartiennent aux titres Oswald et aux
// libellés mono. Hauteur 52 : au-dessus de la cible minimale de 44.
// ─────────────────────────────────────────────────────────────────────────────
enum CopilotButtonVariant { filled, tonal, ghost, reward, danger }

class CopilotButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final CopilotButtonVariant variant;
  final bool loading;
  final bool expand;

  const CopilotButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = CopilotButtonVariant.filled,
    this.loading = false,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final disabled = onPressed == null && !loading;

    // Non `final` : le bloc `disabled` ci-dessous les réassigne.
    late Color bg;
    late Color fg;
    Color? border;
    List<BoxShadow>? glow;

    switch (variant) {
      case CopilotButtonVariant.filled:
        bg = t.accentFill;
        fg = t.onAccent;
        glow = t.glowAccent;
      case CopilotButtonVariant.tonal:
        bg = t.accentTint;
        fg = t.textAccent;
        border = t.accent.withValues(alpha: 0.35);
      case CopilotButtonVariant.ghost:
        bg = Colors.transparent;
        fg = t.textPrimary;
        border = t.outline;
      case CopilotButtonVariant.reward:
        // L'or en aplat porte du texte navy : l'inverse ne passerait pas le
        // contraste sur le thème clair.
        bg = t.gold;
        fg = LinguaPalette.navy900;
      case CopilotButtonVariant.danger:
        bg = Colors.transparent;
        fg = t.danger;
        border = t.danger.withValues(alpha: 0.45);
    }

    if (disabled) {
      bg = variant == CopilotButtonVariant.filled ||
              variant == CopilotButtonVariant.reward
          ? t.surfaceRaised
          : Colors.transparent;
      fg = t.textFaint;
      border = t.outlineSubtle;
      glow = null;
    }

    final content = loading
        ? SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: LinguaSpacing.sm),
              ],
              Text(
                label,
                style: GoogleFonts.manrope(
                  color: fg,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: LinguaRadius.rMd,
        boxShadow: glow,
      ),
      child: Material(
        color: bg,
        borderRadius: LinguaRadius.rMd,
        child: InkWell(
          borderRadius: LinguaRadius.rMd,
          onTap: loading ? null : onPressed,
          child: Container(
            height: 52,
            width: expand ? double.infinity : null,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: LinguaSpacing.xxl),
            decoration: BoxDecoration(
              borderRadius: LinguaRadius.rMd,
              border: border != null ? Border.all(color: border) : null,
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Puce : pastille tintée. Le registre suit ce qu'elle désigne.
// ─────────────────────────────────────────────────────────────────────────────
enum ChipTone { accent, reward, streak, success, neutral }

class AccentChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final ChipTone tone;

  /// Conservé pour compatibilité. Le système n'emploie pas d'emoji : préférer
  /// `icon`.
  final String? emoji;

  const AccentChip({
    super.key,
    required this.label,
    this.icon,
    this.emoji,
    this.tone = ChipTone.accent,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    final (Color ink, Color fill) = switch (tone) {
      ChipTone.accent => (t.textAccent, t.accentTint),
      ChipTone.reward => (t.goldInk, t.gold.withValues(alpha: 0.16)),
      ChipTone.streak => (t.emberInk, t.ember.withValues(alpha: 0.16)),
      ChipTone.success => (t.success, t.success.withValues(alpha: 0.16)),
      ChipTone.neutral => (t.textTertiary, t.surfaceRaised),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LinguaSpacing.md,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: LinguaRadius.rPill,
        border: Border.all(color: ink.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (emoji != null) ...[
            Text(emoji!, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 6),
          ] else if (icon != null) ...[
            Icon(icon, size: 13, color: ink),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              color: ink,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Liquid glass : le matériau de la barre flottante et des superpositions.
//
// Toujours doublé d'un aplat de repli : `BackdropFilter` est coûteux et le
// flou peut être désactivé par le système.
// ─────────────────────────────────────────────────────────────────────────────
class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double blur;
  final BorderRadius radius;

  /// Remplissage appuyé — pour une barre qui passe sur du contenu dense.
  final bool strong;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding = LinguaSpacing.cardPad,
    this.blur = LinguaGlass.blur,
    this.radius = LinguaRadius.rLg,
    this.strong = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: radius, boxShadow: t.shadowFloat),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: strong ? t.surfaceGlassStrong : t.surfaceGlass,
              borderRadius: radius,
              border: Border.all(color: t.glassBorder),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tuile de statistique : le chiffre en mono tabulaire, le libellé en dessous.
// ─────────────────────────────────────────────────────────────────────────────
class StatTile extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;
  final ChipTone tone;

  /// Conservé pour compatibilité — préférer `icon`.
  final String? emoji;

  const StatTile({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.emoji,
    this.tone = ChipTone.accent,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final ink = switch (tone) {
      ChipTone.accent => t.textAccent,
      ChipTone.reward => t.goldInk,
      ChipTone.streak => t.emberInk,
      ChipTone.success => t.success,
      ChipTone.neutral => t.textPrimary,
    };

    return CopilotCard(
      padding: const EdgeInsets.symmetric(
        horizontal: LinguaSpacing.lg,
        vertical: LinguaSpacing.lg - 2,
      ),
      child: Row(
        children: [
          if (emoji != null) ...[
            Text(emoji!, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: LinguaSpacing.md),
          ] else if (icon != null) ...[
            Icon(icon, size: 22, color: ink),
            const SizedBox(width: LinguaSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(value, style: LinguaType.number(ink, size: 20)),
                const SizedBox(height: 2),
                Text(
                  label.toUpperCase(),
                  style: GoogleFonts.jetBrainsMono(
                    color: t.textTertiary,
                    fontSize: 10,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Un mot tchétchène : latin sur la ligne principale, cyrillique en appui.
//
// L'app met en avant l'écriture latine. `lang` suit le cyrillique et non
// l'emplacement — c'est lui qui commande la prononciation d'un lecteur
// d'écran, et l'inverser fait lire la translittération avec la phonologie
// tchétchène.
// ─────────────────────────────────────────────────────────────────────────────
class ChechenWord extends StatelessWidget {
  /// La forme latine — calculée depuis le cyrillique, jamais stockée.
  final String latin;

  /// La forme cyrillique.
  final String cyrillic;

  /// La traduction, sous la paire.
  final String? gloss;

  final double size;
  final CrossAxisAlignment align;

  const ChechenWord({
    super.key,
    required this.latin,
    required this.cyrillic,
    this.gloss,
    this.size = 22,
    this.align = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: align,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(latin, style: LinguaType.chechen(t.textPrimary, size: size)),
        const SizedBox(height: 2),
        Semantics(
          // `label:` plutôt que `attributedLabel:` — strictement équivalent
          // ici (aucun StringAttribute n'était attaché) et sans dépendance
          // à une version récente de dart:ui.
          label: cyrillic,
          child: Text(
            cyrillic,
            style: LinguaType.cyrillic(t.goldInk, size: size * 0.5),
          ),
        ),
        if (gloss != null) ...[
          const SizedBox(height: 5),
          Text(
            gloss!,
            style: GoogleFonts.manrope(
              color: t.textSecondary,
              fontSize: 13.5,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// БӀов — la tour de guet vainakh. Jalon de progression.
//
// Les étages se remplissent de flamme jusqu'à `tier` ; le toit s'allume quand
// la tour est complète. Porté depuis `components/brand/Tower.jsx`.
// ─────────────────────────────────────────────────────────────────────────────
class Tower extends StatelessWidget {
  final int tier;
  final int total;
  final double height;

  const Tower({
    super.key,
    this.tier = 2,
    this.total = 5,
    this.height = 260,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      label: 'Tour de progression : $tier étages sur $total',
      child: CustomPaint(
        size: Size(height * 0.46, height),
        painter: _TowerPainter(
          tier: tier.clamp(0, total),
          total: total,
          on: t.ember,
          onSoft: t.ember.withValues(alpha: 0.22),
          onLine: LinguaPalette.ember400,
          off: t.outline,
        ),
      ),
    );
  }
}

class _TowerPainter extends CustomPainter {
  final int tier;
  final int total;
  final Color on;
  final Color onSoft;
  final Color onLine;
  final Color off;

  _TowerPainter({
    required this.tier,
    required this.total,
    required this.on,
    required this.onSoft,
    required this.onLine,
    required this.off,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Le dessin d'origine tient dans un carré de 100 : on met à l'échelle.
    final s = size.height / 100;
    canvas.save();
    canvas.translate((size.width - 100 * s) / 2, 0);
    canvas.scale(s);
    _draw(canvas);
    canvas.restore();
  }

  void _draw(Canvas canvas) {
    const fw0 = 58.0, taper = 5.0, base = 92.0, fh = 30.0, gap = 6.0;

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..style = PaintingStyle.fill;

    for (var i = 0; i < total; i++) {
      final w = fw0 - i * taper;
      final x = (100 - w) / 2;
      final y = base - (i + 1) * (fh + gap);
      final lit = i < tier;
      final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, w, fh),
        const Radius.circular(2),
      );
      if (lit) canvas.drawRRect(r, fill..color = onSoft);
      canvas.drawRRect(r, stroke..color = lit ? on : off);

      if (lit) {
        canvas.drawLine(
          Offset(50, y + 6),
          Offset(50, y + fh - 6),
          Paint()
            ..color = onLine.withValues(alpha: 0.7)
            ..strokeWidth = 1.5,
        );
      }
    }

    // Le toit crénelé : allumé seulement quand la tour est complète.
    final topW = fw0 - total * taper;
    final tx = (100 - topW) / 2;
    final ty = base - total * (fh + gap) - 2;
    final roofOn = tier >= total;

    final roof = Path()
      ..moveTo(tx, ty)
      ..lineTo(50, ty - 14)
      ..lineTo(tx + topW, ty)
      ..close();
    if (roofOn) canvas.drawPath(roof, fill..color = onSoft);
    canvas.drawPath(roof, stroke..color = roofOn ? on : off);

    canvas.drawRect(
      Rect.fromLTWH(tx - 2, ty - 2, topW + 4, 4),
      fill..color = roofOn ? on : off,
    );
  }

  @override
  bool shouldRepaint(_TowerPainter old) =>
      old.tier != tier || old.total != total || old.on != on;
}

// ─────────────────────────────────────────────────────────────────────────────
// Écusson de ligue : anneau or, glyphe animal au centre.
//
// Les cinq ligues gardent leur couleur dans les deux thèmes.
// ─────────────────────────────────────────────────────────────────────────────
enum League { wolf, eagle, mouflon, horse, falcon }

class LeagueBadge extends StatelessWidget {
  final League league;
  final double size;
  final bool locked;

  const LeagueBadge({
    super.key,
    required this.league,
    this.size = 64,
    this.locked = false,
  });

  static const _colors = <League, Color>{
    League.wolf: LinguaPalette.steel500,
    League.eagle: LinguaPalette.gold500,
    League.mouflon: LinguaPalette.garnet400,
    League.horse: LinguaPalette.ember500,
    League.falcon: LinguaPalette.blue400,
  };

  static const _labels = <League, String>{
    League.wolf: 'Loup',
    League.eagle: 'Aigle',
    League.mouflon: 'Mouflon',
    League.horse: 'Cheval',
    League.falcon: 'Faucon',
  };

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final color = locked ? t.outline : (_colors[league] ?? t.gold);

    return Semantics(
      label: '${_labels[league]}${locked ? ' — verrouillé' : ''}',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: locked ? 0.08 : 0.18),
          border: Border.all(color: color, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          _labels[league]!.substring(0, 1),
          style: GoogleFonts.oswald(
            color: locked ? t.textFaint : color,
            fontSize: size * 0.42,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Médaillon : cadre ornemental grenat et or. Emplacement d'illustration.
//
// `image` reste vide jusqu'à ce qu'une vraie illustration existe — le cadre
// tient seul, il ne réclame pas de remplissage.
// ─────────────────────────────────────────────────────────────────────────────
class Medallion extends StatelessWidget {
  final double size;
  final Widget? image;
  final int? level;

  const Medallion({super.key, this.size = 132, this.image, this.level});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _MedallionRing(ring: t.istang, jewel: t.istangJewel),
          ),
          ClipOval(
            child: SizedBox(
              width: size * 0.68,
              height: size * 0.68,
              child: image ??
                  ColoredBox(
                    color: t.surfaceSunken,
                    child: Center(
                      child: Icon(
                        Icons.local_fire_department_rounded,
                        color: t.istangJewel,
                        size: size * 0.3,
                      ),
                    ),
                  ),
            ),
          ),
          if (level != null)
            Positioned(
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: t.istang,
                  borderRadius: LinguaRadius.rPill,
                  border: Border.all(color: t.istangJewel, width: 1.5),
                ),
                child: Text(
                  'NIV. $level',
                  style: GoogleFonts.jetBrainsMono(
                    color: t.istangJewel,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MedallionRing extends CustomPainter {
  final Color ring;
  final Color jewel;

  _MedallionRing({required this.ring, required this.jewel});

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;

    canvas.drawCircle(
      c,
      r - 1,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = ring,
    );
    canvas.drawCircle(
      c,
      r - 7,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = jewel.withValues(alpha: 0.5),
    );

    // Douze dents sur l'anneau — le motif du feutre Istang.
    for (var i = 0; i < 12; i++) {
      final a = (i / 12) * 2 * math.pi - math.pi / 2;
      canvas.drawCircle(
        c + Offset(math.cos(a), math.sin(a)) * (r - 4),
        2,
        Paint()..color = jewel,
      );
    }
  }

  @override
  bool shouldRepaint(_MedallionRing old) =>
      old.ring != ring || old.jewel != jewel;
}
