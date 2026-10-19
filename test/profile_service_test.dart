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

  group('ProfileService.leaderboardFromRows', () {
    test('conserve rang, XP et « c\'est moi » tels que fournis par le serveur',
        () {
      final list = ProfileService.leaderboardFromRows([
        {'rank': 1, 'user_id': 'a', 'username': 'Aïcha', 'xp': 4120, 'is_me': false},
        {'rank': 2, 'user_id': 'b', 'username': 'moi', 'xp': 2847, 'is_me': true},
      ]);
      expect(list.map((u) => u.rank), [1, 2]);
      expect(list.map((u) => u.xp), [4120, 2847]);
      expect(list.map((u) => u.isCurrentUser), [false, true]);
      expect(list.first.avatarInitials, 'A');
    });

    test('joueur hors du top : sa ligne arrive avec son vrai rang', () {
      // Le serveur ajoute la ligne de l'appelant après le top, rang réel (57).
      final list = ProfileService.leaderboardFromRows([
        {'rank': 1, 'username': 'a', 'xp': 900, 'is_me': false},
        {'rank': 57, 'username': 'moi', 'xp': 12, 'is_me': true},
      ]);
      expect(list.last.rank, 57);
      expect(list.last.isCurrentUser, isTrue);
      expect(list.where((u) => u.isCurrentUser), hasLength(1));
    });

    test('la couleur d\'avatar est stable pour un même rang', () {
      final a = ProfileService.leaderboardFromRows([
        {'rank': 3, 'username': 'x', 'xp': 1, 'is_me': false},
      ]).single;
      final b = ProfileService.leaderboardFromRows([
        {'rank': 3, 'username': 'y', 'xp': 9, 'is_me': true},
      ]).single;
      expect(a.avatarColor, b.avatarColor);
    });

    test('entrées dégradées : pas de crash, valeurs par défaut', () {
      expect(ProfileService.leaderboardFromRows(null), isEmpty);
      expect(ProfileService.leaderboardFromRows('ko'), isEmpty);
      expect(ProfileService.leaderboardFromRows(<dynamic>[]), isEmpty);

      final list = ProfileService.leaderboardFromRows([
        'pas une map',
        {'rank': 5, 'xp': 7.0}, // username absent, xp flottant
        {'username': ''}, // rank/xp absents, nom vide
      ]);
      expect(list, hasLength(2));
      expect(list[0].name, 'Apprenant');
      expect(list[0].xp, 7);
      expect(list[0].isCurrentUser, isFalse);
      expect(list[1].avatarInitials, 'A');
      expect(list[1].rank, 0);
    });
  });
}
