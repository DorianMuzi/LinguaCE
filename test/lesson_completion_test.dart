import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_ce/services/lesson_service.dart';

void main() {
  group('LessonCompletion.fromRpc', () {
    test('première complétion : XP crédité, pas déjà terminée', () {
      final r = LessonCompletion.fromRpc({
        'xp_awarded': 100,
        'already_completed': false,
        'xp': 100,
        'level': 1,
        'league': 'stone',
      });
      expect(r.xpAwarded, 100);
      expect(r.alreadyCompleted, isFalse);
    });

    test('révision : aucun XP, déjà terminée', () {
      final r = LessonCompletion.fromRpc({
        'xp_awarded': 0,
        'already_completed': true,
      });
      expect(r.xpAwarded, 0);
      expect(r.alreadyCompleted, isTrue);
    });

    test('accepte un nombre non entier renvoyé par le JSON', () {
      final r = LessonCompletion.fromRpc({'xp_awarded': 150.0});
      expect(r.xpAwarded, 150);
    });

    test('réponse inattendue : tolérée, ne passe pas pour un échec', () {
      for (final bad in <dynamic>[null, 'ok', 42, <dynamic>[]]) {
        final r = LessonCompletion.fromRpc(bad);
        expect(r.xpAwarded, 0);
        expect(r.alreadyCompleted, isFalse);
      }
    });
  });
}
