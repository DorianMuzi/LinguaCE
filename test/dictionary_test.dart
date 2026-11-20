import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_ce/design/lingua_theme.dart';
import 'package:lingua_ce/i18n/app_strings.dart';
import 'package:lingua_ce/i18n/locale_controller.dart';
import 'package:lingua_ce/models/models.dart';
import 'package:lingua_ce/screens/dictionary_screen.dart';
import 'package:lingua_ce/services/lexicon_service.dart';
import 'package:lingua_ce/services/text_fold.dart';

Lexeme _l(int id, String cyr, String lat, String pos,
        {String? cls, Map<String, List<String>> t = const {}}) =>
    Lexeme(
        id: id, cyrillic: cyr, latin: lat, pos: pos, nounClass: cls,
        translations: t);

final _words = [
  _l(1, 'баркалла', 'barkalla', 'interjection',
      t: {'FR': ['Merci'], 'EN': ['Thank you'], 'RU': ['Спасибо']}),
  _l(2, 'дукха баркалла', 'duqa barkalla', 'phrase',
      t: {'FR': ['Merci beaucoup'], 'EN': ['Thank you very much']}),
  _l(3, 'кӀайн', 'k̇ayŋ', 'adjective',
      t: {'FR': ['Blanc'], 'EN': ['White']}),
  _l(4, 'Ӏаьржа', 'järƶa', 'adjective', t: {'FR': ['Noir'], 'EN': ['Black']}),
  _l(5, 'шура', 'şura', 'noun', cls: 'y',
      t: {'FR': ['Lait'], 'EN': ['Milk'], 'RU': ['Молоко']}),
];

List<int> _ids(String q, [String lang = 'FR']) =>
    LexiconService.search(_words, q, lang).map((l) => l.id).toList();

void main() {
  group('Lexeme.fromRow', () {
    test('ligne complète', () {
      final l = Lexeme.fromRow({
        'id': 7, 'cyrillic': 'хи', 'latin': 'xi', 'sense': 1, 'pos': 'noun',
        'noun_class': 'd', 'audio_url': null,
        'translations': {'FR': ['Eau'], 'EN': ['Water'], 'XX': 'pas une liste'},
      })!;
      expect(l.latin, 'xi');
      expect(l.nounClass, 'd');
      expect(l.translationsFor('EN'), ['Water']);
      expect(l.translations.containsKey('XX'), isFalse);
    });

    test('ligne inexploitable → null', () {
      expect(Lexeme.fromRow({'id': 'x', 'cyrillic': 'хи'}), isNull);
    });

    test('traductions : langue absente → français (dont l\'interface CE)', () {
      expect(_words[0].translationsFor('CE'), ['Merci']);
      expect(_words[1].translationsFor('RU'), ['Merci beaucoup']);
    });

    test('lettres des classes nominales', () {
      expect(Lexeme.classLetter('v'), 'в');
      expect(Lexeme.classLetter('b2'), 'б II');
      expect(Lexeme.classLetter(null), isNull);
    });
  });

  group('recherche', () {
    test('requête vide : tout, par ordre alphabétique latin', () {
      expect(_ids(''), [1, 2, 4, 3, 5]);
    });

    test('latin sans diacritiques', () {
      expect(_ids('kayn'), [3]);
      expect(_ids('sura'), [5]);
      expect(_ids('JARZA'), [4]);
    });

    test('cyrillique, palochka tapé « 1 » ou « I »', () {
      expect(_ids('к1айн'), [3]);
      expect(_ids('Iаьржа'), [4]);
      expect(_ids('баркалла'), [1, 2]);
    });

    test('traduction dans la langue d\'interface, et en français', () {
      expect(_ids('milk', 'EN'), [5]);
      expect(_ids('молоко', 'RU'), [5]);
      expect(_ids('lait', 'EN'), [5]); // le français reste cherchable
    });

    test('exact avant début de mot avant le reste', () {
      // « merci » : exact pour barkalla, début de mot pour duqa barkalla.
      expect(_ids('merci'), [1, 2]);
      // « barkalla » : exact pour 1, début du 2ᵉ mot pour 2.
      expect(_ids('barkalla').first, 1);
    });

    test('rien ne correspond', () {
      expect(_ids('zzz'), isEmpty);
    });
  });

  test('TextFold.foldCyrillic ne touche pas le latin', () {
    expect(TextFold.foldCyrillic('lait 1'), 'lait 1');
  });

  group('écran', () {
    Future<void> pump(WidgetTester tester, Future<List<Lexeme>> Function() load) async {
      final initial = localeController.value;
      addTearDown(() => localeController.value = initial);
      localeController.value = 'FR';
      await tester.binding.setSurfaceSize(const Size(400, 860));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(MaterialApp(
        theme: LinguaTheme.dark(),
        home: DictionaryScreen(load: load),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('liste, filtre, classe nominale', (tester) async {
      await pump(tester, () async => _words);
      // SectionLabel affiche ses titres en capitales.
      String count(int n) => tr('dict.count', {'n': '$n'}).toUpperCase();
      expect(find.text(count(5)), findsOneWidget);
      expect(find.text('şura'), findsOneWidget);
      expect(find.text(tr('dict.class', {'c': 'й'})), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'lait');
      await tester.pumpAndSettle();
      expect(find.text(count(1)), findsOneWidget);
      expect(find.text('barkalla'), findsNothing);

      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pumpAndSettle();
      expect(find.text(tr('dict.empty')), findsOneWidget);
    });

    testWidgets('échec du chargement : message et nouvel essai',
        (tester) async {
      var calls = 0;
      await pump(tester, () async {
        calls++;
        if (calls == 1) throw Exception('hors-ligne');
        return _words;
      });
      expect(find.text(tr('err.generic')), findsOneWidget);
      await tester.tap(find.text(tr('common.retry')));
      await tester.pumpAndSettle();
      expect(find.text('barkalla'), findsOneWidget);
    });
  });
}
