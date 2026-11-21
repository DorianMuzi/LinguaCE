import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../design/lingua_scale.dart';
import '../design/lingua_tokens.dart';
import '../i18n/app_strings.dart';
import '../services/muzin_dar.dart';

/// Barre des lettres tchétchènes absentes d'un clavier latin ordinaire
/// (ä ċ ç ç̇ ə ġ k̇ ŋ ö ṗ q̇ ş ṫ ü ẋ ƶ), à placer près d'un champ de saisie.
///
/// Une touche insère sa lettre au curseur (ou remplace la sélection) sans
/// retirer le focus au champ. ⇧ donne la majuscule de la lettre suivante.
class LetterBar extends StatefulWidget {
  final TextEditingController controller;

  /// Focus du champ, rendu après une insertion s'il l'avait perdu.
  final FocusNode? focusNode;

  const LetterBar({super.key, required this.controller, this.focusNode});

  /// Insère [s] dans [v] à la place de la sélection (à la fin s'il n'y en a
  /// pas) et place le curseur juste après.
  static TextEditingValue insert(TextEditingValue v, String s) {
    final sel = v.selection.isValid
        ? v.selection
        : TextSelection.collapsed(offset: v.text.length);
    return TextEditingValue(
      text: v.text.replaceRange(sel.start, sel.end, s),
      selection: TextSelection.collapsed(offset: sel.start + s.length),
    );
  }

  @override
  State<LetterBar> createState() => _LetterBarState();
}

class _LetterBarState extends State<LetterBar> {
  bool _shift = false;

  void _type(String letter) {
    final s = _shift ? MuzinDar.upper(letter) : letter;
    widget.controller.value = LetterBar.insert(widget.controller.value, s);
    if (_shift) setState(() => _shift = false);
    final focus = widget.focusNode;
    if (focus != null && !focus.hasFocus) focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    // TextFieldTapRegion : toucher la barre ne fait pas perdre le focus au
    // champ (sinon le clavier du téléphone se refermerait à chaque lettre).
    return TextFieldTapRegion(
      child: SizedBox(
        height: 44,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _key(
              t,
              label: tr('letters.shift'),
              selected: _shift,
              onTap: () => setState(() => _shift = !_shift),
              child: Icon(Icons.keyboard_capslock_rounded,
                  size: 20, color: _shift ? t.accentStrong : t.textSecondary),
            ),
            for (final l in MuzinDar.special)
              _key(
                t,
                label: tr('letters.insert',
                    {'l': _shift ? MuzinDar.upper(l) : l}),
                onTap: () => _type(l),
                child: Text(_shift ? MuzinDar.upper(l) : l,
                    style: GoogleFonts.manrope(
                        color: t.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _key(
    LinguaTokens t, {
    required String label,
    required VoidCallback onTap,
    required Widget child,
    bool? selected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Semantics(
        button: true,
        label: label,
        toggled: selected,
        excludeSemantics: true,
        child: Material(
          color: selected == true ? t.accentTint : t.surfaceRaised,
          shape: RoundedRectangleBorder(
            borderRadius: LinguaRadius.rMd,
            side: BorderSide(
                color: selected == true ? t.accent : t.outlineSubtle),
          ),
          child: InkWell(
            borderRadius: LinguaRadius.rMd,
            // Ne prend pas le focus : il reste au champ de saisie.
            canRequestFocus: false,
            onTap: onTap,
            child: SizedBox(width: 44, height: 44, child: Center(child: child)),
          ),
        ),
      ),
    );
  }
}
