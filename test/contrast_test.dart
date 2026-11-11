import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_ce/design/lingua_tokens.dart';

/// Ratio de contraste WCAG 2.x entre deux couleurs opaques.
double contrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

/// Seuil WCAG AA pour du texte de taille normale.
const _aa = 4.5;

void main() {
  test('formule WCAG : noir sur blanc = 21:1', () {
    expect(contrast(Colors.black, Colors.white), closeTo(21, 0.01));
  });

  // Toute couleur qui sert d'encre (texte ou icône porteuse de sens) doit
  // tenir l'AA sur toutes les surfaces opaques où l'app pose du texte, dans
  // les deux thèmes. Échoue si un token est modifié sous le seuil.
  for (final (name, t) in [
    ('sombre', LinguaTokens.dark),
    ('clair', LinguaTokens.light),
  ]) {
    final surfaces = {
      'surfaceBase': t.surfaceBase,
      'surfaceRaised': t.surfaceRaised,
      'surfaceSunken': t.surfaceSunken,
      'surfaceInput': t.surfaceInput,
      'surfaceFeature': t.surfaceFeature,
    };
    final inks = {
      'textPrimary': t.textPrimary,
      'textSecondary': t.textSecondary,
      'textTertiary': t.textTertiary,
      'textFaint': t.textFaint,
      'textAccent': t.textAccent,
      'goldInk': t.goldInk,
      'emberInk': t.emberInk,
      'danger': t.danger,
      'success': t.success,
    };
    for (final MapEntry(key: ink, value: c) in inks.entries) {
      test('thème $name : $ink ≥ $_aa:1 sur chaque surface', () {
        for (final MapEntry(key: s, value: bg) in surfaces.entries) {
          final r = contrast(c, bg);
          expect(r, greaterThanOrEqualTo(_aa),
              reason: '$ink sur $s = ${r.toStringAsFixed(2)}:1');
        }
      });
    }
  }

  test('texte blanc sur les aplats d\'erreur (snackbars) ≥ $_aa:1', () {
    for (final t in [LinguaTokens.dark, LinguaTokens.light]) {
      expect(contrast(Colors.white, t.garnet), greaterThanOrEqualTo(_aa));
    }
  });
}
