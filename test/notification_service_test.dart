import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_ce/services/notification_service.dart';

/// L'essentiel de NotificationService dépend du plugin natif
/// (non mockable simplement en test unitaire) : ces tests couvrent le
/// schéma d'identifiants déterministe, qui est de la logique pure.
void main() {
  group('NotificationService.idForDate', () {
    test('encode AAAAMMJJ', () {
      expect(NotificationService.idForDate(DateTime(2026, 9, 17)), 20260917);
      expect(NotificationService.idForDate(DateTime(2026, 1, 1)), 20260101);
    });

    test('reste unique et croissant au passage d\'un mois', () {
      final aug31 = NotificationService.idForDate(DateTime(2026, 8, 31));
      final sep1 = NotificationService.idForDate(DateTime(2026, 9, 1));
      expect(sep1, greaterThan(aug31));
    });

    test('reste unique et croissant au passage d\'une année', () {
      final dec31 = NotificationService.idForDate(DateTime(2026, 12, 31));
      final jan1 = NotificationService.idForDate(DateTime(2027, 1, 1));
      expect(jan1, greaterThan(dec31));
    });

    test('deux dates distinctes ne collisionnent jamais sur une fenêtre de 14 jours', () {
      final start = DateTime(2026, 2, 25); // à cheval sur une fin de mois
      final ids = List.generate(
        14,
        (i) => NotificationService.idForDate(start.add(Duration(days: i))),
      );
      expect(ids.toSet().length, 14);
    });
  });

  group('NotificationService.isReminderId', () {
    test('reconnaît un identifiant de rappel', () {
      expect(NotificationService.isReminderId(20260917), isTrue);
    });

    test('rejette un identifiant hors de la plage plausible', () {
      expect(NotificationService.isReminderId(0), isFalse);
      expect(NotificationService.isReminderId(1), isFalse);
      expect(NotificationService.isReminderId(99999999999), isFalse);
    });
  });
}
