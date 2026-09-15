import 'package:flutter/material.dart';

class UserModel {
  final String name;
  final int level;
  final int xp;
  final int xpToNext;
  final int streak;
  final String avatarInitials;
  final String league;

  const UserModel({
    required this.name,
    required this.level,
    required this.xp,
    required this.xpToNext,
    required this.streak,
    required this.avatarInitials,
    required this.league,
  });

  double get xpProgress => xp / xpToNext;
}

enum LessonStatus { completed, active, locked }

class LessonModel {
  final String id;
  final String title;
  final String subtitle;
  final String icon;
  final LessonStatus status;
  final int xpReward;
  final int totalExercises;
  final int completedExercises;

  const LessonModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.status,
    required this.xpReward,
    required this.totalExercises,
    required this.completedExercises,
  });

  double get progress =>
      totalExercises > 0 ? completedExercises / totalExercises : 0;
}

enum ExerciseType { flashcard, qcm, translation }

/// Un exercice d'une leçon. Vit en base (`public.exercises`) ; `MockData`
/// en fournit un jeu de secours hors-ligne.
class Exercise {
  final ExerciseType type;
  final String cyrillic;
  final String translit;
  final String french;

  /// Consigne affichée — nulle pour une flashcard.
  final String? prompt;

  /// QCM uniquement : propositions et index (0-based) de la bonne réponse.
  final List<String>? choices;
  final int? correctIndex;

  const Exercise({
    required this.type,
    required this.cyrillic,
    required this.translit,
    required this.french,
    this.prompt,
    this.choices,
    this.correctIndex,
  });

  /// Construit un exercice depuis une ligne Supabase.
  /// Renvoie `null` si la ligne est inexploitable — mieux vaut sauter un
  /// exercice mal formé que planter la leçon entière.
  static Exercise? fromRow(Map<String, dynamic> r) {
    final type = switch (r['type'] as String?) {
      'flashcard' => ExerciseType.flashcard,
      'qcm' => ExerciseType.qcm,
      'translation' => ExerciseType.translation,
      _ => null,
    };
    if (type == null) return null;

    final cyrillic = r['cyrillic'] as String?;
    final translit = r['translit'] as String?;
    final french = r['french'] as String?;
    if (cyrillic == null || translit == null || french == null) return null;

    List<String>? choices;
    final raw = r['choices'];
    if (raw is List) choices = raw.whereType<String>().toList();

    final correctIndex = r['correct_index'] as int?;

    // Un QCM sans propositions valides serait injouable.
    if (type == ExerciseType.qcm) {
      if (choices == null ||
          choices.isEmpty ||
          correctIndex == null ||
          correctIndex < 0 ||
          correctIndex >= choices.length) {
        return null;
      }
    }

    return Exercise(
      type: type,
      cyrillic: cyrillic,
      translit: translit,
      french: french,
      prompt: r['prompt'] as String?,
      choices: choices,
      correctIndex: correctIndex,
    );
  }
}

class LeagueUser {
  final String name;
  final String avatarInitials;
  final Color avatarColor;
  final int xp;
  final int rank;
  final bool isCurrentUser;

  const LeagueUser({
    required this.name,
    required this.avatarInitials,
    required this.avatarColor,
    required this.xp,
    required this.rank,
    required this.isCurrentUser,
  });
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
