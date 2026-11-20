/// Normalisation de texte pour COMPARER (jamais pour afficher).
///
/// Partagée par la vérification des réponses tapées et la recherche du
/// dictionnaire : un apprenant sans clavier tchétchène doit retrouver
/// « k̇ayŋ » en tapant « kayn », et « Ӏаьржа » en tapant « 1аьржа ».
abstract final class TextFold {
  static const _latinFolds = {
    'ş': 's', 'ẋ': 'x', 'ç': 'c', 'ġ': 'g', 'ŋ': 'n', 'ƶ': 'z', 'ċ': 'c',
    'ü': 'u', 'ö': 'o', 'ä': 'a', 'ə': 'e',
    'ʔ': '', 'ʼ': '', 'ʻ': '', '\'': '', '`': '',
  };

  /// Variantes du palochka tapées faute de mieux (I latin, l, chiffre 1,
  /// minuscule ӏ) ramenées à une seule forme.
  static const _palochkaVariants = ['Ӏ', 'ӏ', 'I', 'l', '1', '|'];

  /// Minuscules, sans diacritiques, espaces réduits.
  static String fold(String s) {
    var out = s.trim().toLowerCase();
    _latinFolds.forEach((k, v) => out = out.replaceAll(k, v));
    // Diacritiques combinants (point suscrit de k̇, q̇, ṫ…).
    out = out.replaceAll(RegExp('[̀-ͯ]'), '');
    return out.replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Comme [fold], plus les variantes du palochka unifiées — seulement si
  /// le texte contient du cyrillique (sinon « l » et « 1 » restent eux-mêmes).
  static String foldCyrillic(String s) {
    var out = s.trim();
    if (!RegExp('[Ѐ-ӿ]').hasMatch(out)) return fold(out);
    for (final v in _palochkaVariants) {
      out = out.replaceAll(v, 'ӏ');
    }
    return fold(out);
  }
}
