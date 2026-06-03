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
