import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../data/mock_data.dart';
import 'notification_service.dart';
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

  /// Sauvegarde une progression partielle (sortie en cours de leçon).
  /// Ne touche ni à l'XP ni au statut « terminé », et ne régresse jamais
  /// une progression existante.
  static Future<void> saveProgress({
    required String lessonId,
    required int completedExercises,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null || completedExercises <= 0) return;
    try {
      final prev = await _client
          .from('lesson_progress')
          .select('completed, completed_exercises')
          .eq('user_id', user.id)
          .eq('lesson_id', lessonId)
          .maybeSingle();
      if (prev?['completed'] as bool? ?? false) return;
      final prevCount = prev?['completed_exercises'] as int? ?? 0;
      if (completedExercises <= prevCount) return;

      await _client.from('lesson_progress').upsert({
        'user_id': user.id,
        'lesson_id': lessonId,
        'completed_exercises': completedExercises,
        'completed': false,
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Une sortie en cours de leçon reste une activité du jour.
      await ProfileService.updateStreak();
      // Le rappel du jour devient inutile — best-effort, non bloquant.
      unawaited(NotificationService.sync(lastActivity: DateTime.now())
          .catchError((_) {}));
    } catch (_) {
      // Hors-ligne : repli silencieux, cohérent avec le reste du service.
    }
  }

  /// Termine une leçon via la fonction serveur `complete_lesson` : marque la
  /// leçon terminée, crédite l'XP de la leçon (`lessons.xp_reward`, **une
  /// seule fois**), recalcule niveau/ligue et le compteur de leçons — le tout
  /// en une transaction. Le client n'envoie aucun montant.
  ///
  /// Renvoie `null` si l'opération a échoué (hors-ligne…) : la base est alors
  /// restée inchangée, donc l'UI peut proposer de réessayer sans risque de
  /// double XP ni de leçon « terminée » sans XP.
  static Future<LessonCompletion?> completeLesson({
    required String lessonId,
  }) async {
    if (_client.auth.currentUser == null) return null;
    try {
      // Activité du jour → met à jour la série. Avant l'XP : la complétion
      // réécrit `last_activity`, qui sert de référence au calcul de série.
      // Idempotent dans la même journée, donc sûr à rejouer lors d'une relance.
      await ProfileService.updateStreak();
      final data = await _client
          .rpc('complete_lesson', params: {'p_lesson_id': lessonId});
      // Le rappel du jour devient inutile — best-effort, non bloquant.
      unawaited(NotificationService.sync(lastActivity: DateTime.now())
          .catchError((_) {}));
      return LessonCompletion.fromRpc(data);
    } catch (_) {
      return null;
    }
  }
}

/// Résultat de [LessonService.completeLesson] : ce que le serveur a
/// réellement crédité (et non ce que le client croit avoir gagné).
class LessonCompletion {
  /// XP crédité par cet appel. 0 si la leçon était déjà terminée (révision).
  final int xpAwarded;

  /// `true` si la leçon avait déjà été terminée auparavant.
  final bool alreadyCompleted;

  const LessonCompletion({
    required this.xpAwarded,
    required this.alreadyCompleted,
  });

  /// Lit la réponse JSON de `complete_lesson`. Tolérant : l'appel a réussi
  /// côté serveur, une forme de réponse inattendue ne doit pas passer pour
  /// un échec (et déclencher une relance inutile).
  factory LessonCompletion.fromRpc(dynamic data) {
    if (data is! Map) {
      return const LessonCompletion(xpAwarded: 0, alreadyCompleted: false);
    }
    return LessonCompletion(
      xpAwarded: (data['xp_awarded'] as num?)?.toInt() ?? 0,
      alreadyCompleted: data['already_completed'] as bool? ?? false,
    );
  }
}
