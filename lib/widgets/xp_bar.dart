import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../design/lingua_tokens.dart';

class XpBar extends StatelessWidget {
  final int xp;
  final int xpToNext;
  final int level;

  const XpBar({
    super.key,
    required this.xp,
    required this.xpToNext,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final progress = (xp / xpToNext).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'NIV.$level',
              style: GoogleFonts.spaceMono(
                color: t.accent,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              '$xp / $xpToNext XP',
              style: GoogleFonts.spaceMono(
                color: t.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 6,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: t.surfaceSunken,
              valueColor: AlwaysStoppedAnimation<Color>(t.accent),
            ),
          ),
        ),
      ],
    );
  }
}
