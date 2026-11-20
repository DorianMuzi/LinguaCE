import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/models.dart';
import 'text_fold.dart';

/// Accès au lexique commun (LinguaCE Core) et recherche du dictionnaire.
///
/// v0 : le lexique tient en mémoire (quelques dizaines de mots) ; il est
/// chargé une fois puis filtré localement, ce qui rend la recherche
/// instantanée et utilisable hors-ligne après le premier chargement. Quand
/// il grossira, la recherche passera côté serveur (index de préfixe déjà
/// créés sur `lexemes`).
class LexiconService {
  static List<Lexeme>? _cache;

  /// Colonnes publiques uniquement : les autres ne sont pas lisibles.
  static const _columns =
      'id, cyrillic, latin, sense, pos, noun_class, translations, audio_url';

  /// Mots validés, triés par latin. Lève une exception en cas d'échec
  /// réseau (l'écran propose alors de réessayer).
  static Future<List<Lexeme>> fetchAll({bool refresh = false}) async {
    if (_cache != null && !refresh) return _cache!;
    final rows = await Supabase.instance.client
        .from('lexemes')
        .select(_columns)
        .order('latin')
        .limit(2000);
    _cache = [
      for (final r in rows as List)
        if (Lexeme.fromRow(r as Map<String, dynamic>) case final l?) l,
    ];
    return _cache!;
  }

  /// Filtre [all] selon [query] : latin (sans diacritiques), cyrillique
  /// (variantes du palochka acceptées) et traductions dans [lang] (+ FR).
  /// Classement : correspondance exacte, puis début de mot, puis le reste ;
  /// à égalité, ordre alphabétique latin. Requête vide → tout le lexique.
  static List<Lexeme> search(List<Lexeme> all, String query, String lang) {
    final q = TextFold.foldCyrillic(query);
    if (q.isEmpty) {
      return [...all]..sort((a, b) => a.latin.compareTo(b.latin));
    }

    int? rank(Lexeme l) {
      final fields = <String>[
        TextFold.fold(l.latin),
        TextFold.foldCyrillic(l.cyrillic),
        for (final t in {...l.translationsFor(lang), ...?l.translations['FR']})
          TextFold.fold(t),
      ];
      int? best;
      for (final f in fields) {
        final r = f == q
            ? 0
            : f.startsWith(q) || f.split(RegExp(r'[\s/(),]+')).any((w) => w.startsWith(q))
                ? 1
                : f.contains(q)
                    ? 2
                    : null;
        if (r != null && (best == null || r < best)) best = r;
      }
      return best;
    }

    final scored = [
      for (final l in all)
        if (rank(l) case final r?) (l, r),
    ]..sort((a, b) {
        final c = a.$2.compareTo(b.$2);
        return c != 0 ? c : a.$1.latin.compareTo(b.$1.latin);
      });
    return [for (final (l, _) in scored) l];
  }
}
