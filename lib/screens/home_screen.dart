import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../design/lingua_components.dart';
import '../design/lingua_scale.dart';
import '../design/lingua_tokens.dart';
import '../design/responsive.dart';
import '../i18n/app_strings.dart';
import '../i18n/locale_controller.dart';
import '../models/models.dart';
import '../services/lesson_service.dart';
import '../services/profile_service.dart';
import '../widgets/xp_bar.dart';
import 'chat_screen.dart' show chatDraft;
import 'exercise_screen.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<int> onTabChange;

  /// Notifié à chaque retour sur l'onglet : re-télécharge les données en
  /// gardant les valeurs affichées (pas de skeleton après le 1er chargement).
  final Listenable? refresh;

  const HomeScreen({super.key, required this.onTabChange, this.refresh});

  /// Jour civil courant, compté depuis le 1ᵉʳ janvier 2026 : sert aux
  /// rotations quotidiennes (mot du jour, leçon à réviser).
  static int dayIndex([DateTime? now]) =>
      (now ?? DateTime.now()).difference(DateTime(2026)).inDays;

  /// Leçon à reprendre : celle en cours, sinon la première non terminée,
  /// sinon la première (tout est fini → on révise).
  static LessonModel? currentLesson(List<LessonModel> lessons) {
    if (lessons.isEmpty) return null;
    return lessons.firstWhere(
      (l) => l.status == LessonStatus.active,
      orElse: () => lessons.firstWhere(
        (l) => l.status != LessonStatus.completed,
        orElse: () => lessons.first,
      ),
    );
  }

  /// Leçon à réviser : une leçon terminée, différente chaque jour.
  /// `null` tant qu'aucune leçon n'est terminée.
  static LessonModel? reviewLesson(List<LessonModel> lessons, int day) {
    final done =
        lessons.where((l) => l.status == LessonStatus.completed).toList();
    if (done.isEmpty) return null;
    return done[day % done.length];
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _profile;
  List<LessonModel> _lessons = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    widget.refresh?.addListener(_reload);
    _reload();
  }

  @override
  void dispose() {
    widget.refresh?.removeListener(_reload);
    super.dispose();
  }

  void _reload() {
    _loadProfile();
    _loadLessons();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ProfileService.getOrCreateProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadLessons() async {
    final lessons = await LessonService.fetchLessons();
    if (mounted) setState(() => _lessons = lessons);
  }

  /// Ouvre directement les exercices d'une leçon (un tap, pas de détour par
  /// l'onglet Leçons), puis rafraîchit XP, série et progression au retour.
  Future<void> _openLesson(LessonModel lesson) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ExerciseScreen(lesson: lesson)),
    );
    if (mounted) _reload();
  }

  /// Ouvre le chat avec une question sur le mot du jour déjà saisie.
  void _practiceWord() {
    final w = _wordOfDay;
    chatDraft.value = tr('home.qa_practice_prompt', {'w': w.latin, 'm': w.meaning});
    widget.onTabChange(1);
  }

  String get _username => _profile?['username'] as String? ?? 'Apprenant';
  int get _streak => ProfileService.effectiveStreak(_profile);
  int get _xp => _profile?['xp'] as int? ?? 0;
  int get _level => _profile?['level'] as int? ?? 1;
  int get _xpToNext => _level * 1000;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: ContentClamp(
        padding: EdgeInsets.fromLTRB(
          Responsive.isMobile(context)
              ? LinguaSpacing.screen
              : LinguaSpacing.xxxl,
          LinguaSpacing.sm,
          Responsive.isMobile(context)
              ? LinguaSpacing.screen
              : LinguaSpacing.xxxl,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreeting(),
            const SizedBox(height: LinguaSpacing.xl),
            _loading ? _buildSkeleton(78) : _buildStreakCard(),
            const SizedBox(height: LinguaSpacing.md + 2),
            _loading ? _buildSkeleton(74) : _buildXpCard(),
            const SizedBox(height: LinguaSpacing.stackSection),
            SectionLabel(tr('home.quick_actions')),
            const SizedBox(height: LinguaSpacing.md),
            _buildQuickActions(),
            const SizedBox(height: LinguaSpacing.stackSection),
            SectionLabel(tr('home.daily_lesson')),
            const SizedBox(height: LinguaSpacing.md),
            _buildDailyLesson(),
            const SizedBox(height: LinguaSpacing.stackSection),
            SectionLabel(tr('home.word_of_day'), accent: true),
            const SizedBox(height: LinguaSpacing.md),
            _buildWordOfDay(),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton(double height) {
    final t = context.tokens;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: t.surfaceRaised,
        borderRadius: LinguaRadius.rCard,
        border: Border.all(color: t.outlineSubtle),
      ),
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2, color: t.accent),
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    final t = context.tokens;
    final hour = DateTime.now().hour;
    final greetingKey = hour < 12
        ? 'home.greeting_morning'
        : hour < 18
            ? 'home.greeting_afternoon'
            : 'home.greeting_evening';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${tr(greetingKey)},',
          style: GoogleFonts.manrope(color: t.textSecondary, fontSize: 16),
        ),
        // Le nom en Oswald, mais SANS capitales forcées : `ScreenTitle` les
        // impose et un nom propre en capitales se lit mal.
        Text(
          _loading ? '…' : _username,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.oswald(
            color: t.textPrimary,
            fontSize: 34,
            fontWeight: FontWeight.w700,
            height: 1.05,
          ),
        ),
      ],
    );
  }

  Widget _buildStreakCard() {
    final t = context.tokens;
    final alight = _streak > 0;

    return CopilotCard(
      padding: const EdgeInsets.symmetric(
        horizontal: LinguaSpacing.card,
        vertical: LinguaSpacing.lg,
      ),
      // La flamme borde la carte quand la série court : le registre du feu
      // signale l'état sans un mot de plus.
      edge: alight ? t.ember : null,
      child: Row(
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            size: 30,
            color: alight ? t.emberInk : t.textFaint,
          ),
          const SizedBox(width: LinguaSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('home.streak_days', {'n': '$_streak'}),
                  style: GoogleFonts.manrope(
                    color: t.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  tr(alight ? 'home.streak_keep' : 'home.streak_start'),
                  style: GoogleFonts.manrope(
                    color: t.textSecondary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          if (alight)
            AccentChip(
              label: tr('home.record'),
              icon: Icons.emoji_events_rounded,
              tone: ChipTone.reward,
            ),
        ],
      ),
    );
  }

  Widget _buildXpCard() {
    return CopilotCard(
      child: XpBar(xp: _xp, xpToNext: _xpToNext, level: _level),
    );
  }

  /// Deux raccourcis qui n'existent nulle part ailleurs (la nav bar couvre
  /// déjà Chat / Leçons / Progrès) : réviser une leçon terminée, et pratiquer
  /// le mot du jour avec Naxçi. Aucune requête en plus : profil et leçons
  /// sont déjà chargés.
  Widget _buildQuickActions() {
    if (_lessons.isEmpty) return _buildSkeleton(96);
    final review = HomeScreen.reviewLesson(_lessons, HomeScreen.dayIndex());

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _quickAction(
              icon: Icons.replay_rounded,
              title: tr('home.qa_review'),
              subtitle: review?.title ?? tr('home.qa_review_none'),
              onTap: review == null ? null : () => _openLesson(review),
            ),
          ),
          const SizedBox(width: LinguaSpacing.sm + 2),
          Expanded(
            child: _quickAction(
              icon: Icons.record_voice_over_rounded,
              title: tr('home.qa_practice'),
              subtitle: tr('home.qa_practice_sub', {'w': _wordOfDay.latin}),
              onTap: _practiceWord,
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    final t = context.tokens;
    final enabled = onTap != null;
    // L'InkWell de la carte porte déjà la sémantique de bouton ; désactivée,
    // la carte se lit comme un texte avec sa consigne (« Termine d'abord… »).
    return CopilotCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: enabled ? t.textAccent : t.textFaint),
          const SizedBox(height: LinguaSpacing.sm),
          Text(
            title,
            style: GoogleFonts.manrope(
              color: enabled ? t.textPrimary : t.textSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
              color: t.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyLesson() {
    final t = context.tokens;
    final lesson = HomeScreen.currentLesson(_lessons);
    if (lesson == null) return _buildSkeleton(96);

    return CopilotCard(
      child: Row(
        children: [
          // `lesson.icon` vient des données : on le laisse tel quel.
          Text(lesson.icon, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: LinguaSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.title,
                  style: GoogleFonts.manrope(
                    color: t.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  lesson.subtitle,
                  style: GoogleFonts.manrope(
                    color: t.textSecondary,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: LinguaSpacing.sm + 2),
                ClipRRect(
                  borderRadius: LinguaRadius.rPill,
                  child: SizedBox(
                    height: 5,
                    child: LinearProgressIndicator(
                      value: lesson.progress,
                      backgroundColor: t.surfaceSunken,
                      valueColor: AlwaysStoppedAnimation<Color>(t.accent),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: LinguaSpacing.md),
          CopilotButton(
            label: tr('common.continue'),
            variant: CopilotButtonVariant.tonal,
            onPressed: () => _openLesson(lesson),
          ),
        ],
      ),
    );
  }

  /// Mots du jour — vocabulaire attesté du corpus de l'app (leçons et
  /// system prompt de Naxçi), translittération conforme au système officiel.
  /// (latin, cyrillique, sens par langue d'interface — repli sur FR)
  static const _wordsOfDay = [
    ('barkalla', 'баркалла', {'FR': 'Merci', 'EN': 'Thank you', 'RU': 'Спасибо'}),
    ('de', 'де', {'FR': 'Jour', 'EN': 'Day', 'RU': 'День'}),
    ('büysa', 'буьйса', {'FR': 'Nuit', 'EN': 'Night', 'RU': 'Ночь'}),
    ('xi', 'хи', {'FR': 'Eau', 'EN': 'Water', 'RU': 'Вода'}),
    ('lam', 'лам', {'FR': 'Montagne', 'EN': 'Mountain', 'RU': 'Гора'}),
    ('ċa', 'цӀа', {'FR': 'Maison', 'EN': 'House', 'RU': 'Дом'}),
    ('nana', 'нана', {'FR': 'Mère', 'EN': 'Mother', 'RU': 'Мать'}),
    ('da', 'да', {'FR': 'Père', 'EN': 'Father', 'RU': 'Отец'}),
    ('dog', 'дог', {'FR': 'Cœur', 'EN': 'Heart', 'RU': 'Сердце'}),
    ('küg', 'куьг', {'FR': 'Main', 'EN': 'Hand', 'RU': 'Рука'}),
    ('bepig', 'бепиг', {'FR': 'Pain', 'EN': 'Bread', 'RU': 'Хлеб'}),
    ('şura', 'шура', {'FR': 'Lait', 'EN': 'Milk', 'RU': 'Молоко'}),
    ('ƶiƶig', 'жижиг', {'FR': 'Viande', 'EN': 'Meat', 'RU': 'Мясо'}),
    ('korta', 'корта', {'FR': 'Tête', 'EN': 'Head', 'RU': 'Голова'}),
    ('borz', 'борз', {'FR': 'Loup', 'EN': 'Wolf', 'RU': 'Волк'}),
    ('ärzu', 'аьрзу', {'FR': 'Aigle', 'EN': 'Eagle', 'RU': 'Орёл'}),
  ];

  /// Mot du jour : rotation quotidienne, un mot différent chaque jour civil.
  ({String latin, String cyrillic, String meaning}) get _wordOfDay {
    final word = _wordsOfDay[HomeScreen.dayIndex() % _wordsOfDay.length];
    return (
      latin: word.$1,
      cyrillic: word.$2,
      meaning: word.$3[localeController.value] ?? word.$3['FR'] ?? '',
    );
  }

  Widget _buildWordOfDay() {
    final t = context.tokens;
    final word = _wordOfDay;
    final meaning = word.meaning;

    return CopilotCard(
      gradient: t.heroGradient,
      padding: const EdgeInsets.all(LinguaSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Le mot passe par ChechenWord : latin sur la ligne principale,
          // cyrillique en appui doré, avec le balisage de langue qui va avec.
          ChechenWord(
            latin: word.latin,
            cyrillic: word.cyrillic,
            size: 30,
          ),
          const SizedBox(height: LinguaSpacing.md),
          Container(height: 1, color: t.outlineSubtle),
          const SizedBox(height: LinguaSpacing.md),
          Text(
            tr('home.word_meaning', {'m': meaning}),
            style: GoogleFonts.manrope(
              color: t.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
