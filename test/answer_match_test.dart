import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_ce/data/mock_data.dart';
import 'package:lingua_ce/screens/exercise_screen.dart';

void main() {
  group('réponse tapée', () {
    test('formes de référence acceptées, avec ou sans diacritiques', () {
      expect(ExerciseScreen.answerMatches('Duqa barkalla', 'Duqa barkalla'),
          isTrue);
      expect(ExerciseScreen.answerMatches('marsa vogiyla', 'Marşa voġiyla'),
          isTrue);
      expect(ExerciseScreen.answerMatches('  KAYN ', 'k̇ayŋ'), isTrue);
    });

    test('le « ə » final est facultatif ou tapé « e »', () {
      expect(ExerciseScreen.answerMatches('qoə', 'qoə'), isTrue);
      expect(ExerciseScreen.answerMatches('qoe', 'qoə'), isTrue);
      expect(ExerciseScreen.answerMatches('qo', 'qoə'), isTrue);
    });

    test('une autre réponse reste fausse', () {
      expect(ExerciseScreen.answerMatches('pxi', 'qoə'), isFalse);
      expect(ExerciseScreen.answerMatches('Barkalla duqa', 'Duqa barkalla'),
          isFalse);
    });
  });

  test('le jeu hors-ligne suit les formes de référence', () {
    final all = MockData.exercisesByLesson.values.expand((l) => l).toList();
    final texts = [
      for (final e in all)
        ...[e.cyrillic, e.translit, e.french, e.prompt ?? '', ...?e.choices],
    ].join(' | ');
    // « огӀийла » sans le préfixe de classe в- (la nouvelle forme le contient).
    for (final old in [
      RegExp(r'(?<!в)огӀийла'),
      RegExp(r'(?<!v)oġiyla'),
      RegExp('Barkalla duqa'),
      RegExp('Vorx'),
      // « qo » isolé ; « \b » seul ne suffit pas : « ə » n'est pas une
      // lettre pour les expressions régulières, « qoə » matcherait.
      RegExp(r'\bqo(?![\wə])'),
    ]) {
      expect(old.hasMatch(texts), isFalse,
          reason: 'forme ancienne encore présente : ${old.pattern}');
    }
    expect(texts, contains('Marşa voġiyla'));
    // « Bonjour » = де дика дойла ; марша вогӀийла n'en est plus la réponse.
    expect(texts, contains('De dika doyla'));
    // « 1 » cité seul : forme absolue, comme qoə / pxiə.
    expect(texts, contains('cẋaə'));
    expect(RegExp(r'\b[Cc]ẋa(?![\wə])').hasMatch(texts), isFalse);
    expect(texts, isNot(contains('Bonjour (formel)')));
    expect(texts, contains('qoə'));
    expect(texts, contains('Pxiə'));
  });
}
