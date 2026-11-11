import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_ce/models/models.dart';

LessonModel _lesson({Map<String, String> t = const {}}) => LessonModel(
      id: '1',
      title: 'Premiers Mots',
      subtitle: 'Vocabulaire de base',
      icon: '',
      status: LessonStatus.active,
      xpReward: 100,
      totalExercises: 6,
      completedExercises: 0,
      titleI18n: t,
      subtitleI18n: t.map((k, v) => MapEntry(k, '$v (sub)')),
    );

void main() {
  test('titre dans la langue demandée, repli sur le français', () {
    final l = _lesson(t: {'EN': 'First Words', 'CE': 'Düxẋarlera deşnaş'});
    expect(l.titleFor('EN'), 'First Words');
    expect(l.titleFor('CE'), 'Düxẋarlera deşnaş');
    expect(l.titleFor('RU'), 'Premiers Mots'); // traduction absente
    expect(l.titleFor('FR'), 'Premiers Mots');
    expect(l.subtitleFor('EN'), 'First Words (sub)');
    expect(l.subtitleFor('RU'), 'Vocabulaire de base');
  });

  test('traduction vide → repli sur le français', () {
    expect(_lesson(t: {'EN': '  '}).titleFor('EN'), 'Premiers Mots');
  });

  test('parseI18n tolère colonne absente et valeurs invalides', () {
    expect(LessonModel.parseI18n(null), isEmpty); // avant la migration
    expect(LessonModel.parseI18n('pas un objet'), isEmpty);
    expect(LessonModel.parseI18n({'EN': 'Greetings', 'RU': 42}),
        {'EN': 'Greetings'});
  });
}
