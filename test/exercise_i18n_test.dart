import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_ce/models/models.dart';

Map<String, dynamic> _row({dynamic i18n}) => {
      'type': 'qcm',
      'cyrillic': 'Дика',
      'translit': 'Dika',
      'french': 'Bien / Bon',
      'prompt': 'Que signifie "Dika" ?',
      'choices': ['Mauvais', 'Beaucoup', 'Bien / Bon', 'Peu'],
      'correct_index': 2,
      'i18n': ?i18n,
    };

void main() {
  test('sens, consigne et propositions dans la langue demandée', () {
    final ex = Exercise.fromRow(_row(i18n: {
      'EN': {
        'meaning': 'Good',
        'prompt': 'What does "Dika" mean?',
        'choices': ['Bad', 'A lot', 'Good', 'A little'],
      },
    }))!;
    expect(ex.meaningFor('EN'), 'Good');
    expect(ex.promptFor('EN'), 'What does "Dika" mean?');
    expect(ex.choicesFor('EN')![ex.correctIndex!], 'Good');
  });

  test('langue sans traduction → français ; tchétchène inchangé', () {
    final ex = Exercise.fromRow(_row(i18n: {
      'EN': {'meaning': 'Good'},
    }))!;
    expect(ex.meaningFor('RU'), 'Bien / Bon');
    expect(ex.meaningFor('CE'), 'Bien / Bon');
    expect(ex.promptFor('EN'), 'Que signifie "Dika" ?'); // consigne absente
    expect(ex.choicesFor('EN'), ex.choices); // propositions absentes
    expect(ex.translit, 'Dika');
  });

  test('propositions traduites de mauvaise longueur ignorées', () {
    final ex = Exercise.fromRow(_row(i18n: {
      'EN': {
        'choices': ['Bad', 'Good'], // 2 au lieu de 4 : l'index 2 n'existe pas
      },
    }))!;
    expect(ex.choicesFor('EN'), ex.choices);
  });

  test('colonne i18n absente ou malformée : exercice toujours jouable', () {
    expect(Exercise.fromRow(_row())!.meaningFor('EN'), 'Bien / Bon');
    final ex = Exercise.fromRow(_row(i18n: {
      'EN': 'pas un objet',
      'RU': {'meaning': '  ', 'choices': 'pas une liste'},
    }))!;
    expect(ex.meaningFor('EN'), 'Bien / Bon');
    expect(ex.meaningFor('RU'), 'Bien / Bon'); // vide → repli
    expect(ex.choicesFor('RU'), ex.choices);
  });
}
