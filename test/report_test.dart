import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_ce/design/lingua_theme.dart';
import 'package:lingua_ce/i18n/app_strings.dart';
import 'package:lingua_ce/models/models.dart';
import 'package:lingua_ce/services/report_service.dart';
import 'package:lingua_ce/widgets/report_sheet.dart';

const _ex = Exercise(
  type: ExerciseType.flashcard,
  cyrillic: 'Баркалла',
  translit: 'Barkalla',
  french: 'Merci',
);

void main() {
  group('ReportService.buildRow', () {
    test('instantané de l\'exercice + catégorie', () {
      final row = ReportService.buildRow(
        lessonId: '1',
        position: 3,
        exercise: _ex,
        category: ReportCategory.translation,
        comment: '  mauvaise traduction  ',
        language: 'FR',
      );
      expect(row['lesson_id'], '1');
      expect(row['exercise_position'], 3);
      expect(row['exercise_type'], 'flashcard');
      expect(row['translit'], 'Barkalla');
      expect(row['cyrillic'], 'Баркалла');
      expect(row['french'], 'Merci');
      expect(row['category'], 'translation');
      expect(row['comment'], 'mauvaise traduction');
      expect(row['interface_language'], 'FR');
      // L'utilisateur et le statut sont fixés par le serveur, jamais envoyés.
      expect(row.containsKey('user_id'), isFalse);
      expect(row.containsKey('status'), isFalse);
    });

    test('commentaire vide omis, commentaire trop long tronqué', () {
      expect(
        ReportService.buildRow(
                lessonId: '1',
                position: 1,
                exercise: _ex,
                category: ReportCategory.other,
                comment: '   ')
            .containsKey('comment'),
        isFalse,
      );
      final long = ReportService.buildRow(
          lessonId: '1',
          position: 1,
          exercise: _ex,
          category: ReportCategory.other,
          comment: 'x' * 5000);
      expect((long['comment'] as String).length, ReportService.maxComment);
    });

    test('les catégories correspondent à la contrainte SQL', () {
      expect(ReportCategory.values.map((c) => c.key),
          ['translit', 'translation', 'other']);
    });
  });

  test('toutes les clés i18n du signalement existent', () {
    for (final k in [
      'report.title', 'report.cat_translit', 'report.cat_translation',
      'report.cat_other', 'report.comment_hint', 'report.send',
      'report.thanks', 'report.failed',
    ]) {
      expect(tr(k), isNot(k), reason: 'clé manquante : $k');
    }
  });

  group('feuille de signalement', () {
    Future<void> open(
      WidgetTester tester,
      Future<bool> Function(ReportCategory, String) submit,
    ) async {
      await tester.pumpWidget(MaterialApp(
        theme: LinguaTheme.dark(),
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: TextButton(
                onPressed: () => showReportSheet(context,
                    lessonId: '1', position: 1, exercise: _ex, submit: submit),
                child: const Text('ouvrir'),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('ouvrir'));
      await tester.pumpAndSettle();
    }

    testWidgets('envoi réussi : catégorie et commentaire transmis, merci',
        (tester) async {
      ReportCategory? gotCategory;
      String? gotComment;
      await open(tester, (c, comment) async {
        gotCategory = c;
        gotComment = comment;
        return true;
      });

      expect(find.text('Barkalla'), findsOneWidget);
      await tester.tap(find.text(tr('report.cat_translation')));
      await tester.enterText(find.byType(TextField), 'faux sens');
      await tester.tap(find.text(tr('report.send')));
      await tester.pumpAndSettle();

      expect(gotCategory, ReportCategory.translation);
      expect(gotComment, 'faux sens');
      expect(find.text(tr('report.title')), findsNothing); // feuille fermée
      expect(find.text(tr('report.thanks')), findsOneWidget);
    });

    testWidgets('échec : la feuille reste ouverte avec un message',
        (tester) async {
      await open(tester, (_, __) async => false);
      await tester.tap(find.text(tr('report.send')));
      await tester.pumpAndSettle();

      expect(find.text(tr('report.title')), findsOneWidget);
      expect(find.text(tr('report.failed')), findsOneWidget);
      expect(find.text(tr('report.thanks')), findsNothing);
    });
  });
}
