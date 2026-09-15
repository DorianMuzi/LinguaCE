import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_ce/data/mock_data.dart';
import 'package:lingua_ce/models/models.dart';

/// `Exercise.fromRow` est la frontière entre la base et l'app : une ligne
/// mal formée doit être écartée, jamais faire planter la leçon.
void main() {
  Map<String, dynamic> row({
    String type = 'qcm',
    String? cyrillic = 'хи',
    String? translit = 'xi',
    String? french = 'Eau',
    String? prompt = 'Comment dit-on « Eau » ?',
    Object? choices = const ['Bepig', 'Xi', 'Şura'],
    int? correctIndex = 1,
  }) =>
      {
        'type': type,
        'cyrillic': cyrillic,
        'translit': translit,
        'french': french,
        'prompt': prompt,
        'choices': choices,
        'correct_index': correctIndex,
      };

  group('Exercise.fromRow — lignes valides', () {
    test('un QCM complet est construit', () {
      final e = Exercise.fromRow(row());
      expect(e, isNotNull);
      expect(e!.type, ExerciseType.qcm);
      expect(e.cyrillic, 'хи');
      expect(e.choices, ['Bepig', 'Xi', 'Şura']);
      expect(e.correctIndex, 1);
    });

    test('une flashcard sans choix ni consigne est construite', () {
      final e = Exercise.fromRow(row(
        type: 'flashcard',
        prompt: null,
        choices: null,
        correctIndex: null,
      ));
      expect(e, isNotNull);
      expect(e!.type, ExerciseType.flashcard);
      expect(e.prompt, isNull);
      expect(e.choices, isNull);
    });

    test('une traduction garde sa consigne', () {
      final e = Exercise.fromRow(row(
        type: 'translation',
        prompt: 'Traduis :\n« Eau »',
        choices: null,
        correctIndex: null,
      ));
      expect(e, isNotNull);
      expect(e!.type, ExerciseType.translation);
      expect(e.prompt, contains('Traduis'));
    });
  });

  group('Exercise.fromRow — lignes à écarter', () {
    test('type inconnu', () {
      expect(Exercise.fromRow(row(type: 'dictee')), isNull);
    });

    test('champ obligatoire manquant', () {
      expect(Exercise.fromRow(row(cyrillic: null)), isNull);
      expect(Exercise.fromRow(row(translit: null)), isNull);
      expect(Exercise.fromRow(row(french: null)), isNull);
    });

    test('QCM sans propositions', () {
      expect(Exercise.fromRow(row(choices: null)), isNull);
    });

    test('QCM sans index de bonne réponse', () {
      expect(Exercise.fromRow(row(correctIndex: null)), isNull);
    });

    test('QCM dont l\'index sort des propositions', () {
      expect(Exercise.fromRow(row(correctIndex: 3)), isNull);
      expect(Exercise.fromRow(row(correctIndex: -1)), isNull);
    });

    test('QCM aux propositions vides', () {
      expect(Exercise.fromRow(row(choices: const [])), isNull);
    });
  });

  test('les entrées non textuelles de `choices` sont ignorées', () {
    final e = Exercise.fromRow(row(choices: const ['Xi', 42, 'Şura']));
    expect(e, isNotNull);
    expect(e!.choices, ['Xi', 'Şura']);
  });

  group('Jeu de secours hors-ligne', () {
    test('couvre les 6 leçons existantes, 6 exercices chacune', () {
      for (final id in ['1', '2', '3', '4', '5', '6']) {
        final list = MockData.exercisesByLesson[id];
        expect(list, isNotNull, reason: 'leçon $id absente du secours');
        expect(list!.length, 6, reason: 'leçon $id : 6 exercices attendus');
      }
    });

    test('chaque QCM de secours a un index de réponse valide', () {
      for (final entry in MockData.exercisesByLesson.entries) {
        for (final e in entry.value.where((e) => e.type == ExerciseType.qcm)) {
          expect(e.choices, isNotNull, reason: 'leçon ${entry.key}');
          expect(e.correctIndex, isNotNull, reason: 'leçon ${entry.key}');
          expect(e.correctIndex! >= 0 && e.correctIndex! < e.choices!.length,
              isTrue,
              reason: 'leçon ${entry.key} : index hors des propositions');
        }
      }
    });
  });
}
