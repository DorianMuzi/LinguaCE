import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'lingua_scale.dart';
import 'lingua_tokens.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Label de section : petite étiquette mono en capitales (métadonnée).
// ─────────────────────────────────────────────────────────────────────────────
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.spaceMono(
        color: t.textSecondary,
        fontSize: 11,
        letterSpacing: 1.5,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Carte : surface surélevée, coins arrondis, ombre douce. Tactile en option.
// ─────────────────────────────────────────────────────────────────────────────
class CopilotCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool elevated;
  final Color? color;
  final Gradient? gradient;

  const CopilotCard({
    super.key,
    required this.child,
    this.padding = LinguaSpacing.card,
    this.onTap,
    this.elevated = true,
    this.color,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final decoration = BoxDecoration(
      color: gradient == null ? (color ?? t.surfaceRaised) : null,
      gradient: gradient,
      borderRadius: LinguaRadius.rLg,
      border: Border.all(color: t.outlineSubtle),
      boxShadow: elevated ? t.shadowSm : null,
    );

    final body = AnimatedContainer(
      duration: LinguaDuration.base,
      curve: Curves.easeOut,
      padding: padding,
      decoration: decoration,
      child: child,
    );

    if (onTap == null) return body;
    return Material(
      color: Colors.transparent,
      borderRadius: LinguaRadius.rLg,
      child: InkWell(
        borderRadius: LinguaRadius.rLg,
        onTap: onTap,
        child: body,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bouton : trois variantes — plein (filled), tonal, fantôme (ghost).
// ─────────────────────────────────────────────────────────────────────────────
enum CopilotButtonVariant { filled, tonal, ghost }

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

    late final Color bg;
    late final Color fg;
    late final Color? border;
    switch (variant) {
      case CopilotButtonVariant.filled:
        bg = t.accent;
        fg = t.onAccent;
        border = null;
      case CopilotButtonVariant.tonal:
        bg = t.accentSoft;
        fg = t.accentStrong;
        border = null;
      case CopilotButtonVariant.ghost:
        bg = Colors.transparent;
        fg = t.textPrimary;
        border = t.outline;
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
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: GoogleFonts.inter(
                  color: fg,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );

    return Material(
      color: bg,
      borderRadius: LinguaRadius.rMd,
      child: InkWell(
        borderRadius: LinguaRadius.rMd,
        onTap: loading ? null : onPressed,
        child: Container(
          height: 50,
          width: expand ? double.infinity : null,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          decoration: BoxDecoration(
            borderRadius: LinguaRadius.rMd,
            border: border != null ? Border.all(color: border) : null,
          ),
          child: content,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chip d'accent : petite pastille tintée (statut, tag, ligue…).
// ─────────────────────────────────────────────────────────────────────────────
class AccentChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final String? emoji;

  const AccentChip({super.key, required this.label, this.icon, this.emoji});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: t.accentSoft,
        borderRadius: LinguaRadius.rPill,
        border: Border.all(color: t.accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (emoji != null) ...[
            Text(emoji!, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 6),
          ] else if (icon != null) ...[
            Icon(icon, size: 13, color: t.accentStrong),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: GoogleFonts.spaceMono(
              color: t.accentStrong,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Panneau "glass" : matériau translucide flouté (profondeur, Copilot).
// ─────────────────────────────────────────────────────────────────────────────
class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double blur;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding = LinguaSpacing.card,
    this.blur = 18,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return ClipRRect(
      borderRadius: LinguaRadius.rLg,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: t.surfaceGlass,
            borderRadius: LinguaRadius.rLg,
            border: Border.all(color: t.outlineSubtle),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tuile de statistique : emoji + valeur + libellé.
// ─────────────────────────────────────────────────────────────────────────────
class StatTile extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;

  const StatTile({
    super.key,
    required this.emoji,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return CopilotCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: GoogleFonts.playfairDisplay(
                  color: t.accent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                label,
                style: GoogleFonts.spaceMono(
                  color: t.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
