import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_ce/i18n/app_strings.dart';

/// L'interface CE est en latin Muziŋ Dar : aucun caractère cyrillique, et
/// les textes longs ont désormais leur version CE (plus de repli sur le FR).
void main() {
  final cyrillic = RegExp(r'[Ѐ-ӿ]');

  test('aucun texte CE ne contient de cyrillique', () {
    final offenders = <String>[
      for (final e in debugAppStrings.entries)
        if (cyrillic.hasMatch(e.value['CE'] ?? '')) e.key,
    ];
    expect(offenders, isEmpty);
  });

  test('Confidentialité et Aide ont une version CE', () {
    for (final key in ['set.privacy_body', 'set.help_body']) {
      final entry = debugAppStrings[key]!;
      expect(entry['CE'], isNotNull, reason: key);
      expect(entry['CE'], isNot(entry['FR']), reason: key);
      expect(entry['CE'], contains('discord.gg/fnPmjfttc'), reason: key);
    }
  });
}
