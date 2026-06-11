import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../design/lingua_tokens.dart';
import '../design/lingua_scale.dart';
import '../i18n/app_strings.dart';

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
    final t = context.tokens;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: t.shadowLg,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          // Sigma modéré : un blur de 30 est sensiblement plus coûteux sur
          // les Android d'entrée de gamme pour un rendu quasi identique.
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: t.isDark
                  ? const Color(0xCC26262B)
                  : const Color(0xF2FFFFFF),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: t.outline, width: 1),
            ),
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
    // Semantics : les lecteurs d'écran annoncent un bouton et l'onglet
    // actif ; InkWell remplace GestureDetector pour le retour visuel.
    return Semantics(
      button: true,
      selected: isSelected,
      label: tr(item.label),
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: LinguaDuration.base,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: isSelected
                ? BoxDecoration(
                    color: t.accentSoft,
                    borderRadius: BorderRadius.circular(20),
                  )
                : null,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item.icon,
                  color: isSelected ? t.accentStrong : t.textSecondary,
                  size: 22,
                ),
                const SizedBox(height: 2),
                Text(
                  tr(item.label),
                  style: GoogleFonts.spaceMono(
                    color: isSelected ? t.accentStrong : t.textSecondary,
                    fontSize: 10.5,
                    letterSpacing: 0.2,
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
