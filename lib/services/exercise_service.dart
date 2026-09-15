import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/mock_data.dart';
import '../models/models.dart';

/// Charge le contenu pédagogique d'une leçon.
///
/// La source de vérité est la table `public.exercises` : le contenu s'enrichit
/// sans recompiler l'app. `MockData.exercisesByLesson` sert de secours quand
/// la base est injoignable — même patron que [LessonService.fetchLessons].
class ExerciseService {
  static final _client = Supabase.instance.client;

  /// Exercices de [lessonId], dans l'ordre d'affichage.
  ///
  /// Renvoie une liste vide si la leçon n'a pas encore de contenu — c'est un
  /// état légitime que l'écran doit savoir présenter, pas une erreur.
  static Future<List<Exercise>> fetchForLesson(String lessonId) async {
    try {
      final rows = await _client
          .from('exercises')
          .select()
          .eq('lesson_id', lessonId)
          .order('sort_order', ascending: true);

      final list = (rows as List)
          .map((r) => Exercise.fromRow(r as Map<String, dynamic>))
          .whereType<Exercise>() // écarte les lignes mal formées
          .toList();

      // Base joignable mais leçon vide : on tente le secours, qui peut
      // contenir cette leçon si la migration n'a pas encore été appliquée.
      if (list.isEmpty) return _fallback(lessonId);
      return list;
    } catch (_) {
      return _fallback(lessonId);
    }
  }

  static List<Exercise> _fallback(String lessonId) =>
      List.of(MockData.exercisesByLesson[lessonId] ?? const <Exercise>[]);
}
