import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../design/lingua_tokens.dart';
import '../design/lingua_scale.dart';
import '../design/lingua_components.dart';
import '../design/responsive.dart';
import '../i18n/app_strings.dart';
import '../models/models.dart';
import '../services/profile_service.dart';
import '../services/lesson_service.dart';
import '../widgets/xp_bar.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<int> onTabChange;

  const HomeScreen({super.key, required this.onTabChange});

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
    _loadProfile();
    _loadLessons();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ProfileService.getOrCreateProfile();
      if (mounted) setState(() { _profile = profile; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadLessons() async {
    final lessons = await LessonService.fetchLessons();
    if (mounted) setState(() => _lessons = lessons);
  }

  String get _username => _profile?['username'] as String? ?? 'Apprenant';
  int get _streak => _profile?['streak'] as int? ?? 0;
  int get _xp => _profile?['xp'] as int? ?? 0;
  int get _level => _profile?['level'] as int? ?? 1;
  int get _xpToNext => _level * 1000;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: ContentClamp(
        padding: EdgeInsets.fromLTRB(
          Responsive.isMobile(context) ? 20 : 32,
          8,
          Responsive.isMobile(context) ? 20 : 32,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreeting(),
            const SizedBox(height: 20),
            _loading ? _buildSkeleton(78) : _buildStreakCard(),
            const SizedBox(height: 14),
            _loading ? _buildSkeleton(74) : _buildXpCard(),
            const SizedBox(height: 28),
            SectionLabel(tr('home.quick_actions')),
            const SizedBox(height: 12),
            _buildQuickActions(),
            const SizedBox(height: 28),
            SectionLabel(tr('home.daily_lesson')),
            const SizedBox(height: 12),
            _buildDailyLesson(),
            const SizedBox(height: 28),
            SectionLabel(tr('home.word_of_day')),
            const SizedBox(height: 12),
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
        borderRadius: LinguaRadius.rLg,
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
        Text('${tr(greetingKey)},',
            style: GoogleFonts.inter(color: t.textSecondary, fontSize: 16)),
        Text(
          _loading ? '…' : _username,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.playfairDisplay(
            color: t.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStreakCard() {
    final t = context.tokens;
    return CopilotCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 30)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('home.streak_days', {'n': '$_streak'}),
                  style: GoogleFonts.playfairDisplay(
                    color: t.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  tr(_streak > 0 ? 'home.streak_keep' : 'home.streak_start'),
                  style:
                      GoogleFonts.inter(color: t.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          if (_streak > 0) AccentChip(label: tr('home.record'), emoji: '🏆'),
        ],
      ),
    );
  }

  Widget _buildXpCard() {
    return CopilotCard(
      child: XpBar(xp: _xp, xpToNext: _xpToNext, level: _level),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {'icon': '💬', 'label': 'home.qa_chat', 'tab': 1},
      {'icon': '📚', 'label': 'home.qa_lessons', 'tab': 2},
      {'icon': '📊', 'label': 'home.qa_progress', 'tab': 3},
    ];
    return Row(
      children: actions.map((a) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: a == actions.last ? 0 : 10),
            child: CopilotCard(
              padding: const EdgeInsets.symmetric(vertical: 18),
              onTap: () => widget.onTabChange(a['tab'] as int),
              child: Column(
                children: [
                  Text(a['icon'] as String,
                      style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 6),
                  Text(
                    tr(a['label'] as String),
                    style: GoogleFonts.inter(
                      color: context.tokens.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDailyLesson() {
    final t = context.tokens;
    if (_lessons.isEmpty) {
      return _buildSkeleton(96);
    }
    final lesson = _lessons.firstWhere(
      (l) => l.status == LessonStatus.active,
      orElse: () => _lessons.firstWhere(
        (l) => l.status != LessonStatus.completed,
        orElse: () => _lessons.first,
      ),
    );
    return CopilotCard(
      child: Row(
        children: [
          Text(lesson.icon, style: const TextStyle(fontSize: 34)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.title,
                  style: GoogleFonts.playfairDisplay(
                    color: t.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(lesson.subtitle,
                    style: GoogleFonts.inter(
                        color: t.textSecondary, fontSize: 13)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: SizedBox(
                    height: 4,
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
          const SizedBox(width: 12),
          CopilotButton(
            label: tr('common.continue'),
            variant: CopilotButtonVariant.tonal,
            onPressed: () => widget.onTabChange(2),
          ),
        ],
      ),
    );
  }

  Widget _buildWordOfDay() {
    final t = context.tokens;
    return CopilotCard(
      gradient: t.heroGradient,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AccentChip(label: tr('home.word_of_day'), emoji: '✨'),
          const SizedBox(height: 12),
          Text('barkalla',
              style: GoogleFonts.playfairDisplay(
                color: t.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              )),
          Text('баркалла',
              style:
                  GoogleFonts.spaceMono(color: t.textSecondary, fontSize: 14)),
          const SizedBox(height: 8),
          Text(tr('home.word_desc'),
              style: GoogleFonts.inter(color: t.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}
