import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../design/lingua_components.dart';
import '../design/lingua_scale.dart';
import '../design/lingua_tokens.dart';
import '../i18n/app_strings.dart';

/// La barre de navigation flottante, en liquid glass.
///
/// Elle flotte au-dessus du contenu avec un retrait de 14 px des bords
/// (`--tabbar-inset`) : c'est ce retrait qui la fait lire comme un objet posé
/// sur la page plutôt que comme un bord d'écran.
///
/// Les couleurs viennent des tokens — plus de valeurs codées en dur, donc la
/// barre suit le thème clair sans correctif.
class FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    _NavItem(icon: Icons.home_rounded, label: 'nav.home'),
    _NavItem(icon: Icons.chat_bubble_rounded, label: 'nav.chat'),
    _NavItem(icon: Icons.menu_book_rounded, label: 'nav.learn'),
    _NavItem(icon: Icons.bar_chart_rounded, label: 'nav.progress'),
  ];

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: LinguaSpacing.sm),
      radius: LinguaRadius.rXl,
      strong: true,
      child: SizedBox(
        height: LinguaFrame.tabBarHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            _items.length,
            (i) => _NavButton(
              item: _items[i],
              isSelected: currentIndex == i,
              onTap: () => onTap(i),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _NavButton extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final ink = isSelected ? t.textAccent : t.textTertiary;

    return Semantics(
      button: true,
      selected: isSelected,
      label: tr(item.label),
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: LinguaRadius.rMd,
          // La cible fait 44 px de haut même si le contenu est plus petit.
          child: AnimatedContainer(
            duration: LinguaDuration.base,
            curve: LinguaCurves.out,
            constraints: const BoxConstraints(
              minWidth: LinguaFrame.minTarget + 8,
              minHeight: LinguaFrame.minTarget,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: LinguaSpacing.md,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: isSelected ? t.accentTint : Colors.transparent,
              borderRadius: LinguaRadius.rMd,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, color: ink, size: 22),
                const SizedBox(height: 3),
                Text(
                  tr(item.label).toUpperCase(),
                  style: GoogleFonts.jetBrainsMono(
                    color: ink,
                    fontSize: 9.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    letterSpacing: 0.9,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
