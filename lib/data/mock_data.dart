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
      text: 'Marşalla du! Je suis Naxçi, ton assistant IA pour apprendre le tchétchène. Comment puis-je t\'aider aujourd\'hui ?',
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

  /// Exercices de secours — servent quand la base est injoignable.
  /// La source de vérité est `public.exercises` (migration 20260915120000).
  /// Garder les deux en phase si le contenu évolue.
  static const Map<String, List<Exercise>> exercisesByLesson = {
    '1': [
      Exercise(type: ExerciseType.flashcard,
          cyrillic: 'Салам', translit: 'Salam', french: 'Salut (informel)'),
      Exercise(type: ExerciseType.flashcard,
          cyrillic: 'Баркалла', translit: 'Barkalla', french: 'Merci'),
      Exercise(
        type: ExerciseType.qcm,
        cyrillic: 'Баркалла', translit: 'Barkalla', french: 'Merci',
        prompt: 'Comment dit-on "Merci" en tchétchène ?',
        choices: ['Salam', 'Barkalla', 'Dika', 'Voŋ'],
        correctIndex: 1,
      ),
      Exercise(
        type: ExerciseType.qcm,
        cyrillic: 'Дика', translit: 'Dika', french: 'Bien / Bon',
        prompt: 'Que signifie "Dika" ?',
        choices: ['Mauvais', 'Beaucoup', 'Bien / Bon', 'Peu'],
        correctIndex: 2,
      ),
      Exercise(
        type: ExerciseType.qcm,
        cyrillic: 'Дукха', translit: 'Duqa', french: 'Beaucoup',
        prompt: 'Quel mot signifie "Beaucoup" ?',
        choices: ['K̇ezig', 'Voŋ', 'Dika', 'Duqa'],
        correctIndex: 3,
      ),
      Exercise(
        type: ExerciseType.translation,
        cyrillic: 'Баркалла дукха', translit: 'Barkalla duqa',
        french: 'Merci beaucoup',
        prompt: 'Traduis en tchétchène :\n"Merci beaucoup"',
      ),
    ],
    '2': [
      Exercise(type: ExerciseType.flashcard,
          cyrillic: 'Марша огӀийла', translit: 'Marşa oġiyla',
          french: 'Bonjour (formel)'),
      Exercise(type: ExerciseType.flashcard,
          cyrillic: 'Дела реза хуьлда', translit: 'Dela reza xülda',
          french: 'Que Dieu soit satisfait'),
      Exercise(
        type: ExerciseType.qcm,
        cyrillic: 'Марша огӀийла', translit: 'Marşa oġiyla',
        french: 'Bonjour (formel)',
        prompt: 'Quel est le bonjour formel en tchétchène ?',
        choices: ['Salam', 'Barkalla', 'Marşa oġiyla', 'Dika de'],
        correctIndex: 2,
      ),
      Exercise(
        type: ExerciseType.qcm,
        cyrillic: 'Суьйре', translit: 'Süyre', french: 'Soir',
        prompt: 'Comment dit-on "Soir" en tchétchène ?',
        choices: ['De', 'Büysa', 'Jüyre', 'Süyre'],
        correctIndex: 3,
      ),
      Exercise(
        type: ExerciseType.qcm,
        cyrillic: 'Марша огӀийла', translit: 'Marşa oġiyla',
        french: 'Entre libre (litt.)',
        prompt: 'Que signifie littéralement "Marşa oġiyla" ?',
        choices: ['Bonne journée', 'Entre libre', 'Bonne nuit', 'À bientôt'],
        correctIndex: 1,
      ),
      Exercise(
        type: ExerciseType.translation,
        cyrillic: 'Марша огӀийла', translit: 'Marşa oġiyla',
        french: 'Bonjour (formel)',
        prompt: 'Traduis en tchétchène :\n"Bonjour" (formel)',
      ),
    ],
    '3': [
      Exercise(type: ExerciseType.flashcard,
          cyrillic: 'цхьа', translit: 'cẋa', french: 'Un (1)'),
      Exercise(type: ExerciseType.flashcard,
          cyrillic: 'шиъ', translit: 'şiə', french: 'Deux (2)'),
      Exercise(
        type: ExerciseType.qcm,
        cyrillic: 'кхо', translit: 'qo', french: 'Trois (3)',
        prompt: '"Qo" signifie ?',
        choices: ['Un', 'Deux', 'Trois', 'Quatre'],
        correctIndex: 2,
      ),
      Exercise(
        type: ExerciseType.qcm,
        cyrillic: 'пхи', translit: 'pxi', french: 'Cinq (5)',
        prompt: 'Comment dit-on "5" en tchétchène ?',
        choices: ['Diə', 'Pxi', 'Yalx', 'Vorx'],
        correctIndex: 1,
      ),
      Exercise(
        type: ExerciseType.qcm,
        cyrillic: 'цхьа', translit: 'cẋa', french: 'Un (1)',
        prompt: 'Comment dit-on "1" en tchétchène ?',
        choices: ['Şiə', 'Qo', 'Cẋa', 'Diə'],
        correctIndex: 2,
      ),
      Exercise(
        type: ExerciseType.translation,
        cyrillic: 'кхо', translit: 'qo', french: 'Trois',
        prompt: 'Écris le chiffre 3 en tchétchène :',
      ),
    ],
    '4': [
      Exercise(type: ExerciseType.flashcard,
          cyrillic: 'Да', translit: 'Da', french: 'Père'),
      Exercise(type: ExerciseType.flashcard,
          cyrillic: 'Нана', translit: 'Nana', french: 'Mère'),
      Exercise(
        type: ExerciseType.qcm,
        cyrillic: 'Ваша', translit: 'Vaşa', french: 'Frère',
        prompt: 'Comment dit-on "Frère" en tchétchène ?',
        choices: ['Yişa', 'Nana', 'Vaşa', 'Da'],
        correctIndex: 2,
      ),
      Exercise(
        type: ExerciseType.qcm,
        cyrillic: 'Йиша', translit: 'Yişa', french: 'Sœur',
        prompt: '"Yişa" signifie ?',
        choices: ['Mère', 'Père', 'Frère', 'Sœur'],
        correctIndex: 3,
      ),
      Exercise(
        type: ExerciseType.qcm,
        cyrillic: 'Да', translit: 'Da', french: 'Père',
        prompt: 'Comment dit-on "Père" en tchétchène ?',
        choices: ['Nana', 'Da', 'Vaşa', 'Yişa'],
        correctIndex: 1,
      ),
      Exercise(
        type: ExerciseType.translation,
        cyrillic: 'Нана', translit: 'Nana', french: 'Mère',
        prompt: 'Traduis en tchétchène :\n"Mère"',
      ),
    ],
    '5': [
      Exercise(type: ExerciseType.flashcard,
          cyrillic: 'цӀен', translit: 'ċeŋ', french: 'Rouge'),
      Exercise(type: ExerciseType.flashcard,
          cyrillic: 'сийна', translit: 'siyna', french: 'Bleu'),
      Exercise(
        type: ExerciseType.qcm,
        cyrillic: 'цӀен', translit: 'ċeŋ', french: 'Rouge',
        prompt: 'Comment dit-on "Rouge" en tchétchène ?',
        choices: ['Siyna', 'Ċeŋ', 'K̇ayŋ', 'Bäccara'],
        correctIndex: 1,
      ),
      Exercise(
        type: ExerciseType.qcm,
        cyrillic: 'баьццара', translit: 'bäccara', french: 'Vert',
        prompt: 'Que signifie "Bäccara" ?',
        choices: ['Rouge', 'Bleu', 'Vert', 'Noir'],
        correctIndex: 2,
      ),
      Exercise(
        type: ExerciseType.qcm,
        cyrillic: 'Ӏаьржа', translit: 'Järƶa', french: 'Noir',
        prompt: 'Comment dit-on "Noir" en tchétchène ?',
        choices: ['Järƶa', 'Moƶa', 'K̇ayŋ', 'Siyna'],
        correctIndex: 0,
      ),
      Exercise(
        type: ExerciseType.translation,
        cyrillic: 'кӀайн', translit: 'k̇ayŋ', french: 'Blanc',
        prompt: 'Traduis en tchétchène :\n"Blanc"',
      ),
    ],
    '6': [
      Exercise(type: ExerciseType.flashcard,
          cyrillic: 'бепиг', translit: 'bepig', french: 'Pain'),
      Exercise(type: ExerciseType.flashcard,
          cyrillic: 'хи', translit: 'xi', french: 'Eau'),
      Exercise(
        type: ExerciseType.qcm,
        cyrillic: 'хи', translit: 'xi', french: 'Eau',
        prompt: 'Comment dit-on "Eau" en tchétchène ?',
        choices: ['Bepig', 'Xi', 'Şura', 'Tüxa'],
        correctIndex: 1,
      ),
      Exercise(
        type: ExerciseType.qcm,
        cyrillic: 'жижиг', translit: 'ƶiƶig', french: 'Viande',
        prompt: 'Que signifie "Ƶiƶig" ?',
        choices: ['Pain', 'Lait', 'Viande', 'Sel'],
        correctIndex: 2,
      ),
      Exercise(
        type: ExerciseType.qcm,
        cyrillic: 'шура', translit: 'şura', french: 'Lait',
        prompt: 'Comment dit-on "Lait" en tchétchène ?',
        choices: ['Tüxa', 'Xi', 'Şura', 'Bepig'],
        correctIndex: 2,
      ),
      Exercise(
        type: ExerciseType.translation,
        cyrillic: 'бепиг', translit: 'bepig', french: 'Pain',
        prompt: 'Traduis en tchétchène :\n"Pain"',
      ),
    ],
  };

  static const weeklyXP = [120, 340, 180, 560, 290, 420, 180];
  static const weekDays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
}
