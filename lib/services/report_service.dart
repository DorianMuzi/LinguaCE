import 'package:supabase_flutter/supabase_flutter.dart';

import '../i18n/locale_controller.dart';
import '../models/models.dart';

/// Ce que l'apprenant signale comme fautif.
enum ReportCategory {
  translit,
  translation,
  other;

  /// Valeur stockée en base (cf. contrainte `category` de content_reports).
  String get key => name;
}

/// Signalements d'erreurs de contenu (table `content_reports`).
///
/// Le serveur borne tout (longueurs, catégories, 30 signalements par jour et
/// par utilisateur) : le client ne fait que tronquer pour rester sous les
/// limites et éviter un refus inutile.
class ReportService {
  ReportService._();

  static const maxComment = 1000;

  /// Ligne à insérer. Exposée pour les tests : aucune dépendance réseau.
  static Map<String, dynamic> buildRow({
    required String lessonId,
    required int position,
    required Exercise exercise,
    required ReportCategory category,
    String? comment,
    String? language,
  }) {
    String cap(String s, int n) => s.length <= n ? s : s.substring(0, n);
    final trimmed = comment?.trim() ?? '';
    return {
      'lesson_id': lessonId,
      'exercise_position': position,
      'exercise_type': exercise.type.name,
      'cyrillic': cap(exercise.cyrillic, 500),
      'translit': cap(exercise.translit, 500),
      'french': cap(exercise.french, 500),
      'category': category.key,
      if (trimmed.isNotEmpty) 'comment': cap(trimmed, maxComment),
      if (language != null) 'interface_language': cap(language, 8),
    };
  }

  /// Envoie le signalement. Renvoie `false` en cas d'échec (hors-ligne,
  /// non connecté, limite quotidienne atteinte…) pour que l'UI le dise.
  static Future<bool> submit({
    required String lessonId,
    required int position,
    required Exercise exercise,
    required ReportCategory category,
    String? comment,
  }) async {
    final client = Supabase.instance.client;
    if (client.auth.currentUser == null) return false;
    try {
      await client.from('content_reports').insert(buildRow(
            lessonId: lessonId,
            position: position,
            exercise: exercise,
            category: category,
            comment: comment,
            language: localeController.value,
          ));
      return true;
    } catch (_) {
      return false;
    }
  }
}
