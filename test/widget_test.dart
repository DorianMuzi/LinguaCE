import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_ce/config/app_config.dart';
import 'package:lingua_ce/design/lingua_tokens.dart';

/// Tests unitaires déterministes (sans plateforme ni secrets) — sûrs pour la CI.
void main() {
  group('AppConfig', () {
    test('un modèle Claude par défaut est défini', () {
      expect(AppConfig.anthropicModel, isNotEmpty);
    });

    test('sans secrets injectés, les clés sont absentes', () {
      // En CI, aucune variable --dart-define n'est passée.
      expect(AppConfig.hasAnthropicKey, isFalse);
      expect(AppConfig.hasSupabase, isFalse);
    });
  });

  group('LinguaTokens', () {
    test('les thèmes clair et sombre sont distincts', () {
      expect(LinguaTokens.light.isDark, isFalse);
      expect(LinguaTokens.dark.isDark, isTrue);
      // Ce sont les alias SÉMANTIQUES qui basculent : le sol et le texte.
      expect(
        LinguaTokens.light.surfaceBase,
        isNot(equals(LinguaTokens.dark.surfaceBase)),
      );
      expect(
        LinguaTokens.light.textPrimary,
        isNot(equals(LinguaTokens.dark.textPrimary)),
      );
    });

    test('les rampes de marque ne changent pas de thème', () {
      // Décision du design system (`tokens/theme-light.css`) : le bleu
      // d'interaction et les registres ember/or/grenat restent identiques,
      // pour que les couleurs de ligue et l'ornement Istang ne bougent pas.
      expect(LinguaTokens.light.accent, equals(LinguaTokens.dark.accent));
      expect(LinguaTokens.light.ember, equals(LinguaTokens.dark.ember));
      expect(LinguaTokens.light.gold, equals(LinguaTokens.dark.gold));
      expect(LinguaTokens.light.garnet, equals(LinguaTokens.dark.garnet));
    });

    test('l\'or lisible en texte s\'assombrit sur le thème clair', () {
      // `gold` est réservé aux aplats ; `goldInk` porte le texte.
      expect(LinguaTokens.dark.goldInk, equals(LinguaTokens.dark.gold));
      expect(
        LinguaTokens.light.goldInk,
        isNot(equals(LinguaTokens.light.gold)),
      );
    });

    test('le lerp entre deux thèmes reste valide', () {
      final mid = LinguaTokens.light.lerp(LinguaTokens.dark, 0.5);
      expect(mid, isA<LinguaTokens>());
    });
  });
}
