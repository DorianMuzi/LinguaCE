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
      expect(
        LinguaTokens.light.accent,
        isNot(equals(LinguaTokens.dark.accent)),
      );
    });

    test('le lerp entre deux thèmes reste valide', () {
      final mid = LinguaTokens.light.lerp(LinguaTokens.dark, 0.5);
      expect(mid, isA<LinguaTokens>());
    });
  });
}
