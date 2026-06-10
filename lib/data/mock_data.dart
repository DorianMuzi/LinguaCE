import 'package:flutter/material.dart';
import '../models/models.dart';

class MockData {
  static const user = UserModel(
    name: 'Dorian',
    level: 4,
    xp: 2847,
    xpToNext: 3500,
    streak: 12,
    avatarInitials: 'D',
    league: 'stone',
  );

  static const lessons = [
    LessonModel(
      id: '1',
      title: 'Premiers Mots',
      subtitle: 'Vocabulaire de base',
      icon: '🌱',
      status: LessonStatus.completed,
      xpReward: 100,
      totalExercises: 10,
      completedExercises: 10,
    ),
    LessonModel(
      id: '2',
      title: 'Salutations',
      subtitle: 'Bonjour, au revoir...',
      icon: '👋',
      status: LessonStatus.completed,
      xpReward: 150,
      totalExercises: 12,
      completedExercises: 12,
    ),
    LessonModel(
      id: '3',
      title: 'Chiffres & Nombres',
      subtitle: 'De 1 à 100',
      icon: '🔢',
      status: LessonStatus.active,
      xpReward: 200,
      totalExercises: 15,
      completedExercises: 7,
    ),
    LessonModel(
      id: '4',
      title: 'La Famille',
      subtitle: 'Mère, père, frère...',
      icon: '👨‍👩‍👧',
      status: LessonStatus.locked,
      xpReward: 250,
      totalExercises: 18,
      completedExercises: 0,
    ),
    LessonModel(
      id: '5',
      title: 'Les Couleurs',
      subtitle: 'Rouge, bleu, vert...',
      icon: '🎨',
      status: LessonStatus.locked,
      xpReward: 300,
      totalExercises: 6,
      completedExercises: 0,
    ),
    LessonModel(
      id: '6',
      title: 'La Nourriture',
      subtitle: 'Pain, eau, viande...',
      icon: '🍽️',
      status: LessonStatus.locked,
      xpReward: 350,
      totalExercises: 6,
      completedExercises: 0,
    ),
  ];

  static const leagueUsers = [
    LeagueUser(
      name: 'Aïcha',
      avatarInitials: 'A',
      avatarColor: Color(0xFF7C3AED),
      xp: 4120,
      rank: 1,
      isCurrentUser: false,
    ),
    LeagueUser(
      name: 'Dorian',
      avatarInitials: 'D',
      avatarColor: Color(0xFFC4922A),
      xp: 2847,
      rank: 2,
      isCurrentUser: true,
    ),
    LeagueUser(
      name: 'Rustam',
      avatarInitials: 'R',
      avatarColor: Color(0xFF0891B2),
      xp: 2310,
      rank: 3,
      isCurrentUser: false,
    ),
    LeagueUser(
      name: 'Leia',
      avatarInitials: 'L',
      avatarColor: Color(0xFFBE185D),
      xp: 1890,
      rank: 4,
      isCurrentUser: false,
    ),
  ];

  static final initialMessages = [
    ChatMessage(
      text: 'Marşalla du! Je suis Noxçi, ton assistant IA pour apprendre le tchétchène. Comment puis-je t\'aider aujourd\'hui ?',
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];

  static const quickActions = [
    {'icon': '💬', 'label': 'Chat IA', 'tab': 1},
    {'icon': '📚', 'label': 'Leçons', 'tab': 2},
    {'icon': '📊', 'label': 'Progrès', 'tab': 3},
  ];

  static const aiResponses = [
    'En tchétchène, on dit "Маршалла хаттар" (Marşalla xattar) pour demander "Comment vas-tu ?"',
    'Le mot "доттагӀалла" (dottaġalla) signifie "amitié" en tchétchène.',
    'Pour dire "merci" en tchétchène, on utilise "баркалла" (barkalla).',
    'Le tchétchène est une langue nakh-daghestanaise avec environ 1,5 million de locuteurs.',
    'Le verbe "хаа" (xaa) signifie "savoir" ou "connaître" en tchétchène.',
  ];

  static const weeklyXP = [120, 340, 180, 560, 290, 420, 180];
  static const weekDays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
}
