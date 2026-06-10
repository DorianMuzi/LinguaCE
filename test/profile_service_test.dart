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

  group('ProfileService — ligues culturelles', () {
    test('seuils de leagueForXp', () {
      expect(ProfileService.leagueForXp(0), 'stone');
      expect(ProfileService.leagueForXp(999), 'stone');
      expect(ProfileService.leagueForXp(1000), 'forest');
      expect(ProfileService.leagueForXp(3000), 'mountain');
      expect(ProfileService.leagueForXp(7000), 'eagle');
      expect(ProfileService.leagueForXp(15000), 'noxco');
    });

    test('normalizeLeague mappe les anciennes valeurs et les inconnues', () {
      expect(ProfileService.normalizeLeague('Aigle'), 'stone');
      expect(ProfileService.normalizeLeague('Argent'), 'forest');
      expect(ProfileService.normalizeLeague('Or'), 'mountain');
      expect(ProfileService.normalizeLeague('Diamant'), 'eagle');
      expect(ProfileService.normalizeLeague('noxco'), 'noxco');
      expect(ProfileService.normalizeLeague(null), 'stone');
      expect(ProfileService.normalizeLeague('???'), 'stone');
    });
  });
}
