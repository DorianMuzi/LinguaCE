import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_ce/design/lingua_theme.dart';
import 'package:lingua_ce/i18n/app_strings.dart';
import 'package:lingua_ce/models/models.dart';
import 'package:lingua_ce/screens/onboarding_screen.dart';
import 'package:lingua_ce/services/onboarding_service.dart';
import 'package:lingua_ce/widgets/report_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lignes directrices d'accessibilité de Flutter, vérifiées sur les écrans
/// testables sans Supabase, dans les deux thèmes :
/// - cibles tactiles ≥ 48 × 48 dp (Android) ;
/// - toute cible tactile a un libellé pour les lecteurs d'écran.
///
/// Le contraste est vérifié token par token dans `contrast_test.dart` :
/// `textContrastGuideline` capture l'écran en asynchrone réel, ce qui laisse
/// google_fonts tenter (et rater) ses téléchargements pendant le test.
Future<void> _meetsGuidelines(WidgetTester tester) async {
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
}

void main() {
  for (final (name, theme) in [
    ('sombre', LinguaTheme.dark),
    ('clair', LinguaTheme.light),
  ]) {
    testWidgets('onboarding, chaque étape — thème $name', (tester) async {
      final semantics = tester.ensureSemantics();
      SharedPreferences.setMockInitialValues({});
      await OnboardingService.load();
      await tester.binding.setSurfaceSize(const Size(400, 860));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(MaterialApp(
        theme: theme(),
        home: const OnboardingScreen(showReminderStep: true),
      ));
      await tester.pumpAndSettle();

      for (var step = 0; step < 4; step++) {
        await _meetsGuidelines(tester);
        if (step < 3) {
          await tester.tap(find.text(tr('onb.next')));
          await tester.pumpAndSettle();
        }
      }
      semantics.dispose();
    });

    testWidgets('feuille « Signaler une erreur » — thème $name',
        (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(MaterialApp(
        theme: theme(),
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: TextButton(
                onPressed: () => showReportSheet(
                  context,
                  lessonId: '1',
                  position: 1,
                  exercise: const Exercise(
                    type: ExerciseType.flashcard,
                    cyrillic: 'Баркалла',
                    translit: 'Barkalla',
                    french: 'Merci',
                  ),
                  submit: (_, __) async => true,
                ),
                child: const Text('ouvrir'),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('ouvrir'));
      await tester.pumpAndSettle();
      await _meetsGuidelines(tester);
      semantics.dispose();
    });
  }
}
