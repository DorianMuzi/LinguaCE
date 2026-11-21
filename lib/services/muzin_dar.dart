/// L'alphabet latin tchétchène (Muziŋ Darr), tel que le définit la
/// spécification du Core (spec/alphabet.md, dépôt privé) : 41 lettres, ordre
/// validé par l'auteur le 2026-11-21.
///
/// Ce fichier n'en reprend que l'inventaire public — les lettres, leur ordre,
/// leurs majuscules —, jamais les règles de translittération.
///
/// Encodage : NFC. ç̇, k̇ et q̇ n'existent pas en un seul caractère Unicode :
/// lettre de base + U+0307 (point en chef combinant).
abstract final class MuzinDar {
  static const dot = '̇';

  /// Les 41 lettres, dans l'ordre alphabétique.
  static const letters = [
    'a', 'ä', 'b', 'c', 'ċ', 'ç', 'ç$dot', 'd', 'e', 'ə', 'f', 'g', 'ġ', 'h', //
    'i', 'j', 'k', 'k$dot', 'l', 'm', 'n', 'ŋ', 'o', 'ö', 'p', 'ṗ', 'q', //
    'q$dot', 'r', 's', 'ş', 't', 'ṫ', 'u', 'ü', 'v', 'x', 'ẋ', 'y', 'z', 'ƶ',
  ];

  /// Les lettres absentes d'un clavier latin ordinaire (barre de lettres).
  static final special = [
    for (final l in letters)
      if (l.runes.any((r) => r > 0x7F)) l,
  ];

  /// Majuscule d'une lettre (ç̇ → Ç̇ : seule la lettre de base change).
  static String upper(String letter) => letter.toUpperCase();

  // ─── Ordre alphabétique ────────────────────────────────────
  static final Map<String, int> _rank = {
    for (var i = 0; i < letters.length; i++) letters[i]: i,
  };

  /// Accent tonique et longueur : ignorés par le tri (spec § 3).
  static const _marks = {
    'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u', 'ý': 'y',
    'ā': 'a', 'ī': 'i', 'ū': 'u', 'ȫ': 'ö', 'ǖ': 'ü', 'ǘ': 'ü',
  };

  /// Clé de tri : un rang par lettre (ç̇ compte pour une seule lettre).
  /// Séparateurs avant chiffres, chiffres avant lettres, inconnus après.
  static List<int> sortKey(String s) {
    var t = s.toLowerCase();
    _marks.forEach((k, v) => t = t.replaceAll(k, v));
    t = t.replaceAll(RegExp('[́̄]'), '');

    final key = <int>[];
    for (var i = 0; i < t.length; i++) {
      final c = t[i];
      if (i + 1 < t.length && t[i + 1] == dot && _rank.containsKey('$c$dot')) {
        key.add(100 + _rank['$c$dot']!);
        i++;
      } else if (_rank[c] case final r?) {
        key.add(100 + r);
      } else if (RegExp(r'[0-9]').hasMatch(c)) {
        key.add(10 + int.parse(c));
      } else if (RegExp(r'[\s\-,.?!…«»()]').hasMatch(c)) {
        key.add(1);
      } else {
        key.add(1000 + c.codeUnitAt(0));
      }
    }
    return key;
  }

  /// Compare deux textes latins selon l'ordre de l'alphabet (et non selon
  /// les points de code, qui rangeraient ẋ après y).
  static int compare(String a, String b) {
    final ka = sortKey(a), kb = sortKey(b);
    for (var i = 0; i < ka.length && i < kb.length; i++) {
      if (ka[i] != kb[i]) return ka[i].compareTo(kb[i]);
    }
    final byLength = ka.length.compareTo(kb.length);
    return byLength != 0 ? byLength : a.compareTo(b);
  }
}
