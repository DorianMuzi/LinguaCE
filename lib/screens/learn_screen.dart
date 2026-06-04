import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../design/lingua_tokens.dart';
import '../design/lingua_scale.dart';
import '../design/lingua_components.dart';
import '../design/responsive.dart';
import '../i18n/app_strings.dart';
import '../models/models.dart';
import '../services/lesson_service.dart';
import 'exercise_screen.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  List<LessonModel> _lessons = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final lessons = await LessonService.fetchLessons();
    if (!mounted) return;
    setState(() {
      _lessons = lessons;
      _loading = false;
    });
  }

  Future<void> _openLesson(LessonModel lesson) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ExerciseScreen(lesson: lesson)),
    );
    _load(); // recharge la progression au retour
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
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
            _buildHeader(t),
            const SizedBox(height: 20),
            _loading
                ? _buildSkeleton(t)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProgressOverview(t),
                      const SizedBox(height: 28),
                      SectionLabel(tr('learn.path')),
                      const SizedBox(height: 12),
                      ..._lessons.map((l) =>
                          _LessonCard(lesson: l, onOpen: () => _openLesson(l))),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton(LinguaTokens t) {
    return Column(
      children: List.generate(
        4,
        (_) => Container(
          height: 84,
          margin: const EdgeInsets.only(bottom: 12),
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
        ),
      ),
    );
  }

  Widget _buildHeader(LinguaTokens t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tr('learn.title1'),
            style: GoogleFonts.playfairDisplay(
                color: t.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.bold)),
        Text(tr('learn.title2'),
            style: GoogleFonts.playfairDisplay(
                color: t.accent, fontSize: 28, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildProgressOverview(LinguaTokens t) {
    final completed =
        _lessons.where((l) => l.status == LessonStatus.completed).length;
    final total = _lessons.length;
    return CopilotCard(
      gradient: t.heroGradient,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tr('learn.lessons_count', {'c': '$completed', 't': '$total'}),
                    style: GoogleFonts.playfairDisplay(
                        color: t.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                Text(tr('learn.completed'),
                    style:
                        GoogleFonts.inter(color: t.textSecondary, fontSize: 14)),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    height: 6,
                    child: LinearProgressIndicator(
                      value: total == 0 ? 0 : completed / total,
                      backgroundColor: t.surfaceSunken,
                      valueColor: AlwaysStoppedAnimation<Color>(t.accent),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Column(
            children: [
              const Text('🏅', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 4),
              Text(
                  tr(completed == total && total > 0
                      ? 'learn.finished'
                      : 'learn.beginner'),
                  style: GoogleFonts.spaceMono(color: t.accent, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final LessonModel lesson;
  final VoidCallback onOpen;
  const _LessonCard({required this.lesson, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final isLocked = lesson.status == LessonStatus.locked;
    final isCompleted = lesson.status == LessonStatus.completed;
    final isActive = lesson.status == LessonStatus.active;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: isLocked ? null : onOpen,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isLocked ? t.surfaceSunken : t.surfaceRaised,
            borderRadius: LinguaRadius.rLg,
            border: Border.all(
              color: isActive
                  ? t.accent
                  : isCompleted
                      ? t.accent.withValues(alpha: 0.4)
                      : t.outlineSubtle,
              width: isActive ? 1.5 : 1,
            ),
            boxShadow: isLocked ? null : t.shadowSm,
          ),
          child: Row(
            children: [
              _buildStatusIcon(t, isCompleted, isLocked),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            lesson.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.playfairDisplay(
                              color:
                                  isLocked ? t.textTertiary : t.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (isActive) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: t.accentSoft,
                              borderRadius: LinguaRadius.rPill,
                              border: Border.all(color: t.accent),
                            ),
                            child: Text(tr('learn.in_progress'),
                                style: GoogleFonts.spaceMono(
                                    color: t.accentStrong,
                                    fontSize: 9,
                                    letterSpacing: 1)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(lesson.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                            color: t.textSecondary, fontSize: 13)),
                    if (isActive && lesson.completedExercises > 0) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: SizedBox(
                          height: 4,
                          child: LinearProgressIndicator(
                            value: lesson.progress,
                            backgroundColor: t.surfaceSunken,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(t.accent),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tr('learn.exercises_count', {
                          'c': '${lesson.completedExercises}',
                          't': '${lesson.totalExercises}'
                        }),
                        style: GoogleFonts.spaceMono(
                            color: t.textTertiary, fontSize: 10),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('+${lesson.xpReward} XP',
                      style: GoogleFonts.spaceMono(
                          color: isLocked ? t.textTertiary : t.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (!isLocked)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isCompleted ? t.surfaceSunken : t.accent,
                        borderRadius: LinguaRadius.rPill,
                      ),
                      child: Text(
                        tr(isCompleted ? 'learn.review' : 'learn.start'),
                        style: GoogleFonts.inter(
                          color: isCompleted ? t.textSecondary : t.onAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    Icon(Icons.lock_outline, color: t.textTertiary, size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(LinguaTokens t, bool isCompleted, bool isLocked) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isCompleted ? t.accentSoft : t.surfaceSunken,
        shape: BoxShape.circle,
        border: Border.all(color: isCompleted ? t.accent : t.outline),
      ),
      child: Center(
        child: isCompleted
            ? Icon(Icons.check_rounded, color: t.accent, size: 22)
            : Text(lesson.icon, style: const TextStyle(fontSize: 20)),
      ),
    );
  }
}
