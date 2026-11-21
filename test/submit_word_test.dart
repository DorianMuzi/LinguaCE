import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_ce/design/lingua_theme.dart';
import 'package:lingua_ce/i18n/app_strings.dart';
import 'package:lingua_ce/i18n/locale_controller.dart';
import 'package:lingua_ce/screens/submit_word_screen.dart';
import 'package:lingua_ce/services/word_submission_service.dart';

void main() {
  group('validation', () {
    String? v(String c, String l, String m) =>
        WordSubmissionService.validate(cyrillic: c, latin: l, meaning: m);

    test('il faut une forme et un sens', () {
      expect(v('', '', 'pomme'), 'submit.err_form');
      expect(v('Ӏаж', '', ''), 'submit.err_form');
      expect(v('Ӏаж', '', 'pomme'), isNull);
      expect(v('', 'jaƶ', 'pomme'), isNull);
    });

    test('chaque champ dans son alphabet (palotchka « 1 » toléré)', () {
      expect(v('jaƶ', '', 'pomme'), 'submit.err_cyrillic');
      expect(v('1аж', '', 'pomme'), isNull);
      expect(v('', 'Ӏаж', 'pomme'), 'submit.err_latin');
    });
  });

  test('ligne envoyée : champs vides omis, langue du sens jointe', () {
    final row = WordSubmissionService.buildRow(
      cyrillic: '  Ӏаж ',
      latin: '',
      meaning: ' pomme ',
      language: 'FR',
    );
    expect(row, {'cyrillic': 'Ӏаж', 'meaning': 'pomme', 'meaning_lang': 'FR'});
  });

  testWidgets('écran : pré-rempli, erreur claire, puis envoi', (tester) async {
    final initial = localeController.value;
    addTearDown(() => localeController.value = initial);
    localeController.value = 'FR';
    final sent = <Map<String, String>>[];

    await tester.binding.setSurfaceSize(const Size(420, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(
      theme: LinguaTheme.dark(),
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SubmitWordScreen(
                  initial: 'jaƶ',
                  submit: ({required cyrillic, required latin, required meaning, note = ''}) async {
                    sent.add({'latin': latin, 'meaning': meaning});
                    return true;
                  },
                ),
              ),
            ),
            child: const Text('ouvrir'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('ouvrir'));
    await tester.pumpAndSettle();

    // Le mot cherché (latin) arrive dans le champ latin.
    expect(find.widgetWithText(TextField, 'jaƶ'), findsOneWidget);

    await tester.tap(find.text(tr('submit.send')));
    await tester.pumpAndSettle();
    expect(find.text(tr('submit.err_form')), findsOneWidget);
    expect(sent, isEmpty);

    await tester.enterText(
        find.widgetWithText(TextField, tr('submit.meaning')), 'pomme');
    await tester.tap(find.text(tr('submit.send')));
    await tester.pumpAndSettle();
    expect(sent, [
      {'latin': 'jaƶ', 'meaning': 'pomme'}
    ]);
    expect(find.text(tr('submit.thanks')), findsOneWidget);
  });
}
