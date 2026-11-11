import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_ce/design/lingua_theme.dart';
import 'package:lingua_ce/i18n/app_strings.dart';
import 'package:lingua_ce/screens/onboarding_screen.dart';
import 'package:lingua_ce/services/claude_service.dart';
import 'package:lingua_ce/services/onboarding_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('OnboardingService', () {
    test('valeurs par défaut : pas fait, débutant', () async {
      SharedPreferences.setMockInitialValues({});
      await OnboardingService.load();
      expect(OnboardingService.done, isFalse);
      expect(OnboardingService.level, LearnerLevel.beginner);
    });

    test('complete() persiste le niveau et le marqueur', () async {
      SharedPreferences.setMockInitialValues({});
      await OnboardingService.load();
      await OnboardingService.complete(LearnerLevel.advanced);

      // Relecture « à froid », comme au prochain lancement.
      await OnboardingService.load();
      expect(OnboardingService.done, isTrue);
      expect(OnboardingService.level, LearnerLevel.advanced);
    });

    test('valeur persistée inconnue : repli sur débutant', () async {
      SharedPreferences.setMockInitialValues({'learner_level': 'expert'});
      await OnboardingService.load();
      expect(OnboardingService.level, LearnerLevel.beginner);
    });
  });

  group('Naxçi — consigne de niveau', () {
    test('le niveau va dans le bloc variable, pas dans le bloc en cache', () {
      final blocks =
          ClaudeService.buildSystemBlocks('FR', level: LearnerLevel.advanced);
      expect(blocks, hasLength(2));
      // Le premier bloc (grammaire, en cache) ne dépend pas du niveau.
      final beginner =
          ClaudeService.buildSystemBlocks('FR', level: LearnerLevel.beginner);
      expect(blocks.first['text'], beginner.first['text']);
      expect(blocks.first['cache_control'], isNotNull);
      // Le second porte la langue ET le niveau.
      expect(blocks.last['text'], contains('français'));
      expect(blocks.last['text'], contains('avancé'));
      expect(blocks.last.containsKey('cache_control'), isFalse);
    });

    test('CE : tchétchène seul, prime sur les règles du bloc en cache', () {
      final text = ClaudeService.buildSystemBlocks('CE').last['text'] as String;
      expect(text, contains('TCHÉTCHÈNE UNIQUEMENT'));
      expect(text, contains('PRIME'));
      expect(text, contains('Muziŋ Dar'));
      expect(text, isNot(contains('1992')));
      // La langue vient après le niveau : c'est la dernière consigne lue.
      expect(text.indexOf('TCHÉTCHÈNE'),
          greaterThan(text.indexOf(ClaudeService.levelInstruction(
              LearnerLevel.beginner))));
    });

    test('chaque niveau a une consigne distincte', () {
      final texts =
          LearnerLevel.values.map(ClaudeService.levelInstruction).toSet();
      expect(texts, hasLength(LearnerLevel.values.length));
    });
  });

  group('i18n', () {
    test('toutes les clés d\'onboarding existent', () {
      final keys = [
        'onb.next', 'onb.back', 'onb.start',
        for (final s in ['p1', 'p2', 'p3', 'p4']) ...['onb.${s}_title'],
        'onb.p1_body', 'onb.p2_body', 'onb.p3_body', 'onb.p4_body',
        'onb.p4_switch', 'set.level',
        for (final l in LearnerLevel.values) ...[
          'onb.lvl.${l.key}',
          'onb.lvl.${l.key}_desc',
        ],
      ];
      for (final k in keys) {
        expect(tr(k), isNot(k), reason: 'clé manquante : $k');
      }
    });
  });

  group('OnboardingScreen', () {
    Future<void> pump(WidgetTester tester, {required bool reminder}) async {
      SharedPreferences.setMockInitialValues({});
      await OnboardingService.load();
      await tester.binding.setSurfaceSize(const Size(400, 860));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(MaterialApp(
        theme: LinguaTheme.dark(),
        home: OnboardingScreen(showReminderStep: reminder),
      ));
      await tester.pumpAndSettle();
    }

    Future<void> next(WidgetTester tester) async {
      await tester.tap(find.text(tr('onb.next')));
      await tester.pumpAndSettle();
    }

    testWidgets('parcours : niveau choisi et étape rappel', (tester) async {
      await pump(tester, reminder: true);
      expect(find.text(tr('onb.p1_title')), findsOneWidget);
      expect(find.text(tr('onb.back')), findsNothing);

      await next(tester);
      expect(find.text(tr('onb.p2_title')), findsOneWidget);
      expect(find.text(tr('onb.back')), findsOneWidget);

      await next(tester);
      expect(find.text(tr('onb.p3_title')), findsOneWidget);
      await tester.tap(find.text(tr('onb.lvl.intermediate')));
      await tester.pumpAndSettle();

      await next(tester);
      expect(find.text(tr('onb.p4_title')), findsOneWidget);
      expect(find.text(tr('onb.start')), findsOneWidget);

      // Retour arrière : le choix de niveau est conservé (une seule coche,
      // sur la carte « intermédiaire »).
      await tester.tap(find.text(tr('onb.back')));
      await tester.pumpAndSettle();
      final check = find.byIcon(Icons.check_circle_rounded);
      expect(check, findsOneWidget);
      final cardOfCheck = find.ancestor(of: check, matching: find.byType(Row));
      expect(
        find.descendant(
            of: cardOfCheck.first,
            matching: find.text(tr('onb.lvl.intermediate'))),
        findsOneWidget,
      );
    });

    testWidgets('sans étape rappel (web) : 3 étapes', (tester) async {
      await pump(tester, reminder: false);
      await next(tester);
      await next(tester);
      expect(find.text(tr('onb.p3_title')), findsOneWidget);
      expect(find.text(tr('onb.start')), findsOneWidget);
      expect(find.text(tr('onb.p4_title')), findsNothing);
    });
  });
}
