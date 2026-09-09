import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../design/lingua_scale.dart';
import '../design/lingua_theme.dart';
import '../design/lingua_tokens.dart';

/// Barre d'XP : le niveau à gauche, le compte à droite, la jauge dessous.
///
/// L'XP est **or** dans le système, pas bleu — `--reward: var(--gold-500)`.
/// Le bleu est la couleur de l'interaction ; l'or celle de la progression.
/// Les mélanger fait perdre au bleu son sens de « ceci est actionnable ».
class XpBar extends StatelessWidget {
  final int xp;
  final int xpToNext;
  final int level;

  /// Anime la jauge depuis sa valeur précédente. À laisser actif après une
  /// leçon : c'est là que le gain se lit.
  final bool animate;

  const XpBar({
    super.key,
    required this.xp,
    required this.xpToNext,
    required this.level,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final progress = xpToNext <= 0 ? 0.0 : (xp / xpToNext).clamp(0.0, 1.0);

    return Semantics(
      label: 'Niveau $level, $xp XP sur $xpToNext',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'NIV. $level',
                style: GoogleFonts.jetBrainsMono(
                  color: t.goldInk,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.6,
                ),
              ),
              Text(
                '$xp / $xpToNext XP',
                style: LinguaType.number(t.textTertiary, size: 11),
              ),
            ],
          ),
          const SizedBox(height: 7),
          _Track(progress: progress, animate: animate),
        ],
      ),
    );
  }
}

class _Track extends StatelessWidget {
  final double progress;
  final bool animate;

  const _Track({required this.progress, required this.animate});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress),
      duration: animate ? LinguaDuration.slow : Duration.zero,
      curve: LinguaCurves.out,
      builder: (context, value, _) => LayoutBuilder(
        builder: (context, c) => Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: t.surfaceSunken,
                borderRadius: LinguaRadius.rPill,
              ),
            ),
            Container(
              height: 8,
              width: c.maxWidth * value,
              decoration: BoxDecoration(
                // L'or vire au clair vers la tête de la jauge : la
                // progression paraît en mouvement même à l'arrêt.
                gradient: LinearGradient(
                  colors: [t.gold, LinguaPalette.gold400],
                ),
                borderRadius: LinguaRadius.rPill,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
