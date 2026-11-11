import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_ce/i18n/app_strings.dart';
import 'package:lingua_ce/i18n/locale_controller.dart';
import 'package:lingua_ce/models/models.dart';
import 'package:lingua_ce/screens/home_screen.dart';

LessonModel _lesson(String id, LessonStatus status) => LessonModel(
      id: id,
      title: 'Leçon $id',
      subtitle: '',
      icon: '',
      status: status,
      xpReward: 100,
      totalExercises: 6,
      completedExercises: 0,
    );

void main() {
  final lessons = [
    _lesson('1', LessonStatus.completed),
    _lesson('2', LessonStatus.completed),
    _lesson('3', LessonStatus.active),
    _lesson('4', LessonStatus.locked),
  ];

  group('Réviser', () {
    test('aucune leçon terminée → pas de révision proposée', () {
      final fresh = [
        _lesson('1', LessonStatus.active),
        _lesson('2', LessonStatus.locked),
      ];
      expect(HomeScreen.reviewLesson(fresh, 0), isNull);
      expect(HomeScreen.reviewLesson(const [], 0), isNull);
    });

    test('ne propose que des leçons terminées, en rotation quotidienne', () {
      expect(HomeScreen.reviewLesson(lessons, 0)!.id, '1');
      expect(HomeScreen.reviewLesson(lessons, 1)!.id, '2');
      expect(HomeScreen.reviewLesson(lessons, 2)!.id, '1');
      for (var day = 0; day < 10; day++) {
        expect(HomeScreen.reviewLesson(lessons, day)!.status,
            LessonStatus.completed);
      }
    });
  });

  group('Leçon à reprendre', () {
    test('la leçon en cours en priorité', () {
      expect(HomeScreen.currentLesson(lessons)!.id, '3');
    });

    test('sinon la première non terminée, sinon la première', () {
      expect(
          HomeScreen.currentLesson([
            _lesson('1', LessonStatus.completed),
            _lesson('2', LessonStatus.locked),
          ])!.id,
          '2');
      expect(
          HomeScreen.currentLesson([
            _lesson('1', LessonStatus.completed),
            _lesson('2', LessonStatus.completed),
          ])!.id,
          '1');
      expect(HomeScreen.currentLesson(const []), isNull);
    });
  });

  test('dayIndex change à minuit, pas à heure fixe', () {
    expect(HomeScreen.dayIndex(DateTime(2026, 1, 1, 23, 59)), 0);
    expect(HomeScreen.dayIndex(DateTime(2026, 1, 2, 0, 1)), 1);
  });

  test('chaînes des actions rapides présentes dans les 4 langues', () {
    const keys = [
      'home.qa_review', 'home.qa_review_none', 'home.qa_practice',
      'home.qa_practice_sub', 'home.qa_practice_prompt',
    ];
    final initial = localeController.value;
    addTearDown(() => localeController.value = initial);
    for (final k in keys) {
      localeController.value = 'FR';
      final fr = tr(k);
      expect(fr, isNot(k), reason: 'clé manquante : $k');
      // tr() se replie sur le FR : une traduction absente se verrait ici.
      for (final lang in ['EN', 'RU', 'CE']) {
        localeController.value = lang;
        expect(tr(k), isNot(fr), reason: '$k sans $lang');
      }
    }
  });

  test('la question pré-remplie cite le mot du jour', () {
    final prompt = tr('home.qa_practice_prompt', {'w': 'barkalla', 'm': 'Merci'});
    expect(prompt, contains('barkalla'));
  });
}
