import 'package:supabase_flutter/supabase_flutter.dart';

/// Client de translittération cyrillique tchétchène → latin.
///
/// L'algorithme (système 1992) est **propriétaire** et vit côté serveur dans
/// une Edge Function Supabase (`transliterate`). Ce client ne fait qu'appeler
/// l'API : aucune règle n'est exposée dans le code public.
class TransliterationService {
  static const _functionName = 'transliterate';

  /// Renvoie la translittération de [text], ou une chaîne vide en cas
  /// d'échec (fonction non déployée, hors-ligne…) — dégradation silencieuse.
  static Future<String> transliterate(String text) async {
    if (text.trim().isEmpty) return '';
    try {
      final res = await Supabase.instance.client.functions.invoke(
        _functionName,
        body: {'text': text},
      );
      final data = res.data;
      if (data is Map && data['result'] is String) {
        return data['result'] as String;
      }
      return '';
    } catch (_) {
      return '';
    }
  }
}
