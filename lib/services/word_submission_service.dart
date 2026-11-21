import 'package:supabase_flutter/supabase_flutter.dart';

import '../i18n/locale_controller.dart';

/// Mots proposés par les utilisateurs (table `word_submissions`).
///
/// Chaque proposition est relue par l'auteur avant d'entrer dans le lexique
/// du Core : rien n'est montré aux autres sans cette validation. Le serveur
/// borne tout (longueurs, 30 propositions par jour) ; le client vérifie la
/// forme pour donner un message clair avant l'envoi.
class WordSubmissionService {
  WordSubmissionService._();

  static const maxForm = 80;
  static const maxMeaning = 200;
  static const maxNote = 500;

  static final _cyrillic = RegExp('[Ѐ-ӿ]');
  static final _latinLetter = RegExp('[A-Za-z]');

  /// Clé i18n de l'erreur, ou `null` si la proposition est recevable.
  static String? validate({
    required String cyrillic,
    required String latin,
    required String meaning,
  }) {
    final c = cyrillic.trim(), l = latin.trim(), m = meaning.trim();
    if ((c.isEmpty && l.isEmpty) || m.isEmpty) return 'submit.err_form';
    // Le palotchka tapé « I » ou « 1 » est toléré dans le champ cyrillique.
    if (c.isNotEmpty &&
        (!_cyrillic.hasMatch(c) ||
            _latinLetter.hasMatch(c.replaceAll(RegExp('[Il1]'), '')))) {
      return 'submit.err_cyrillic';
    }
    if (l.isNotEmpty && _cyrillic.hasMatch(l)) return 'submit.err_latin';
    return null;
  }

  /// Ligne à insérer. Exposée pour les tests : aucune dépendance réseau.
  static Map<String, dynamic> buildRow({
    required String cyrillic,
    required String latin,
    required String meaning,
    String note = '',
    required String language,
  }) {
    String cap(String s, int n) => s.length <= n ? s : s.substring(0, n);
    final c = cyrillic.trim(), l = latin.trim(), n = note.trim();
    return {
      if (c.isNotEmpty) 'cyrillic': cap(c, maxForm),
      if (l.isNotEmpty) 'latin': cap(l, maxForm),
      'meaning': cap(meaning.trim(), maxMeaning),
      'meaning_lang': language,
      if (n.isNotEmpty) 'note': cap(n, maxNote),
    };
  }

  /// Envoie la proposition. `false` en cas d'échec (hors-ligne, non connecté,
  /// limite quotidienne atteinte…) pour que l'écran le dise.
  static Future<bool> submit({
    required String cyrillic,
    required String latin,
    required String meaning,
    String note = '',
  }) async {
    final client = Supabase.instance.client;
    if (client.auth.currentUser == null) return false;
    try {
      await client.from('word_submissions').insert(buildRow(
            cyrillic: cyrillic,
            latin: latin,
            meaning: meaning,
            note: note,
            language: localeController.value,
          ));
      return true;
    } catch (_) {
      return false;
    }
  }
}
