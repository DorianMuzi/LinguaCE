import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_ce/design/lingua_theme.dart';
import 'package:lingua_ce/i18n/app_strings.dart';
import 'package:lingua_ce/i18n/locale_controller.dart';
import 'package:lingua_ce/models/models.dart';
import 'package:lingua_ce/services/lexicon_service.dart';
import 'package:lingua_ce/services/muzin_dar.dart';
import 'package:lingua_ce/widgets/letter_bar.dart';

const dot = '̇';

void main() {
  group('alphabet (spec Core 0.1)', () {
    test('41 lettres, 16 absentes d\'un clavier ordinaire, dans l\'ordre', () {
      expect(MuzinDar.letters, hasLength(41));
      expect(MuzinDar.letters.toSet(), hasLength(41));
      expect(MuzinDar.letters, isNot(contains('w')));
      expect(MuzinDar.special.join(' '),
          'ä ċ ç ç$dot ə ġ k$dot ŋ ö ṗ q$dot ş ṫ ü ẋ ƶ');
    });

    test('points de code : précomposés quand ils existent, sinon + U+0307', () {
      for (final l in ['ċ', 'ġ', 'ṗ', 'ṫ', 'ẋ']) {
        expect(l.length, 1, reason: '$l doit être précomposé');
      }
      for (final l in ['ç$dot', 'k$dot', 'q$dot']) {
        expect(MuzinDar.letters, contains(l));
      }
      expect('ş'.codeUnitAt(0), 0x015F, reason: 's cédille, pas ș');
      expect('ƶ'.codeUnitAt(0), 0x01B6);
      expect('ə'.codeUnitAt(0), 0x0259);
    });

    test('majuscules : seule la lettre de base change', () {
      expect(MuzinDar.upper('ç$dot'), 'Ç$dot');
      expect(MuzinDar.upper('q$dot'), 'Q$dot');
      expect(MuzinDar.upper('ə'), 'Ə');
      expect(MuzinDar.upper('ƶ'), 'Ƶ');
      expect(MuzinDar.upper('ŋ'), 'Ŋ');
      expect(MuzinDar.upper('ẋ'), 'Ẋ');
    });

    test('ordre alphabétique validé, pas celui des points de code', () {
      final words = ['ya', 'ẋa', 'ba', 'äla', 'azz', 'ç${dot}ara', 'çay', 'ċa',
          'ca', 'q${dot}a', 'qa', 'ra'];
      words.sort(MuzinDar.compare);
      expect(words, ['azz', 'äla', 'ba', 'ca', 'ċa', 'çay', 'ç${dot}ara',
          'qa', 'q${dot}a', 'ra', 'ẋa', 'ya']);
      // Accent tonique et casse ignorés.
      expect(MuzinDar.compare('Ála', 'ala'), isNot(lessThan(0)));
      expect(MuzinDar.compare('ála', 'äla'), lessThan(0));
    });

    test('le dictionnaire suit cet ordre', () {
      Lexeme w(int id, String latin) =>
          Lexeme(id: id, cyrillic: 'х', latin: latin, pos: 'noun');
      final sorted = LexiconService.search(
          [w(1, 'yurt'), w(2, 'ẋaŋ'), w(3, 'ä'), w(4, 'b')], '', 'FR');
      expect(sorted.map((l) => l.latin), ['ä', 'b', 'ẋaŋ', 'yurt']);
    });

    test('les textes CE de l\'app n\'utilisent que des lettres de l\'alphabet',
        () {
      final allowed = {
        for (final l in MuzinDar.letters) ...[l, MuzinDar.upper(l)],
      };
      final bad = <String>{};
      for (final e in debugAppStrings.entries) {
        final ce = e.value['CE'] ?? '';
        final chars = ce.runes.map(String.fromCharCode).toList();
        for (var i = 0; i < chars.length; i++) {
          final c = chars[i];
          if (c == dot) continue;
          final isLetter = RegExp(r'\p{L}', unicode: true).hasMatch(c);
          if (!isLetter || c.codeUnitAt(0) < 0x80) continue;
          final withDot = i + 1 < chars.length && chars[i + 1] == dot;
          if (!allowed.contains(withDot ? '$c$dot' : c)) bad.add('${e.key}: $c');
        }
      }
      expect(bad, isEmpty);
    });
  });

  group('barre de lettres', () {
    late TextEditingController ctrl;
    late FocusNode focus;

    Future<void> pump(WidgetTester tester) async {
      final initial = localeController.value;
      addTearDown(() => localeController.value = initial);
      localeController.value = 'FR';
      ctrl = TextEditingController();
      focus = FocusNode();
      addTearDown(ctrl.dispose);
      addTearDown(focus.dispose);
      await tester.pumpWidget(MaterialApp(
        theme: LinguaTheme.dark(),
        home: Scaffold(
          body: Column(children: [
            TextField(controller: ctrl, focusNode: focus),
            LetterBar(controller: ctrl, focusNode: focus),
          ]),
        ),
      ));
    }

    Finder key(String l) =>
        find.bySemanticsLabel(tr('letters.insert', {'l': l}));

    testWidgets('insère au curseur et garde le focus du champ', (tester) async {
      final semantics = tester.ensureSemantics();
      await pump(tester);
      await tester.tap(find.byType(TextField));
      await tester.enterText(find.byType(TextField), 'aŋ');
      ctrl.selection = const TextSelection.collapsed(offset: 0);
      await tester.pump();

      await tester.tap(key('ẋ'));
      await tester.pump();
      expect(ctrl.text, 'ẋaŋ');
      expect(ctrl.selection.baseOffset, 1);
      expect(focus.hasFocus, isTrue);

      // ç̇ : deux points de code insérés d'un coup, curseur après les deux.
      ctrl.selection = TextSelection.collapsed(offset: ctrl.text.length);
      await tester.tap(key('ç$dot'));
      await tester.pump();
      expect(ctrl.text, 'ẋaŋç$dot');
      expect(ctrl.selection.baseOffset, ctrl.text.length);
      semantics.dispose();
    });

    testWidgets('⇧ : une seule majuscule, puis retour aux minuscules',
        (tester) async {
      final semantics = tester.ensureSemantics();
      await pump(tester);
      await tester.tap(find.bySemanticsLabel(tr('letters.shift')));
      await tester.pump();
      await tester.tap(key('Ç$dot'));
      await tester.pump();
      await tester.tap(key('ä'));
      await tester.pump();
      expect(ctrl.text, 'Ç$dotä');
      semantics.dispose();
    });

    test('remplace la sélection', () {
      final v = LetterBar.insert(
        const TextEditingValue(
            text: 'xala',
            selection: TextSelection(baseOffset: 0, extentOffset: 1)),
        'ẋ',
      );
      expect(v.text, 'ẋala');
      expect(v.selection.baseOffset, 1);
    });
  });
}
