import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../data/mock_data.dart';
import 'profile_service.dart';

/// Gère le catalogue de leçons (Supabase) et la progression par utilisateur.
class LessonService {
  static final _client = Supabase.instance.client;

  /// Charge le catalogue + la progression de l'utilisateur et calcule le
  /// statut de chaque leçon. Déblocage **séquentiel** : la première leçon
  /// non terminée est « active », les suivantes sont « verrouillées ».
  ///
  /// Repli sur [MockData.lessons] si la base est indisponible/vide.
  static Future<List<LessonModel>> fetchLessons() async {
    final user = _client.auth.currentUser;
    try {
      final rows = await _client
          .from('lessons')
          .select()
          .order('sort_order', ascending: true);
      final lessons = rows as List;
      if (lessons.isEmpty) return List.from(MockData.lessons);

      // Progression de l'utilisateur
      final progress = <String, Map<String, dynamic>>{};
      if (user != null) {
        final pr = await _client
            .from('lesson_progress')
            .select()
            .eq('user_id', user.id);
        for (final r in (pr as List)) {
          progress[r['lesson_id'] as String] = r as Map<String, dynamic>;
        }
      }

      var activeAssigned = false;
      final result = <LessonModel>[];
      for (final l in lessons) {
        final id = l['id'] as String;
        final total = l['total_exercises'] as int? ?? 6;
        final p = progress[id];
        final done = p?['completed'] as bool? ?? false;
        final doneEx = p?['completed_exercises'] as int? ?? 0;

        LessonStatus status;
        if (done) {
          status = LessonStatus.completed;
        } else if (!activeAssigned) {
          status = LessonStatus.active;
          activeAssigned = true;
        } else {
          status = LessonStatus.locked;
        }

        result.add(LessonModel(
          id: id,
          title: l['title'] as String,
          subtitle: l['subtitle'] as String,
          icon: l['icon'] as String,
          status: status,
          xpReward: l['xp_reward'] as int? ?? 50,
          totalExercises: total,
          completedExercises: done ? total : doneEx,
        ));
      }
      return result;
    } catch (_) {
      return List.from(MockData.lessons);
    }
  }

  /// Enregistre la complétion d'une leçon, ajoute l'XP (une seule fois) et
  /// met à jour le compteur de leçons terminées du profil.
  static Future<void> completeLesson({
    required String lessonId,
    required int completedExercises,
    required int totalExercises,
    required int xpEarned,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    final isCompleted = completedExercises >= totalExercises;

    try {
      // État précédent (pour ne pas redonner d'XP si déjà terminée)
      final prev = await _client
          .from('lesson_progress')
          .select('completed')
          .eq('user_id', user.id)
          .eq('lesson_id', lessonId)
          .maybeSingle();
      final wasCompleted = prev?['completed'] as bool? ?? false;

      await _client.from('lesson_progress').upsert({
        'user_id': user.id,
        'lesson_id': lessonId,
        'completed_exercises': completedExercises,
        'completed': isCompleted,
        'updated_at': DateTime.now().toIso8601String(),
      });

      if (isCompleted && !wasCompleted) {
        await ProfileService.addXP(xpEarned);
      }

      // Recompte les leçons terminées
      final completedRows = await _client
          .from('lesson_progress')
          .select('lesson_id')
          .eq('user_id', user.id)
          .eq('completed', true);
      await _client
          .from('profiles')
          .update({'lessons_completed': (completedRows as List).length})
          .eq('id', user.id);
    } catch (_) {
      // Repli silencieux : au pire, l'XP du profil est tout de même ajouté
      if (isCompleted) await ProfileService.addXP(xpEarned);
    }
  }
}
