import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_ce/services/profile_service.dart';

void main() {
  group('ProfileService.effectiveStreak', () {
    test('profil absent ou sans activité → 0', () {
      expect(ProfileService.effectiveStreak(null), 0);
      expect(ProfileService.effectiveStreak({'streak': 5}), 0);
    });

    test('activité aujourd\'hui → série conservée', () {
      final today = DateTime.now().toIso8601String();
      expect(
        ProfileService.effectiveStreak({'streak': 5, 'last_activity': today}),
        5,
      );
    });

    test('activité hier → série conservée (encore rattrapable aujourd\'hui)',
        () {
      final yesterday =
          DateTime.now().subtract(const Duration(days: 1)).toIso8601String();
      expect(
        ProfileService.effectiveStreak(
            {'streak': 12, 'last_activity': yesterday}),
        12,
      );
    });

    test('plus d\'un jour civil sans activité → série rompue (0)', () {
      final old =
          DateTime.now().subtract(const Duration(days: 3)).toIso8601String();
      expect(
        ProfileService.effectiveStreak({'streak': 12, 'last_activity': old}),
        0,
      );
    });
  });
}
